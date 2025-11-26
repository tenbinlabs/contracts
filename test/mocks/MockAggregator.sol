// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

import {AggregatorInterface} from "src/external/chainlink/AggregatorInterface.sol";
import {SafeCast} from "lib/openzeppelin-contracts/contracts/utils/math/SafeCast.sol";

/// @title Mock chainlink oracle which allows setting price directly
contract MockAggregator is AggregatorInterface {
    using SafeCast for uint256;

    /// @dev Mock answer
    int256 answer;

    /// @dev Get answer
    function latestAnswer() external view returns (int256) {
        return answer;
    }

    /// @dev Set answer by converting uint256 with 18 decimals to int256 with 8 decimals
    function setAnswer(uint256 newAnswer) external {
        answer = (newAnswer / 1e10).toInt256();
    }

    function getAnswer(uint256 roundId) external view returns (int256) {}
    function latestTimestamp() external view returns (uint256) {}
    function latestRound() external view returns (uint256) {}
    function getTimestamp(uint256 roundId) external view returns (uint256) {}
}
