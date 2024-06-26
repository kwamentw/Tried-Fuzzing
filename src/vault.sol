//SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {IERC20} from "./interfaces/IERC20.sol";

/**
 * @title MyVault
 * @author 4B
 * @notice This vault was created purposely for fuzzing
 */
contract Vault {
    address public immutable i_underlying;

    string public name;
    string public symbol;

    uint8 public immutable i_decimals;

    uint256 public totalSupply;

    mapping(address => uint) public balanceOfUser;

    /**
     * //////////////  INITIALIZING /////////////
     * @param _underlying underlying token of the vault to be initialised
     * @param _decimals number of decimals the vault will be working with
     */
    constructor(address _underlying, uint8 _decimals) {
        i_underlying = _underlying;
        i_decimals = _decimals;

        _mint(30e6);
    }

    /**
     * Mints shares to sender
     * @param shares amount of shares to mint
     */
    function _mint(uint256 shares) internal {
        require(shares > 0, "Cannot mint 0 shares");
        totalSupply += shares;
        balanceOfUser[msg.sender] += shares;
    }

    function mint_(uint256 shares) public {
        _mint(shares);
    }

    /**
     * Burns vault shares from sender
     * @param shares amount of shares
     */
    function _burn(uint256 shares) internal {
        require(shares > 0, "we have to burn something");
        totalSupply -= shares;
        balanceOfUser[msg.sender] -= shares;
    }

    /**
     * Returns the amount of underlying assets this contract holds
     */
    function totalAssets() public view returns (uint256) {
        uint256 thisAssets = IERC20(i_underlying).balanceOf(address(this));
        return thisAssets;
    }

    /**
     * Converts amount deposited to the shares(how many shares of the vault you have)
     * @param amount amount to convert
     */
    function converToShares(uint256 amount) private view returns (uint256) {
        uint256 shares;
        shares = (amount * totalSupply) / totalAssets();
        return shares;
    }

    /**
     * Converts shares to amount of underlying asset or token
     */
    function convertToAssets(uint256 shares) private view returns (uint256) {
        uint256 amountAssets = (shares * totalAssets()) / totalSupply;
        return amountAssets;
    }

    /**
     * Depositing assets into the vault
     * @param user address of user depositing the shares
     * @param amount amount of underlying token to deposit
     */
    function deposit(address user, uint256 amount) external {
        uint256 shares = converToShares(amount);
        _mint(shares);
        bool ok = IERC20(i_underlying).transferFrom(
            user,
            address(this),
            amount
        );
        require(ok, "Txn failed");
    }

    /**
     * Withdrawing shares user has in the vault
     */
    function withdraw() external {
        uint256 shares = balanceOfUser[msg.sender];
        uint256 amountToWithdraw = convertToAssets(shares);
        _burn(shares);
        bool ok = IERC20(i_underlying).transfer(msg.sender, amountToWithdraw);
        require(ok, "Txn failed");
    }
}
