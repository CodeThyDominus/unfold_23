// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

contract Paypal {

    address public owner;

    constructor() {
        owner = msg.sender; // Corrected msg.sender assignment
    }

    struct Request { // Corrected struct name to start with an uppercase letter
        address requester;
        uint256 amount;
        string message;
        string name;
    }

    struct SendReceive { // Corrected struct name to start with an uppercase letter
        string action;
        uint256 amount;
        string message;
        address otherPartyAddress;
        string otherPartyName;
    }

    struct UserName { // Corrected struct name to start with an uppercase letter
        string name;
        bool hasName;
    }

    // mapping for request, transaction, and userName
    mapping(address => UserName) public names;
    mapping(address => Request[]) public requests; // Added "public" to make it accessible
    mapping(address => SendReceive[]) public history; // Added "public" to make it accessible

    // Adding name to wallet
    function addName(string memory _name) public {
        UserName storage newUserName = names[msg.sender];
        newUserName.name = _name; // Corrected the assignment of name
        newUserName.hasName = true;
    }

    // Creating request
    function createRequest(address user, uint256 _amount, string memory _message) public {
        Request memory newRequest;
        newRequest.requester = msg.sender;
        newRequest.amount = _amount;
        newRequest.message = _message;

        // Checking the association between username and address
        if (names[msg.sender].hasName) {
            newRequest.name = names[msg.sender].name;
        }

        requests[user].push(newRequest);
    }

    // Payment for request
    function payRequest(uint256 _request) public payable {
        require(_request < requests[msg.sender].length, "No Such Request Found!");
        Request storage payableRequest = requests[msg.sender][_request]; // Corrected variable name

        uint256 toPay = payableRequest.amount * 1 ether; // Corrected the conversion
        require(msg.value == toPay, "Pay Correct Amount");

        payable(payableRequest.requester).transfer(msg.value);

        requests[msg.sender][_request] = requests[msg.sender][requests[msg.sender].length - 1]; // Corrected variable names
        requests[msg.sender].pop();
    }

    // Sending request to user
    function getMyRequests(address _user) public view returns(
        address[] memory, 
        uint256[] memory, 
        string[] memory, 
        string[] memory) {

        address[] memory addrs = new address[](requests[_user].length);
        uint256[] memory amnt = new uint256[](requests[_user].length);
        string[] memory msge = new string[](requests[_user].length);
        string[] memory nme = new string[](requests[_user].length);

        for (uint i = 0; i < requests[_user].length; i++) {
            Request storage myRequest = requests[_user][i]; // Corrected variable name
            addrs[i] = myRequest.requester;
            amnt[i] = myRequest.amount;
            msge[i] = myRequest.message;
            nme[i] = myRequest.name;
        }

        return (addrs, amnt, msge, nme);
    }   
}
