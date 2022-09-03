// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
 
contract Fund {
 
   mapping(address=>uint) shares;
 
   function safeWithdraw(uint256 amount) public {
       // Checks
       require(msg.sender == tx.origin, "Contracts not allowed");
       require(shares[msg.sender] >= amount, "Insufficient funds");
       // Effects
       uint256 newBalance = SafeMath.sub(shares[msg.sender], amount);
       shares[msg.sender] = newBalance;
       // Interaction
       payable(msg.sender).transfer(amount);
   }
}