// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity >=0.7.0 <0.8.0;

contract DelegateRegistry {
    mapping (address => mapping (bytes32 => address)) public delegation;
}