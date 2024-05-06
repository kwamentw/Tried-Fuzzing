// SPDX-License-Identifier:MIT
pragma solidity 0.8.20;

import {Test} from "forge-std/Test.sol";
import {Vault} from "../src/vault.sol";
import {FourbToken} from "../src/mock/ERC20Mock.sol";

/**
 * @title Vault Handler
 * @notice A handler to facilitate fuzz testing `Vault`
 */
contract VaultHandler is Test {
    //initialisations
    Vault simplevault;
    FourbToken token;

    address USER = makeAddr("USER");

    constructor(Vault _vault) {
        // initialising token
        token = new FourbToken("4BTOKEN", "4BTKN", 6, 900);
        // initialising vault
        simplevault = _vault;

        // minting some tokens to vault
        vm.startPrank(address(simplevault));
        token.mint(100e6);
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
        token.mint(amountOfAssets + 10e6);

        token.approve(amountOfAssets + 10e6, address(simplevault));

        simplevault.deposit(address(this), amountOfAssets);
        vm.stopPrank();
    }
}
