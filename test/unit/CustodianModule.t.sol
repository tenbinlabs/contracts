// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

import {BaseTest} from "test/BaseTest.sol";
import {CustodianModule} from "src/CustodianModule.sol";
import {IAccessControl} from "lib/openzeppelin-contracts/contracts/access/IAccessControl.sol";

contract CustodianModuleTest is BaseTest {
    function test_Deployment() public view {
        assertTrue(custodianModule.hasRole(ADMIN_ROLE, admin));
        assertTrue(custodianModule.hasRole(KEEPER_ROLE, keeper));
    }

    function test_AccessControl() public {
        vm.expectPartialRevert(IAccessControl.AccessControlUnauthorizedAccount.selector);
        custodianModule.setCustodianStatus(address(0), true);

        vm.expectPartialRevert(IAccessControl.AccessControlUnauthorizedAccount.selector);
        custodianModule.send(address(0), address(0), 0);
    }

    function test_SetCustodianStatus() public {
        vm.startPrank(owner);
        vm.expectEmit();
        emit CustodianModule.CustodianUpdated(user, true);
        custodianModule.setCustodianStatus(user, true);

        // verify state
        assertTrue(custodianModule.custodians(user));

        // Opposite state
        vm.expectEmit();
        emit CustodianModule.CustodianUpdated(user, false);
        custodianModule.setCustodianStatus(user, false);

        // verify state
        assertFalse(custodianModule.custodians(user));

        vm.stopPrank();
    }

    function test_Revert_setCustodianStatus() public {
        vm.startPrank(owner);
        vm.expectRevert(CustodianModule.NonZeroAddress.selector);
        custodianModule.setCustodianStatus(address(0), true);
        vm.stopPrank();
    }

    function test_Send() public {
        uint256 amount = 100 ether;
        uint256 beforeBal = collateral.balanceOf(user);

        collateral.mint(address(custodianModule), amount);
        vm.startPrank(owner);
        custodianModule.setCustodianStatus(user, true);
        vm.stopPrank();

        vm.startPrank(keeper);
        custodianModule.send(user, address(collateral), amount);
        vm.stopPrank();

        assertEq(collateral.balanceOf(user), beforeBal + amount);
    }

    function test_Revert_Send() public {
        vm.startPrank(keeper);
        vm.expectRevert(CustodianModule.NonZeroAddress.selector);
        custodianModule.send(address(0), address(collateral), 10 ether);

        vm.expectRevert(CustodianModule.NonZeroAddress.selector);
        custodianModule.send(address(1), address(0), 10 ether);

        vm.expectRevert(CustodianModule.NotApprovedCustodian.selector);
        custodianModule.send(address(1), address(collateral), 100 ether);

        vm.stopPrank();
    }
}
