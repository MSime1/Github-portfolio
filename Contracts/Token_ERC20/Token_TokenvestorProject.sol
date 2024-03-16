// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Token is ERC20, Ownable {

    uint8 private _tokenDecimals;
    uint256 private _maxSupply;

    constructor(
        string memory tokenName,
        string memory tokenSymbol,
        uint8 tokenDecimals,
        uint256 maxSupply,
        address onlyOwner
    ) ERC20(tokenName, tokenSymbol) Ownable(onlyOwner) {
        _tokenDecimals = tokenDecimals;
        _maxSupply = maxSupply;
    }

    function decimals() public view override returns (uint8) {
        return _tokenDecimals;
    }

    function getMaxSupply() public view returns (uint256) {
        return _maxSupply;
    }

    function remainingMintable() public view returns (uint256) {
        return getMaxSupply() - totalSupply();
    }

    function mint(address account, uint256 amount) external onlyOwner {
        require(totalSupply() + amount <= getMaxSupply(), "Exceeds max supply");
        _mint(account, amount);
    }

    function burn(address account, uint256 amount) external {
        _burn(account, amount);
    }
}
