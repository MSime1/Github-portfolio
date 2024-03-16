// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MyToken is ERC20, Ownable {
    constructor(string memory _tokenName, string memory _tokenSymbol) 
    ERC20(_tokenName, _tokenSymbol) {
        _mint(msg.sender, 1000000*10e18);
    }
}