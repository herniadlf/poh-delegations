//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.10;

interface IProofOfHumanity {
    
    function addSubmission(string calldata, string calldata) external;

    function isRegistered(address _submissionID) external view returns (bool);
    
    function submissionCounter() external view returns (uint);
    
}