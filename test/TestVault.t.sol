//SPDX-License-Identifier:MIT
pragma solidity 0.8.20;

import {Test} from "forge-std/Test.sol";
import {Vault} from "../src/vault.sol";
import {FourbToken} from "../src/mock/ERC20Mock.sol";
import {StdInvariant} from "forge-std/StdInvariant.sol";
import {VaultHandler} from "./Handler.sol";
import {console2} from "forge-std/console2.sol";

contract VaultTest is Test {
    FourbToken underlyingTkn;
    Vault simplevault;
    VaultHandler handler;

    address USER = makeAddr("USER");

    function setUp() public {
        underlyingTkn = new FourbToken("FOURBTOKEN", "4bTKN", 6, 1000);
        simplevault = new Vault(
            address(underlyingTkn),
            underlyingTkn.decimals()
        );

        handler = new VaultHandler(simplevault);
        targetContract(address(handler));

        vm.prank(address(simplevault));
        underlyingTkn.mint(1000e6);

        vm.prank(address(handler));
        underlyingTkn.mint(1000e6);
    }

    // function testConverShares() public view {
    //     simplevault.converToShares(90e6);
    // }

    function testDepositing() public {
        vm.startPrank(USER);
        underlyingTkn.mint(100e6);

        underlyingTkn.approve(95e6, address(simplevault));

        simplevault.deposit(90e6);

        vm.stopPrank();

        assertGt(simplevault.totalSupply(), simplevault.balanceOfUser(USER));

        console2.log(simplevault.totalAssets());
        console2.log(simplevault.totalSupply());
        console2.log(underlyingTkn.balanceOfAddress(USER));
        console2.log(simplevault.balanceOfUser(USER));
    }

    function testWithdrawVault1() public {
        vm.startPrank(USER);
        underlyingTkn.mint(100e6);

        underlyingTkn.approve(95e6, address(simplevault));

        simplevault.deposit(90e6);

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
}
