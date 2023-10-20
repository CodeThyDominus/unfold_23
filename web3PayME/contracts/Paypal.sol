// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

contract Paypal {

    address public owner;

    struct Request { 
        address requester;
        uint256 amount;
        string message;
    }

    struct SendReceive {
        string action;
        uint256 amount;
        string message;
        address otherPartyAddress;
    }

    struct UserName { 
        string name;
        bool hasName;
    }

    // mapping for request, transaction, and userName
    mapping(address => UserName) public names;
    mapping(address => Request[]) public requests; 
    mapping(address => SendReceive[]) public history; 

    modifier onlyOwner() {
        require(msg.sender == owner, "This function can be only called by Owner!");
        _;
    }

    constructor() {
        owner = msg.sender; 
    }

    // Adding name to wallet
    function addName(string memory _name) public {
        names[msg.sender] = UserName(_name, true);
    }

    // Creating request
    function createRequest(uint256 _amount, string memory _message) public {
        Request memory newRequest;
        newRequest.requester = msg.sender;
        newRequest.amount = _amount;
        newRequest.message = _message;
        
        if (names[msg.sender].hasName) {
            newRequest.message = names[msg.sender].name;
        }

        requests[msg.sender].push(newRequest);
    }

    // Payment for request
    function payRequest(uint256 _request) public payable {
        require(_request < requests[msg.sender].length, "No Such Request");
        Request[] storage myRequests = requests[msg.sender];
        Request storage payableRequest = myRequests[_request];
        uint256 toPay = payableRequest.amount * 1 ether;
        require(msg.value == toPay, "Pay Correct Amount");
        payable(payableRequest.requester).transfer(msg.value);
        addHistory(msg.sender, payableRequest.requester, payableRequest.amount, payableRequest.message);
        myRequests[_request] = myRequests[myRequests.length - 1];
        myRequests.pop();
    }

    // saving history
    function addHistory(address sender, address receiver, uint256 _amount, string memory _message) private {
        SendReceive memory newSend;
        newSend.action = "Send";
        newSend.amount = _amount;
        newSend.message = _message;
        newSend.otherPartyAddress = receiver;
        history[sender].push(newSend);

        SendReceive memory newReceive;
        newReceive.action = "Receive";
        newReceive.amount = _amount;
        newReceive.message = _message;
        newReceive.otherPartyAddress = sender;
        history[receiver].push(newReceive);
    }

    // Sending request to user
    function getMyRequests() public view returns (Request[] memory) {
        return requests[msg.sender];
    }

    // viewing saved hostory
    function getMyHistory() public view returns (SendReceive[] memory) {
        return history[msg.sender];
    }

    //retrieve username associated with address
    function getMyName() public view returns (UserName memory) {
        return names[msg.sender];
    }

    // to change owner of contract
    function setOwner(address newOwner) public onlyOwner {
        owner = newOwner;
    }  
    
}
