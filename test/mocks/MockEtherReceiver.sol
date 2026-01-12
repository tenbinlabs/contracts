// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

/// Revert when receiving ETH
contract MockEtherReceiver {
    // Revert on receiving ETH
    receive() external payable {
        revert("Cannot receive ETH");
    }
}
