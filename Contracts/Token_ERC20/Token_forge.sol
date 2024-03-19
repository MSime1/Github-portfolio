//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import "lib/openzeppelin-contracts/contracts/access/Ownable.sol";


contract Token is ERC20, Ownable {

  

    constructor() ERC20("MyToken", "MTKN") Ownable(msg.sender) {
        _mint(msg.sender, 1000 * 10**decimals());
    }

    
    function mint(address account, uint256 amount) public onlyOwner {
        _mint(account, amount);
    }

    function burn(address account, uint256 amount) public {
        require(msg.sender == owner(), "Only owner can burn tokens");
        _burn(account, amount);
    }
}
