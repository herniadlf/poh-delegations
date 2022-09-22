//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.10;

import "../interfaces/IDelegateRegistry.sol";

contract DelegateRegistryMock is IDelegateRegistry {
    
    function setDelegate(bytes32 id, address delegate) external override {
        delegation[msg.sender][id] = delegate;
    }

}