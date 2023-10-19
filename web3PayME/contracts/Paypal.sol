// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

// Uncomment this line to use console.log
// import "hardhat/console.sol";

contract Paypal {
    // S1 : Define the owner of the smart contract

    address public owner;

    constructor() {
        owner = msg.sender;
    }

    // S2 :create struct and mapping for request,transaction and name

    struct request {
        address requestor;
        uint256 amount;
        string message;
        string name;
    }

    struct sendReceive {
        string action;
        uint256 amount;
        string message;
        address otherPartyAddress;
        string otherPartyName;
    }

    struct userName {
        string name;
        bool hasName;
    }

    mapping(address => userName) names;
    mapping(address => request[]) requests;
    mapping(address => sendReceive[]) history;

    //S3 :Add a name to wallet address
    function addName(string memory _name) public {
        userName storage newUserName = names[msg.sender];
        newUserName.name = _name;
        newUserName.hasName = true;
    }

    //S4 :create a Request

    function createRequest(
        address user,
        uint256 _amount,
        string memory _message
    ) public {
        request memory newRequest;
        newRequest.requestor = msg.sender;
        newRequest.amount = _amount;
        newRequest.message = _message;
        if (names[msg.sender].hasName) {
            newRequest.name = names[msg.sender].name;
        }
        requests[user].push(newRequest);
    }

    //S5 :Pay a request

  function payRequest(uint256 _request) public payable {
    
    require(_request < requests[msg.sender].length, "No Such Request");
    request[] storage myRequests = requests[msg.sender];
    request storage payableRequest = myRequests[_request];
        
    uint256 toPay = payableRequest.amount * 1000000000000000000;
    require(msg.value == (toPay), "Pay Correct Amount");

    payable(payableRequest.requestor).transfer(msg.value);

    addHistory(msg.sender, payableRequest.requestor, payableRequest.amount, payableRequest.message);

    myRequests[_request] = myRequests[myRequests.length-1];
    myRequests.pop();

}