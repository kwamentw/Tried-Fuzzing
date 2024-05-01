// SPDX-License-Identifier:MIT
pragma solidity 0.8.20;

import {Test} from "forge-std/Test.sol";
import {Vault} from "../src/vault.sol";
import {FourbToken} from "../src/mock/ERC20Mock.sol";

contract VaultHandler is Test {
    Vault simplevault;
    FourbToken token;

    address USER = makeAddr("USER");

    constructor(Vault _vault) {
        token = new FourbToken("4BTOKEN", "4BTKN", 6, 900);
        simplevault = _vault;

        vm.prank(address(simplevault));
        token.mint(100e6);
    }

    function deposit(uint256 amountOfAssets) public {
        amountOfAssets = bound(amountOfAssets, 1e6, address(this).balance);

        vm.startPrank(USER);
        bool tru = token.mint(amountOfAssets + 10e6);
        require(tru, "didnt mint");

        bool appruv = token.approve(
            amountOfAssets + 10e6,
            address(simplevault)
        );
        require(appruv, "Didn't approve");

        simplevault.deposit(amountOfAssets);
        vm.stopPrank();
    }
}
