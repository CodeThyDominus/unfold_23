// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

contract Paypal{

    address public owner;

    constructor(){
        owner = msg sender;
    }

    struct request{
        address requester;
        uint256 ampunt;
        string message;
        string name;
    }

    struct sendReceive{
        string action;
        uint256 amount;
        string message;
        address otherPartyAddress;
        string otherPartyName;
    }

    struct userName{
        string name;
    }

    // mapping for request, transaction and userName
    mapping(address => userName) names;
    mapping(address => request[]) requests;
    mapping(address => sendReceive[]) history;

    //adding name to wallet
    function addName(string memory) public{
        userName storage newUserName = names[msg.sender];
        newUserName = _name;
    }

    //creating request
    function createRequest(address user, uint256 _amount, string memory _message) public{
        request memory newRequest;
        newRequest.requester = msg.sender;
        newRequest.amount = _amount;
        newRequest.message = _message;
        requests[user].push(newRequest);
    }

    //payment for request
    function payRequest(uint256 _request) public payable{
        require(_request < requests[msg.sender].length, "No Such Rewuest Found!");
        request storage payableRequest = myRequests[_request];
        
    uint256 toPay = payableRequest.amount * 1000000000000000000;
    require(msg.value == (toPay), "Pay Correct Amount");

    payable(payableRequest.requester).transfer(msg.value);

    addHistory(msg.sender, payableRequest.requester, payableRequest.amount, payableRequest.message);

    myRequests[_request] = myRequests[myRequests.length-1];
    myRequests.pop();
    }
    
    //sending request to user
    function getMyRequests(address _user) public view returns(
         address[] memory, 
         uint256[] memory, 
         string[] memory, 
         string[] memory
){

        address[] memory addrs = new address[](requests[_user].length);
        uint256[] memory amnt = new uint256[](requests[_user].length);
        string[] memory msge = new string[](requests[_user].length);
        string[] memory nme = new string[](requests[_user].length);
        
        for (uint i = 0; i < requests[_user].length; i++) {
            request storage myRequests = requests[_user][i];
            addrs[i] = myRequests.requestr;
            amnt[i] = myRequests.amount;
            msge[i] = myRequests.message;
            nme[i] = myRequests.name;
        }
        
        return (addrs, amnt, msge, nme);        
         

}
    

}
