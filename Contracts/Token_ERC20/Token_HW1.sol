// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./interfaces/IBlacklist.sol";

contract Token is ERC20, Ownable{

address public blAddress;
    constructor(string memory TokenName, string memory TokenSymbol, address blAddress_) ERC20(TokenName, TokenSymbol) Ownable(_msgSender()) {
        blAddress = blAddress_;
     }

    function mint (address account, uint256 amount) external onlyOwner {
        _beforeTokenTransfer(_msgSender(), account, amount);
        _mint(account, amount);
    }

    function burn (address account, uint256 amount) external {
        _beforeTokenTransfer(_msgSender(), address (0), amount);
        _burn(account, amount);
    }

    function transfer(address to, uint256 value) public override returns (bool) {
        _beforeTokenTransfer(_msgSender(), to, value);
        super._transfer(_msgSender(), to, value);
        return true;
    }

    function transferFrom(address from, address to, uint256 value) public override returns (bool) {
        _beforeTokenTransfer(from, to, value);
        super._transfer(from, to, value);
        return true;
    }
 
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal view {
        amount;
        if(IBlacklist(blAddress).isBlacklisted(from) || IBlacklist(blAddress).isBlacklisted(to)) {
            revert("address is Blacklisted");
        }

    }
}