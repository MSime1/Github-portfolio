// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {Test, console} from "forge-std/Test.sol";
import {Token} from "../src/Token.sol";

contract TokenTest is Test {
    Token public token;

    address public owner;
    address public ZERO_ADDRESS = address(0);
    address public spender = address(1);
    address public user = address(2);

    string public name = "MyToken";
    string public symbol = "MTKN";

    uint256 public decimals = 18;
    uint256 public publicamount = 1000 * 1e18;
    uint256 public initialSupply = 1000 * 1e18;

    event Transfer(address indexed from, address indexed to, uint256 amount);

    function setUp() public {
      owner = address(this);
      token = new Token();

    }

    function testinitialState() public view {
        
        assertEq(token.name(), name);
        assertEq(token.symbol(), symbol);
        assertEq(token.decimals(), decimals);
        assertEq(token.totalSupply(), initialSupply);
      

    }

    function testFailUnauthorizedMinter(uint256 amount) public {
        vm.prank(user);
        token.mint(user, amount);
    }

    function testFailMintToAccountZero(uint256 amount) public {
        vm.prank(user);
        token.mint(ZERO_ADDRESS, amount);        
    }

    function testIncreseTotalSupply() public {
        uint amount = 1000 * 1e18;
        uint256 expectedSupply = initialSupply + amount;
        vm.prank(owner);
        token.mint(owner, amount);
        assertEq(token.totalSupply(), expectedSupply);
    }

      function testDecreseTotalSupply() public {
        uint amount = 1000 * 1e18;
        uint256 expectedSupply = initialSupply - amount;
        vm.prank(owner);
        token.burn(owner, amount);
        assertEq(token.totalSupply(), expectedSupply);
    }

   function testIncreaseOwnerBalance() public {
        uint amount = 1000 * 1e18;
        vm.prank(owner);
        token.mint(user, amount);
        assertEq(token.balanceOf(user), amount);
    }
    

    function testEmitTransferEventForMint() public {
        uint amount = 10000 * 1e18;
        vm.expectEmit(true, true, false, true);
        emit Transfer(ZERO_ADDRESS, user, amount);
        vm.prank(owner);
        token.mint(user, amount);
    }
    
}
