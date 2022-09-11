// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract Oracles {

    // Allow SafeMath functions to be called for all uint256 types (similar to "prototype" in Javascript)
    using SafeMath for uint256; 

    // Account used to deploy contract
    address private contractOwner;                  
    // Incremented to add pseudo-randomness at various points
    uint8 private nonce = 0;    
    // Fee to be paid when registering oracle
    uint256 public constant REGISTRATION_FEE = 1 ether;
    // Number of oracles that must respond for valid status
    uint256 private constant MIN_RESPONSES = 3;
    // Status codes returned by oracles
    uint8 private constant ON_TIME = 10;
    uint8 private constant NOT_ON_TIME = 99;

    // Track all registered oracles
    mapping(address => uint8[3]) private oracles;
    // Model for responses from oracles
    struct ResponseInfo {
        address requester;                              // Account that requested status
        bool isOpen;                                    // If open, oracle responses are accepted
        mapping(uint8 => address[]) responses;          // Mapping key is the status code reported
                                                        // This lets us group responses and identify
                                                        // the response that majority of the oracles
                                                        // submit
    }
    // Track all oracle responses
    // Key = hash(index, flight, timestamp)
    mapping(bytes32 => ResponseInfo) private oracleResponses;


    // Flight data persisted forever
    struct FlightStatus {
        bool hasStatus;
        uint8 status;        
    }
    mapping(bytes32 => FlightStatus) flights;

    constructor () {
        contractOwner = msg.sender;
    }
   
    /********************************************************************************************/
    /*                                     SMART CONTRACT MODIFIERS                             */
    /********************************************************************************************/
    modifier requireContractOwner() {
        require(msg.sender == contractOwner, "Caller is not contract owner");
        _;
    }
    /********************************************************************************************/
    /*                                     SMART CONTRACT EVENTS                                */
    /********************************************************************************************/
    // Event fired each time an oracle submits a response
    event FlightStatusInfo(string flight, uint256 timestamp, uint8 status, bool verified);

    // Event fired when flight status request is submitted
    // Oracles track this and if they have a matching index they fetch data and submit a response
    event OracleRequest(uint8 index, string flight, uint256 timestamp);

    /********************************************************************************************/
    /*                                     SMART CONTRACT FUNCTIONS                             */
    /********************************************************************************************/
    function registerOracle () external payable {
        // Require registration fee
        require (msg.value >= REGISTRATION_FEE, "To register an oracle a stake of 1 ether is required");
        // Generate three random indexes (range 0-9) using generateIndexes for the calling oracle
        uint8[3] memory indexes = generateIndexes(msg.sender);
        // Assign the indexes to the oracle and save to the contract state
        oracles[msg.sender] = indexes;
    }

    function getOracle (address account) external view requireContractOwner returns(uint8[3] memory) {
        return oracles[account];
    }

    function fetchFlightStatus (string memory flight, uint256 timestamp) external {
        // Generate index with a random index based on the calling account
        uint8 index = getRandomIndex(msg.sender);
        // Generate a unique key for storing the request
        bytes32 key = keccak256(abi.encodePacked(index, flight, timestamp));
        ResponseInfo storage newResponseInfo = oracleResponses[key];
        newResponseInfo.requester = msg.sender;
        newResponseInfo.isOpen = true;
        // Notify oracles that match the index value that they need to fetch flight status
        emit OracleRequest(index, flight, timestamp);
    }

    // Called by oracle when a response is available to an outstanding request
    // For the response to be accepted, there must be a pending request that is open
    // and matches one of the three Indexes randomly assigned to the oracle at the
    // time of registration (i.e. uninvited oracles are not welcome)
    function submitOracleResponse (uint8 index, string memory flight, uint256 timestamp, uint8 statusId) external {
        require((oracles[msg.sender][0] == index) || (oracles[msg.sender][1] == index) || (oracles[msg.sender][2] == index), "Index does not match oracle request");
        // Require that the response is being submitted for a request that is still open
        bytes32 key = keccak256(abi.encodePacked(index, flight, timestamp));
        require(oracleResponses[key].isOpen == true, "Request already close");
        // Push response
        oracleResponses[key].responses[statusId].push(msg.sender);
        // Information isn't considered verified until at least MIN_RESPONSES oracles respond with the same information
        if (oracleResponses[key].responses[statusId].length >= MIN_RESPONSES) {
            // Prevent any more responses since MIN_RESPONSE threshold has been reached
            oracleResponses[key].isOpen = false;
            // Announce to the world that verified flight status information is available
            emit FlightStatusInfo(flight, timestamp, statusId, true);
            // Save the flight information for posterity
            bytes32 flightKey = keccak256(abi.encodePacked(flight, timestamp));
            flights[flightKey] = FlightStatus(true, statusId);
        } else {
            //  Announce to the world that NON-verified flight status information is available
            emit FlightStatusInfo(flight, timestamp, statusId, false);
        }
    }

    // Query the status of any flight
    function viewFlightStatus (string memory flight, uint256 timestamp) external view returns(uint8) {
            bytes32 flightKey = keccak256(abi.encodePacked(flight, timestamp));
            require(flights[flightKey].hasStatus, "Flight status not available");
            return flights[flightKey].status;
    }

    // Returns array of three non-duplicating integers from 0-9
    function generateIndexes (address account) internal returns(uint8[3] memory) {
        uint8[3] memory indexes;
        
        indexes[0] = getRandomIndex(account);

        indexes[1] = indexes[0];
        while(indexes[1] == indexes[0]) {
            indexes[1] = getRandomIndex(account);
        }

        indexes[2] = indexes[1];
        while((indexes[2] == indexes[0]) || (indexes[2] == indexes[1])) {
            indexes[2] = getRandomIndex(account);
        }

        return indexes;
    }

    // Returns array of three non-duplicating integers from 0-9
    function getRandomIndex (address account) internal returns (uint8) {
        uint8 maxValue = 10;
        // Pseudo random number...the incrementing nonce adds variation
        uint8 random = uint8(uint256(keccak256(abi.encodePacked(blockhash(block.number - nonce++), account))) % maxValue);
        if (nonce > 250) {
            nonce = 0;  // Can only fetch blockhashes for last 256 blocks so we adapt
        }
        return random;
    }
}