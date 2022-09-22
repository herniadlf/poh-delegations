//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.10;

abstract contract IDelegateRegistry {
    
    mapping (address => mapping (bytes32 => address)) public delegation;
    
    function setDelegate(bytes32 id, address delegate) external virtual;

}