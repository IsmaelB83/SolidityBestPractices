// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
 
contract CheckEffectInteraction {
 
    mapping(address=>uint) shares;
    
    function deposit() public payable {
        //uint256 newBalance = SafeMath.add(shares[msg.sender], msg.value);
        shares[msg.sender] += msg.value;
    }

    function safeWithdraw(uint256 amount) public {
        // Checks
        require(msg.sender == tx.origin, "Contracts not allowed");
        require(shares[msg.sender] >= amount, "Insufficient funds");
        // Effects
        uint256 newBalance = SafeMath.sub(shares[msg.sender], amount);
        shares[msg.sender] = newBalance;
        // Interaction
        payable((msg.sender)).transfer(amount);
    }

    function getBalance() public view returns (uint256) {
        return shares[msg.sender];
    }
}