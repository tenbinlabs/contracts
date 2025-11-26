// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.30;

import {OFTAdapter} from "lib/devtools/packages/oft-evm/contracts/OFTAdapter.sol";
import {Ownable} from "lib/openzeppelin-contracts/contracts/access/Ownable.sol";

/// @notice OFTAdapter uses a deployed ERC-20 token and SafeERC20 to interact with the OFTCore contract.
contract LayerZeroOFTAdapter is OFTAdapter {
    constructor(address _token, address _lzEndpoint, address _owner)
        OFTAdapter(_token, _lzEndpoint, _owner)
        Ownable(_owner)
    {}
}
