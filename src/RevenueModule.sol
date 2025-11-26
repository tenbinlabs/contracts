// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

import {AccessControl} from "lib/openzeppelin-contracts/contracts/access/AccessControl.sol";
import {Controller} from "src/Controller.sol";
import {ICollateralManager} from "src/interface/ICollateralManager.sol";
import {IERC20} from "lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {IRevenueModule} from "src/interface/IRevenueModule.sol";
import {StakedAsset} from "src/StakedAsset.sol";
import {SafeERC20} from "lib/openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";

/// @title RevenueModule
/// @notice Manages revenue earned by the Tenbin protocol
/// Revenue is frequently used to offset the cost of off-chain hedging.
///
/// The revenue module can perform the following actions:
///
/// - Withdraw revenue from the collateral manager
/// - Transfer revenue back to the collateral manager
/// - Transfer revenue to a multisig contract
/// - Provide liquidity to mint new asset tokens as a reward
/// - Reward the staking pool with asset tokens
///
/// A keeper role is assigned by the revenue module to automate these tasks
/// For example, the keeper might be called 2x per day to transfer revenue back to the collateral manager, and 1x per day to reward the staking contract
contract RevenueModule is IRevenueModule, AccessControl {
    using SafeERC20 for IERC20;

    /// @notice Admin role manages delegating a signer and approving a controller to mint rewards from revenue
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");

    /// @notice Multisig role can withdraw revenue to a multisig contract
    bytes32 public constant MULTISIG_ROLE = keccak256("MULTISIG_ROLE");

    /// @notice Keeper role can pull revenue from the manager, transfer revenue to the manager, and reward the staking contract
    bytes32 public constant KEEPER_ROLE = keccak256("KEEPER_ROLE");

    /// @notice Address of asset staking pool
    address public immutable staking;

    /// @notice Address of asset token
    address public immutable asset;

    /// @notice Address of collateral manager contract
    address public immutable manager;

    /// @notice Address of controller contract
    address public immutable controller;

    /// @dev Revert if zero address
    modifier nonZeroAddress(address addr) {
        if (addr == address(0)) revert NonZeroAddress();
        _;
    }

    /// @dev RevenueModule constructor
    /// @param manager_ Manager account
    /// @param staking_ Staking contract address
    /// @param owner_ Default admin for this contract
    /// @param controller_ Controller contract address
    /// @param asset_ Asset token contract address
    constructor(address manager_, address staking_, address owner_, address controller_, address asset_)
        nonZeroAddress(manager_)
        nonZeroAddress(staking_)
        nonZeroAddress(owner_)
        nonZeroAddress(controller_)
        nonZeroAddress(asset_)
    {
        manager = manager_;
        staking = staking_;
        controller = controller_;
        asset = asset_;
        _grantRole(DEFAULT_ADMIN_ROLE, owner_);
    }

    /// @inheritdoc IRevenueModule
    function pull(address token) external override onlyRole(KEEPER_ROLE) nonZeroAddress(token) {
        ICollateralManager collateralManager = ICollateralManager(manager);
        uint256 revenueAmount = collateralManager.getRevenue(token);
        if (revenueAmount == 0) revert InsufficientRevenue();
        collateralManager.withdrawRevenue(token, revenueAmount);
        emit RevenuePulled(token, revenueAmount);
    }

    /// @inheritdoc IRevenueModule
    function withdrawToMultisig(address token, uint256 amount)
        external
        override
        nonZeroAddress(token)
        onlyRole(MULTISIG_ROLE)
    {
        _sendFunds(msg.sender, token, amount);
        emit WithdrawToMultisig(token, amount);
    }

    /// @inheritdoc IRevenueModule
    function withdrawToManager(address token, uint256 amount)
        external
        override
        onlyRole(KEEPER_ROLE)
        nonZeroAddress(token)
    {
        _sendFunds(manager, token, amount);
        emit WithdrawToManager(token, amount);
    }

    /// @inheritdoc IRevenueModule
    function reward(uint256 amount) external override onlyRole(KEEPER_ROLE) {
        IERC20(asset).safeIncreaseAllowance(staking, amount);
        StakedAsset(staking).reward(amount);
        emit RewardSent(amount);
    }

    /// @inheritdoc IRevenueModule
    function increaseControllerApproval(address token, uint256 amount)
        external
        onlyRole(ADMIN_ROLE)
        nonZeroAddress(token)
    {
        IERC20(token).safeIncreaseAllowance(controller, amount);
    }

    /// @inheritdoc IRevenueModule
    function delegateSigner(address signer, bool status) external onlyRole(ADMIN_ROLE) {
        Controller(controller).setDelegateStatus(signer, status);
    }

    /// @dev Helper function to handle token transfers
    /// @param to Receiver of tokens
    /// @param token Token address to be sent
    /// @param amount Amount to be sent
    function _sendFunds(address to, address token, uint256 amount) private {
        if (amount == 0) revert InvalidAmount();
        IERC20(token).safeTransfer(to, amount);
    }
}
