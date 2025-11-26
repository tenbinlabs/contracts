// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

/// @title OracleAdapter
/// @notice Normalize price data from an external source into a standard representation
interface IOracleAdapter {
    /// @notice Returns price with 18 decimals of precision
    /// @return price Price with 18 decimals of precision
    function getPrice() external view returns (uint256 price);
}
