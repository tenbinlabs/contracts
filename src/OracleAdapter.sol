// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

import {AggregatorInterface} from "src/external/chainlink/AggregatorInterface.sol";
import {IOracleAdapter} from "src/interface/IOracleAdapter.sol";
import {SafeCast} from "lib/openzeppelin-contracts/contracts/utils/math/SafeCast.sol";

/// @title Oracle Adapter
/// @notice Normalize oracle data from a Chainlink aggregator into a standard representation
contract OracleAdapter is IOracleAdapter {
    using SafeCast for int256;

    /// @notice Chainlink oracle
    AggregatorInterface public immutable oracle;

    /// @param oracle_ Address of chainlink oracle
    constructor(address oracle_) {
        oracle = AggregatorInterface(oracle_);
    }

    /// @inheritdoc IOracleAdapter
    /// @dev Return price in USD with 18 decimals
    function getPrice() external view returns (uint256) {
        return oracle.latestAnswer().toUint256() * 1e10;
    }
}
