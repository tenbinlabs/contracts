// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

import {SendLibBaseE2} from "lib/LayerZero-v2/packages/layerzero-v2/evm/messagelib/contracts/SendLibBaseE2.sol";
import {
    SetConfigParam
} from "lib/LayerZero-v2/packages/layerzero-v2/evm/protocol/contracts/interfaces/IMessageLibManager.sol";
import {WorkerOptions} from "lib/LayerZero-v2/packages/layerzero-v2/evm/messagelib/contracts/SendLibBase.sol";
import {Ownable} from "lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import {Packet} from "lib/LayerZero-v2/packages/layerzero-v2/evm/protocol/contracts/interfaces/ISendLib.sol";

contract MockSendLibBaseE2 is Ownable, SendLibBaseE2 {
    constructor(address _endpoint, address _owner) SendLibBaseE2(_endpoint, type(uint256).max, 0) Ownable(_owner) {}

    function setConfig(address, SetConfigParam[] calldata) external {}

    function getConfig(uint32, address, uint32) external view returns (bytes memory) {}

    function getDefaultConfig(uint32 _eid, uint32 _configType) external view returns (bytes memory) {}

    function isSupportedEid(
        uint32 /*_eid*/
    )
        external
        pure
        returns (bool)
    {
        return true;
    }

    function _quoteVerifier(address, uint32, WorkerOptions[] memory) internal view override returns (uint256) {}

    function version() external view returns (uint64, uint8, uint8) {}

    function _splitOptions(bytes calldata) internal view override returns (bytes memory, WorkerOptions[] memory) {}

    function _payVerifier(Packet calldata, WorkerOptions[] memory) internal override returns (uint256, bytes memory) {}

    function mockFee(address _owner, uint256 _fee) external {
        fees[_owner] = _fee;
    }
}
