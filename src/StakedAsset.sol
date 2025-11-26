// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

import {AccessControl} from "lib/openzeppelin-contracts/contracts/access/AccessControl.sol";
import {AssetSilo} from "src/AssetSilo.sol";
import {IERC20, ERC20} from "lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import {IRestrictedRegistry} from "src/interface/IRestrictedRegistry.sol";
import {IStakedAsset} from "src/interface/IStakedAsset.sol";
import {ERC20Permit} from "lib/openzeppelin-contracts/contracts/token/ERC20/extensions/ERC20Permit.sol";
import {ERC4626} from "lib/openzeppelin-contracts/contracts/token/ERC20/extensions/ERC4626.sol";
import {Math} from "lib/openzeppelin-contracts/contracts/utils/math/Math.sol";
import {SafeERC20} from "lib/openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";

/// @title StakedAsset
/// @notice Allows staking an asset token for a staking token
/// Rewards can be sent to this contract to reward stakers proportionally to their stake
/// Includes a vesting period over which pending rewards are linearly vested
/// Whenever a reward is paid to the contract, the vesting period resets
/// Includes a cooldown period over which a user must wait between cooldown and withdrawing
/// When cooldownLength > 0, the normal withdraw() and redeem() functions will revert
/// Users call cooldownShares() and cooldownAssets() to initiate cooldown
/// If a cooldown already exists for a user, initiating cooldown again with additional assets will reset the cooldown time
/// Users do not earn rewards for assets during the cooldown period
/// Assets in cooldown are stored in a Silo contract until cooldown is complete
/// After the cooldown is completed, users can call withdraw() to claim their asset tokens
///
/// In order to avoid a first depositor donation attack a minimum stake should be made in the same transaction as the contract deployment
contract StakedAsset is IStakedAsset, IRestrictedRegistry, ERC20Permit, ERC4626, AccessControl {
    using SafeERC20 for IERC20;

    /// @notice Rewarder role transfers asset tokens into the contract
    bytes32 constant REWARDER_ROLE = keccak256("REWARDER_ROLE");

    /// @notice Admin role can change vesting and cooldown period
    bytes32 constant ADMIN_ROLE = keccak256("ADMIN_ROLE");

    /// @notice Restricter role can change restricted status of accounts
    bytes32 constant RESTRICTER_ROLE = keccak256("RESTRICTER_ROLE");

    /// @notice Max cooldown period
    uint256 public constant MAX_COOLDOWN_LENGTH = 90 days;

    /// @notice Max vesting period
    uint256 public constant MAX_VESTING_LENGTH = 90 days;

    /// @notice Min vesting period to prevent rounding errors when calculating rewards within 0.1%
    uint256 public constant MIN_VESTING_LENGTH = 1200 seconds;

    /// @notice Minimum amount of shares allowed
    uint256 public constant MIN_SHARES = 1e18;

    /// @notice AssetSilo holds assets during cooldown
    AssetSilo public immutable silo;

    /// @notice Amount of shares in cooldown for an account
    mapping(address => Cooldown) public cooldowns;

    /// @notice Cooldown period for unstaking in seconds
    uint256 public cooldownLength;

    /// @notice Vesting data
    Vesting public vesting;

    /// @notice Keep track of restricted addresses
    mapping(address => bool) public isRestricted;

    /// @dev Revert if zero address
    modifier nonZeroAddress(address addr) {
        if (addr == address(0)) revert NonZeroAddress();
        _;
    }

    /// @dev Reverts if account is restricted
    modifier nonRestricted(address account) {
        if (isRestricted[account]) revert AccountRestricted();
        _;
    }

    /// @param name_ Name of this token
    /// @param symbol_ Symbol for this token
    /// @param asset_ Asset to stake and reward
    constructor(string memory name_, string memory symbol_, IERC20 asset_, address owner_)
        ERC20(name_, symbol_)
        ERC20Permit(name_)
        ERC4626(asset_)
        nonZeroAddress(owner_)
    {
        _grantRole(DEFAULT_ADMIN_ROLE, owner_);
        silo = new AssetSilo(address(this), address(asset_));
    }

    /// @notice Get pending rewards for this contract
    /// @return amount Pending unvested rewards
    function pendingRewards() external view returns (uint256 amount) {
        amount = _pendingRewards();
    }

    /// @inheritdoc IStakedAsset
    function reward(uint256 assets) external onlyRole(REWARDER_ROLE) {
        if (vesting.length > 0) {
            uint256 pending = _pendingRewards();
            vesting.assets = pending + assets;
            vesting.end = uint128(block.timestamp) + vesting.length;
            emit VestingStarted(pending + assets, uint128(block.timestamp) + vesting.length);
        }
        IERC20(asset()).safeTransferFrom(msg.sender, address(this), assets);
        emit RewardsReceived(assets);
    }

    /// @inheritdoc IStakedAsset
    function cooldownShares(uint256 shares) external nonRestricted(msg.sender) returns (uint256 assets) {
        if (shares > maxRedeem(msg.sender)) revert CooldownExceededMaxRedeem();
        assets = previewRedeem(shares);
        // forge-lint: disable-next-line(unsafe-typecast)
        cooldowns[msg.sender].assets += uint160(assets);
        // forge-lint: disable-next-line(unsafe-typecast)
        cooldowns[msg.sender].end = uint96(block.timestamp + cooldownLength);
        _withdraw(msg.sender, address(silo), msg.sender, assets, shares);
        emit CooldownStarted(msg.sender, assets);
    }

    /// @inheritdoc IStakedAsset
    function cooldownAssets(uint256 assets) external nonRestricted(msg.sender) returns (uint256 shares) {
        if (assets > maxWithdraw(msg.sender)) revert CooldownExceededMaxWithdraw();
        shares = previewWithdraw(assets);
        // forge-lint: disable-next-line(unsafe-typecast)
        cooldowns[msg.sender].assets += uint160(assets);
        // forge-lint: disable-next-line(unsafe-typecast)
        cooldowns[msg.sender].end = uint96(block.timestamp + cooldownLength);
        _withdraw(msg.sender, address(silo), msg.sender, assets, shares);
        emit CooldownStarted(msg.sender, assets);
    }

    /// @notice Unstake shares that are in cooldown
    /// @param to Account to transfer assets to
    function unstake(address to) external nonRestricted(msg.sender) nonZeroAddress(to) {
        Cooldown memory cooldown = cooldowns[msg.sender];
        if (cooldown.end > block.timestamp) revert CooldownInProgress();
        delete cooldowns[msg.sender];
        silo.withdraw(to, cooldown.assets);
        emit Unstake(msg.sender, to, cooldown.assets);
    }

    /// @notice Set a new vesting period
    /// @param newVestingLength New vesting period
    /// @dev Note: setting low vesting lengths causes rounding issues
    function setVestingLength(uint128 newVestingLength) external onlyRole(ADMIN_ROLE) {
        if (newVestingLength > MAX_VESTING_LENGTH) revert ExceedsMaxVestingLength();
        if (newVestingLength < MIN_VESTING_LENGTH && newVestingLength != 0) revert SubceedsMinVestingLength();
        if (vesting.end > block.timestamp) revert VestingNotCompleted();
        vesting.length = newVestingLength;

        emit VestingLengthUpdated(newVestingLength);
    }

    /// @notice Set a new cooldown period
    /// @param newCooldownLength New cooldown period
    function setCooldownLength(uint256 newCooldownLength) external onlyRole(ADMIN_ROLE) {
        if (newCooldownLength > MAX_COOLDOWN_LENGTH) revert ExceedsMaxCooldownLength();
        cooldownLength = newCooldownLength;

        emit CooldownLengthUpdated(newCooldownLength);
    }

    /// @inheritdoc IRestrictedRegistry
    function setIsRestricted(address account, bool newStatus) external onlyRole(RESTRICTER_ROLE) {
        isRestricted[account] = newStatus;
        emit RestrictedStatusChanged(account, newStatus);
    }

    /// @notice Withdraw assets from a restricted account.
    /// Without the ability to redeem frozen shares, a portion of rewards will be stuck in the contract
    /// Always redeems the full balance of the restricted account
    /// @param from Restricted account to redeem shares from
    /// @param to Account to transfer assets to
    function transferRestrictedAssets(address from, address to)
        external
        nonZeroAddress(to)
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        if (!isRestricted[from]) revert NonRestrictedAccount();
        uint256 shares = balanceOf(from);
        uint256 assets = previewRedeem(shares);
        _withdraw(from, to, from, assets, shares);

        Cooldown memory cooldown = cooldowns[from];
        if (cooldown.assets > 0) {
            delete cooldowns[from];
            silo.withdraw(to, cooldown.assets);
        }
    }

    /// @dev Overrides the deposit function to include restricted address check
    function deposit(uint256 assets, address receiver)
        public
        override
        nonRestricted(msg.sender)
        nonRestricted(receiver)
        returns (uint256 shares)
    {
        shares = super.deposit(assets, receiver);
        _checkMinShares();
    }

    /// @notice Get number of decimals for this token
    /// @return Decimals for this token
    function decimals() public pure override(ERC4626, ERC20) returns (uint8) {
        return 18;
    }

    /// @notice Withdraw function which reverts when cooldown is active
    function withdraw(uint256 assets, address receiver, address owner) public override returns (uint256) {
        if (cooldownLength > 0) revert RequiresCooldown();
        return super.withdraw(assets, receiver, owner);
    }

    /// @notice Redeem function which requires cooldown
    function redeem(uint256 shares, address receiver, address owner) public override returns (uint256) {
        if (cooldownLength > 0) revert RequiresCooldown();
        return super.redeem(shares, receiver, owner);
    }

    /// @notice Calculate total assets minus pending reward
    /// @return Total assets not including pending reward
    function totalAssets() public view override returns (uint256) {
        return IERC20(asset()).balanceOf(address(this)) - _pendingRewards();
    }

    /// @notice Rescue tokens sent to this contract
    /// @param token The address of the ERC20 token to be rescued
    /// @param to Recipient of rescued tokens
    /// @dev the receiver should be a trusted address to avoid external calls attack vectors
    function rescueToken(address token, address to) external onlyRole(ADMIN_ROLE) nonZeroAddress(to) {
        if (token == asset()) revert InvalidRescueToken();
        IERC20(token).safeTransfer(to, IERC20(token).balanceOf(address(this)));
    }

    /// @dev Override transfer function to prevent restricted accounts from transferring
    function transfer(address to, uint256 value)
        public
        override(IERC20, ERC20)
        nonRestricted(msg.sender)
        nonRestricted(to)
        returns (bool)
    {
        return super.transfer(to, value);
    }

    function transferFrom(address from, address to, uint256 value)
        public
        override(IERC20, ERC20)
        nonRestricted(from)
        nonRestricted(to)
        returns (bool)
    {
        return super.transferFrom(from, to, value);
    }

    /// @dev Override of _withdraw to enforce minimum shares remain
    function _withdraw(address caller, address receiver, address _owner, uint256 assets, uint256 shares)
        internal
        override
    {
        super._withdraw(caller, receiver, _owner, assets, shares);
        _checkMinShares();
    }

    /// @dev Calculate pending reward based on vesting time and length
    /// @return pending Pending unvested rewards
    function _pendingRewards() internal view returns (uint256 pending) {
        Vesting memory data = vesting;
        uint256 end = data.end;
        uint256 length = data.length;
        uint256 assets = data.assets;
        if (length == 0) return 0;
        if (block.timestamp >= end) return 0;
        pending = Math.mulDiv(assets, end - block.timestamp, length);
    }

    /// @dev Ensures a small non-zero amount of shares always remains
    function _checkMinShares() internal view {
        uint256 _totalSupply = totalSupply();
        if (_totalSupply < MIN_SHARES) revert BelowMinimumShare();
    }
}
