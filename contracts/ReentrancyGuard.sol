// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract ReentrancyGuard {
    uint256 private counter = 1;

    modifier entrancyGuard() {
        counter = SafeMath.add(counter, 1);
        uint256 localCounter = counter;
        _;
        require(localCounter == counter, "Renntrancy guard fails");
    }

    function safeWithdraw(uint256 amount) external entrancyGuard {
        // ...
    }
}