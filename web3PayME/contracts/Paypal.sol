// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract PaymentGateway {
    address public owner;

    struct Request {
        address requester;
        address token;
        uint256 amount;
        string message;
    }

    struct SendReceive {
        string action;
        address token;
        uint256 amount;
        string message;
        address otherPartyAddress;
    }

    mapping(address => Request[]) public requests;
    mapping(address => SendReceive[]) public history;

    modifier onlyOwner() {
        require(msg.sender == owner, "This function can be only called by the owner!");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function createRequest(address _token, uint256 _amount, string memory _message) public {
        require(IERC20(_token).transferFrom(msg.sender, address(this), _amount), "Token transfer failed");
        Request memory newRequest;
        newRequest.requester = msg.sender;
        newRequest.token = _token;
        newRequest.amount = _amount;
        newRequest.message = _message;

        requests[msg.sender].push(newRequest);
    }

    function payRequest(uint256 _requestIndex) public {
        require(_requestIndex < requests[msg.sender].length, "No Such Request");
        Request storage payableRequest = requests[msg.sender][_requestIndex];

        require(IERC20(payableRequest.token).transfer(msg.sender, payableRequest.amount), "Token transfer failed");
        addHistory(msg.sender, payableRequest.token, msg.sender, payableRequest.amount, payableRequest.message);

        // Remove the request after payment
        requests[msg.sender][_requestIndex] = requests[msg.sender][requests[msg.sender].length - 1];
        requests[msg.sender].pop();
    }

    function addHistory(address sender, address token, address receiver, uint256 _amount, string memory _message) private {
        SendReceive memory newSend;
        newSend.action = "Send";
        newSend.token = token;
        newSend.amount = _amount;
        newSend.message = _message;
        newSend.otherPartyAddress = receiver;
        history[sender].push(newSend);

        SendReceive memory newReceive;
        newReceive.action = "Receive";
        newReceive.token = token;
        newReceive.amount = _amount;
        newReceive.message = _message;
        newReceive.otherPartyAddress = sender;
        history[receiver].push(newReceive);
    }

    function getMyRequests() public view returns (Request[] memory) {
        return requests[msg.sender];
    }

    function getMyHistory() public view returns (SendReceive[] memory) {
        return history[msg.sender];
    }
}
