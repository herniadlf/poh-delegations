//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.10;

import "../interfaces/IProofOfHumanity.sol";

contract PoHMock is IProofOfHumanity {

    mapping(address => bool) public fakeRegistry;
    uint public registrySize;

    function addSubmission(string calldata, string calldata) external {
        fakeRegistry[msg.sender] = true;
        registrySize += 1;
    }

    function isRegistered(address _submissionID) external view returns (bool){
        return fakeRegistry[_submissionID];
    }
    
    function submissionCounter() external view returns (uint) {
        return registrySize;
    }
}