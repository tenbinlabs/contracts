// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

import {IERC20} from "lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "lib/openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";

/// @title AssetSilo
/// @notice Stores assets in cooldown for Tenbin protocol staking
contract AssetSilo {
    using SafeERC20 for IERC20;

    /// @notice Only staking contract
    error OnlyStaking();

    /// @notice Staking contract
    address public immutable staking;

    /// @notice Asset token
    IERC20 immutable asset;

    /// @dev AssetSilo constructor
    /// @param staking_ Address of staking contract
    /// @param asset_ Address of asset contract
    constructor(address staking_, address asset_) {
        staking = staking_;
        asset = IERC20(asset_);
    }

    /// @notice Withdraw assets to an account
    /// @param to Account to withdraw tokens to
    /// @param amount Amount of tokens to withdraw
    function withdraw(address to, uint256 amount) external {
        if (msg.sender != staking) revert OnlyStaking();
        asset.safeTransfer(to, amount);
    }
}
