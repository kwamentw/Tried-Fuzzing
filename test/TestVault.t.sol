//SPDX-License-Identifier:MIT
pragma solidity 0.8.20;

import {Test} from "forge-std/Test.sol";
import {Vault} from "../src/vault.sol";
import {ERC20} from "../src/mock/ERC20Mock.sol";
import {StdInvariant} from "forge-std/StdInvariant.sol";
import {VaultHandler} from "./Handler.sol";
import {console2} from "forge-std/console2.sol";

/**
 * @title Vault Test
 * @notice Test script for testing the vault
 */

contract VaultTest is Test {
    // underlying token
    ERC20 underlyingTkn;
    // vault contract
    Vault simplevault;
    // vault handler for invariant testing
    VaultHandler handler;

    // actor
    address USER = makeAddr("USER");

    /**
     * Setting up all the variables needed for testing
     */
    function setUp() public {
        // initializing underlying asset
        underlyingTkn = new ERC20("FOURBTOKEN", "4bTKN", 6, 1000);

        // initializing vault
        simplevault = new Vault(
            address(underlyingTkn),
            underlyingTkn.decimals()
        );

        // initializing my handler
        handler = new VaultHandler(simplevault);

        // setting custom selectors(This way stateful fuzz will be between these functions and not random ones)
        // bytes4[] memory selectorss = new bytes4[](1);
        // selectorss[0] = handler.deposit.selector;
        // targetSelector(
        //     FuzzSelector({addr: address(handler), selectors: selectorss})
        // );

        // setting target contract so invariant tests interact with handler instead of actual contract
        targetContract(address(handler));

        // minting some tokens to the vault
        vm.prank(address(simplevault));
        underlyingTkn.mint(address(simplevault), 1000e6);

        // minting some tokens to the handler
        vm.prank(address(handler));
        underlyingTkn.mint(address(handler), 1000e6);
    }

    /**
     * Unit test for the deposit function
     */
    function testDepositing() public {
        vm.startPrank(USER);
        underlyingTkn.mint(USER, 100e6);

        underlyingTkn.approve(address(simplevault), 100e6);

        simplevault.deposit(USER, 100e6);

        vm.stopPrank();

        assertGt(simplevault.totalSupply(), simplevault.balanceOfUser(USER));

        console2.log(simplevault.totalAssets());
        console2.log(simplevault.totalSupply());
        console2.log(underlyingTkn.balanceOf(USER));
        console2.log(simplevault.balanceOfUser(USER));
    }

    /**
     * Unit test for withdraw function
     */
    function testWithdrawVault1() public {
        vm.startPrank(USER);
        underlyingTkn.mint(USER, 100e6);

        underlyingTkn.approve(address(simplevault), 100e6);

        simplevault.deposit(USER, 100e6);

        vm.stopPrank();

        vm.prank(USER);
        simplevault.withdraw();

        assertEq(simplevault.balanceOfUser(USER), 0);
        assertEq(underlyingTkn.balanceOf(USER), 100e6);
    }

    /**
     * Invariant to check that total assets are always greater than balance of User
     */
    function invariant_TAGtBU() public view {
        assertGt(simplevault.totalAssets(), simplevault.balanceOfUser(USER));
    }

    /**
     * when depositing this invariant should always hold
     */
    function invariant_totalSupplyGTbalanceofUser() public view {
        assertLt(simplevault.balanceOfUser(USER), simplevault.totalSupply());
    }

    /**
     * Testing whether handler deposit was working.
     * Trying to find the cause of the overflow/undeflow error
     */
    function testhandlerDeposit() public {
        handler.deposit(100e6);
    }
}
