// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract Employees {

    using SafeMath for uint256; 

    struct Profile {
        string id;
        bool isRegistered;
        bool isAdmin;
        uint256 sales;
        uint256 bonus;
        address wallet;
    }

    address private contractOwner;                  // Account used to deploy contract
    mapping(string => Profile) employees;
    mapping(address => bool) private authorized;

    constructor () {
        contractOwner = msg.sender;
    }

    modifier isCallerAuthrized() {
        require(authorized[msg.sender] == true, "Not an authorized contract call");
        _;
    }

    modifier requireContractOwner() {
        require(msg.sender == contractOwner, "Caller is not contract owner");
        _;
    }

    function authorizeContract(address contractAddress) external requireContractOwner {
        authorized[contractAddress] = true;
    }

    function deauthorizeContract(address contractAddress) external requireContractOwner {
        authorized[contractAddress] = false;
    }

    function isAuthorizedContract(address contractAddress) external view returns(bool) {
        return authorized[contractAddress];
    }

    function isEmployeeRegistered (string memory id) external view returns(bool) {
        return employees[id].isRegistered;
    }

   function registerEmployee (string memory id, bool isAdmin, address wallet ) external {
        require(!employees[id].isRegistered, "Employee is already registered.");
        employees[id] = Profile({   id: id,
                                    isRegistered: true,
                                    isAdmin: isAdmin,
                                    sales: 0,
                                    bonus: 0,
                                    wallet: wallet
                                });
    }

    function getEmployee (string memory id) external view returns(address, bool, bool, uint256, uint256) {
        return (employees[id].wallet, employees[id].isRegistered, employees[id].isAdmin, employees[id].sales, employees[id].bonus);
    }

    function getEmployeeBonus (string memory id ) external view returns(uint256) {
        return employees[id].bonus;
    }

    function updateEmployee (string memory id, uint256 sales, uint256 bonus ) external isCallerAuthrized {
        require(employees[id].isRegistered, "Employee is not registered.");
        employees[id].sales = SafeMath.add(employees[id].sales, sales);
        employees[id].bonus = SafeMath.add(employees[id].bonus, bonus);

    }
}