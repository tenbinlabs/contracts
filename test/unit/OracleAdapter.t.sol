// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

import {MockAggregator} from "test/mocks/MockAggregator.sol";
import {OracleAdapter} from "src/OracleAdapter.sol";
import {Test} from "forge-std/Test.sol";

contract OracleAdapterTest is Test {
    uint256 internal constant ADAPTER_PRECISION = 1e10;

    MockAggregator internal aggregator;
    OracleAdapter internal adapter;

    function setUp() public {
        aggregator = new MockAggregator();
        adapter = new OracleAdapter(address(aggregator));
    }

    function test_OracleAdapter() public {
        aggregator.setAnswer(1e18);
        assertEq(adapter.getPrice(), 1e18);
    }

    function test_fuzz_OracleAdapter(uint256 price) public {
        price = bound(price, ADAPTER_PRECISION, 1e48);
        aggregator.setAnswer(price);
        assertApproxEqAbs(adapter.getPrice(), price, ADAPTER_PRECISION);
    }
}
