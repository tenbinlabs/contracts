// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

import {VaultComposerSync} from "lib/devtools/packages/ovault-evm/contracts/VaultComposerSync.sol";

/**
 * @title LayerZeroOVaultComposer
 * @notice Cross-chain vault composer enabling omnichain vault operations via LayerZero
 */
contract LayerZeroOVaultComposer is VaultComposerSync {
    /**
     * @notice Creates a new cross-chain vault composer
     * @dev Initializes the composer with vault and OFT contracts for omnichain operations
     * @param _vault The vault contract implementing ERC4626 for deposit/redeem operations
     * @param _assetOFT The OFT contract for cross-chain asset transfers
     * @param _shareOFT The OFT contract for cross-chain share transfers
     */
    constructor(address _vault, address _assetOFT, address _shareOFT) VaultComposerSync(_vault, _assetOFT, _shareOFT) {}
}
