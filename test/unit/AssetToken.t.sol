// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

import {IERC20Errors} from "lib/openzeppelin-contracts/contracts/interfaces/draft-IERC6093.sol";
import {AssetToken} from "src/AssetToken.sol";
import {Test} from "forge-std/Test.sol";

contract AssetTokenTest is Test {
    AssetToken internal token;
    uint256 internal account0Key = 0xA000;
    address internal account0;
    address internal minter;
    address internal owner;

    function setUp() public {
        account0 = vm.addr(account0Key);
        minter = vm.addr(0xA001);
        owner = vm.addr(0xA002);
        token = new AssetToken("Asset Token", "AST", owner);
    }

    function test_Revert_Mint(uint256 amount) public {
        // can't mint from non-minter account
        vm.expectRevert(AssetToken.OnlyMinter.selector);
        token.mint(account0, amount);
    }

    function test_Mint(uint256 amount) public {
        vm.prank(owner);
        token.setMinter(minter);
        vm.prank(minter);
        token.mint(account0, amount);
        assertEq(token.balanceOf(account0), amount);
        assertEq(token.totalSupply(), amount);
    }

    function test_Revert_Burn(uint256 burnAmount) public {
        burnAmount = bound(burnAmount, 1, type(uint256).max);
        vm.expectPartialRevert(IERC20Errors.ERC20InsufficientAllowance.selector);
        token.burn(account0, burnAmount);
    }

    function test_Burn(uint256 amount, uint256 burnAmount) public {
        burnAmount = bound(burnAmount, 0, amount);
        vm.prank(owner);
        token.setMinter(minter);
        vm.prank(minter);
        token.mint(account0, amount);
        vm.startPrank(account0);
        token.approve(account0, burnAmount);
        token.burn(account0, burnAmount);
        assertEq(token.balanceOf(account0), amount - burnAmount);
        assertEq(token.totalSupply(), amount - burnAmount);
    }

    function test_Revert_SetMinter() public {
        vm.prank(account0);
        vm.expectRevert();
        token.setMinter(account0);
    }

    function test_SetMinter(address account) public {
        vm.expectEmit();
        emit AssetToken.MinterChanged(account);
        vm.prank(owner);
        token.setMinter(account);
        assertEq(token.minter(), account);
    }
}
