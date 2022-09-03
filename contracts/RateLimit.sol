// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
 
contract RateLimit {
 
    mapping(address=>uint) shares;

    uint256 enabled = block.timestamp;
    
    modifier rateLimit(uint time) {
        require(block.timestamp >= enabled, "Rate limiting in effect");
        enabled = SafeMath.add(enabled, time);
        _;
    }

    function deposit() public payable {
        //uint256 newBalance = SafeMath.add(shares[msg.sender], msg.value);
        shares[msg.sender] += msg.value;
    }

    function safeWithdraw(uint256 amount) public rateLimit(30 minutes) {
        // Checks
        require(msg.sender == tx.origin, "Contracts not allowed");
        require(shares[msg.sender] >= amount, "Insufficient funds");
        // Effects
        uint256 newBalance = SafeMath.sub(shares[msg.sender], amount);
        shares[msg.sender] = newBalance;
        // Interaction
        payable((msg.sender)).transfer(amount);
    }
}