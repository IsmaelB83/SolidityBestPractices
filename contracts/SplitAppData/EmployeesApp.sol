// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./Employees.sol";

contract EmployeesApp {

    using SafeMath for uint256;   
    Employees employees;

    constructor (address dataContract) {
        employees = Employees(dataContract);
    }

    function calculateBonus ( uint256 sales ) internal pure returns(uint256) {
        if (sales < 100) {
            return SafeMath.div(SafeMath.mul(sales, 5), 100);
        }
        else if (sales < 500) {
            return SafeMath.div(SafeMath.mul(sales, 7), 100);
        }
        else {
            return SafeMath.div(SafeMath.mul(sales, 10), 100);
        }
    }

    function addSale (string memory id, uint256 amount ) external {
        employees.updateEmployee(id, amount, calculateBonus(amount));
    }
}