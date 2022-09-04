// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

contract MultipartAndPause {

    /********************************************************************************************/
    /*                                       DATA VARIABLES                                     */
    /********************************************************************************************/
    struct UserProfile {
        bool isRegistered;
        bool isAdmin;
    }

    address private contractOwner;                  // Account used to deploy contract
    mapping(address => UserProfile) userProfiles;   // Mapping for storing user profiles

    bool public operational;

    uint constant M = 2;
    address[] multiCalls = new address[](0);

    /********************************************************************************************/
    /*                                       EVENT DEFINITIONS                                  */
    /********************************************************************************************/
    // No events

    /**
    * @dev Constructor
    * The deploying account becomes contractOwner
    */
    constructor() {
        contractOwner = msg.sender;
        operational = true;
    }

    /********************************************************************************************/
    /*                                       FUNCTION MODIFIERS                                 */
    /********************************************************************************************/

    // Modifiers help avoid duplication of code. They are typically used to validate something
    // before a function is allowed to be executed.

    /**
    * @dev Modifier that requires the "ContractOwner" account to be the function caller
    */
    modifier requireContractOwner() {
        require(msg.sender == contractOwner, "Caller is not contract owner");
        _;
    }

    /// @dev This modifier checks whether the contract is paused or not
    modifier isOperational() {
        require(operational == true, "Smart contract is paused");
        _;
    }

    /// @dev Checks whether the message sender is an admin or not (for multi-party consensus)
    modifier requiredAdmin() {
        require(userProfiles[msg.sender].isAdmin == true, "Sender is not an admin");
        _;
    }

    /********************************************************************************************/
    /*                                       UTILITY FUNCTIONS                                  */
    /********************************************************************************************/

   /**
    * @dev Check if a user is registered
    * @return A bool that indicates if the user is registered
    */   
    function isUserRegistered (address account) external view returns(UserProfile memory) {
        require(account != address(0), "'account' must be a valid address.");
        return (userProfiles[account]);
    }

    /********************************************************************************************/
    /*                                     SMART CONTRACT FUNCTIONS                             */
    /********************************************************************************************/
    function registerUser (address account, bool isAdmin) external requireContractOwner isOperational {
        //require(!userProfiles[account].isRegistered, "User is already registered.");
        userProfiles[account] = UserProfile({ isRegistered: true, isAdmin: isAdmin });
    }

    function setOperational (bool status) public requiredAdmin {
        require(operational != status, "Contract status is already the value requested");
        // Check duplicated calls
        bool isDuplicate = false;
        for (uint256 i = 0; i < multiCalls.length; i++) {
            if (multiCalls[i] == msg.sender) {
                isDuplicate = true;
                break;
            }
        }
        require(isDuplicate == false, "An admin can call just once");
        
        // Add to multiCalls array and check approval step
        multiCalls.push(msg.sender);
        if (multiCalls.length == M) {
            operational = status;
            multiCalls = new address[](0);
        }
    }
}