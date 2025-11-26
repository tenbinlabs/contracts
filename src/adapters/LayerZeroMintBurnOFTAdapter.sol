// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

import {MintBurnOFTAdapter} from "lib/devtools/packages/oft-evm/contracts/MintBurnOFTAdapter.sol";
import {IMintableBurnable} from "lib/devtools/packages/oft-evm/contracts/interfaces/IMintableBurnable.sol";
import {Ownable} from "lib/openzeppelin-contracts/contracts/access/Ownable.sol";

/// @notice OFT Adapter which mints and burns tokens on spoke chains
/// This contract should be set as `minter` in AssetToken on spoke chains
contract LayerZeroMintBurnOFTAdapter is Ownable, MintBurnOFTAdapter {
    constructor(address _owner, address _token, address _minterBurner, address _lzEndpoint, address _delegate)
        Ownable(_owner)
        MintBurnOFTAdapter(_token, IMintableBurnable(_minterBurner), _lzEndpoint, _delegate)
    {}
}
