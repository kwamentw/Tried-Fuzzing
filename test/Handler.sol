// SPDX-License-Identifier:MIT
pragma solidity 0.8.20;

import {Test} from "forge-std/Test.sol";
import {Vault} from "../src/vault.sol";
import {ERC20} from "../src/mock/ERC20Mock.sol";

/**
 * @title Vault Handler
 * @notice A handler to facilitate fuzz testing `Vault`
 */
contract VaultHandler is Test {
    //initialisations
    Vault simplevault;
    ERC20 token;

    address USER = makeAddr("USER");

    constructor(Vault _vault) {
        // initialising token
        token = new ERC20("4BTOKEN", "4BTKN", 6, 900);
        // initialising vault
        simplevault = _vault;

        // minting some tokens to vault
        vm.startPrank(address(simplevault));
        token.mint(address(simplevault), 100e6);
        vm.stopPrank();
    }

    /**
     * A function to call vault deposit
     * @param amountOfAssets amount of assets to deposit
     * // error: panic arithmetic overflow underflow ;; i don't know why still checking
     * got it to work after changing the user to address(this) instead of USER!
     */
    function deposit(uint256 amountOfAssets) public {
        amountOfAssets = bound(amountOfAssets, 1e6, 100e6);

        vm.startPrank(address(this));
        token.mint(address(this), amountOfAssets + 10e6);

        token.approve(address(simplevault), amountOfAssets + 10e6);

        simplevault.deposit(address(this), amountOfAssets);
        vm.stopPrank();
    }
}
