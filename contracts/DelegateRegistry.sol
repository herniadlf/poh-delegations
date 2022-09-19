// SPDX-License-Identifier: LGPL-3.0-only

pragma solidity ^0.8.10;

contract DelegateRegistry {
    mapping (address => mapping (bytes32 => address)) public delegation;
}