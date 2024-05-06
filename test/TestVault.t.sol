//SPDX-License-Identifier:MIT
pragma solidity 0.8.20;

import {Test} from "forge-std/Test.sol";
import {Vault} from "../src/vault.sol";
import {FourbToken} from "../src/mock/ERC20Mock.sol";
import {StdInvariant} from "forge-std/StdInvariant.sol";
import {VaultHandler} from "./Handler.sol";
import {console2} from "forge-std/console2.sol";

/**
 * @title Vault Test
 * @notice Test script for the vault
 */

contract VaultTest is Test {
    FourbToken underlyingTkn;
    Vault simplevault;
    VaultHandler handler;

    address USER = makeAddr("USER");

    /**
     * Setting up all the variables needed for testing
     */
    function setUp() public {
        // initializing underlying asset
        underlyingTkn = new FourbToken("FOURBTOKEN", "4bTKN", 6, 1000);

        // initializing vault
        simplevault = new Vault(
            address(underlyingTkn),
            underlyingTkn.decimals()
        );

        // initializing my handler
        handler = new VaultHandler(simplevault);

        // setting custom selectors(This way stateful fuzz will be between these functions and not random ones)
        bytes4[] memory selectorss = new bytes4[](1);
        selectorss[0] = handler.deposit.selector;
        targetSelector(
            FuzzSelector({addr: address(handler), selectors: selectorss})
        );

        // setting target contract so invariant tests interact with handler instead of actual contract
        targetContract(address(handler));

        // minting some tokens to the vault
        vm.prank(address(simplevault));
        underlyingTkn.mint(1000e6);

        // minting some tokens to the handler
        vm.prank(address(handler));
        underlyingTkn.mint(1000e6);
    }

    // function testConverShares() public view {
    //     simplevault.converToShares(90e6);
    // }

    /**
     * Unit test for the deposit function
     */
    function testDepositing() public {
        vm.startPrank(USER);
        underlyingTkn.mint(100e6);

        underlyingTkn.approve(100e6, address(simplevault));

        simplevault.deposit(USER, 100e6);

        vm.stopPrank();

        assertGt(simplevault.totalSupply(), simplevault.balanceOfUser(USER));

        console2.log(simplevault.totalAssets());
        console2.log(simplevault.totalSupply());
        console2.log(underlyingTkn.balanceOf(USER));
        console2.log(simplevault.balanceOfUser(USER));
    }

    function testWithdrawVault1() public {
        vm.startPrank(USER);
        underlyingTkn.mint(100e6);

        underlyingTkn.approve(95e6, address(simplevault));

        simplevault.deposit(USER, 90e6);

        vm.stopPrank();

        vm.prank(USER);
        simplevault.withdraw();

        assertEq(simplevault.balanceOfUser(USER), 0);
        assertEq(underlyingTkn.balanceOfAddress(USER), 100e6);
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
     * Trying to find the cause of the overflow/undeflow error
     */
    function testhandlerDeposit() public {
        handler.deposit(100e6);
    }
}
