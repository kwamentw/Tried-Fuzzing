// SPDX-License-Identifier:MIT
pragma solidity 0.8.20;

import {Test} from "forge-std/Test.sol";
import {Vault} from "../src/vault.sol";
import {ERC20} from "../src/mock/ERC20Mock.sol";

contract VaultHandler is Test {
    Vault simplevault;
    ERC20 token;

    address USER = makeAddr("USER");

    constructor(Vault _vault) {
        token = new ERC20("4BTOKEN", "4BTKN", 6, 900);
        simplevault = _vault;

        vm.startPrank(address(simplevault));
        token.mint(address(simplevault), 100e6);
        vm.stopPrank();
    }

    function deposit(uint256 amountOfAssets) public {
        amountOfAssets = bound(amountOfAssets, 1e6, 100e6);

        vm.startPrank(USER);
        token.mint(USER, amountOfAssets + 10e6);

        token.approve(address(simplevault), amountOfAssets + 10e6);

        simplevault.deposit(USER, amountOfAssets);
        vm.stopPrank();
    }
}
