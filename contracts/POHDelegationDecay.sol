// SPDX-License-Identifier: MIT

/**
 *  @authors: [@herniadlf]
 *  @reviewers: []
 *  @auditors: []
 *  @bounties: []
 *  @deployments: []
 *  @tools: []
 */
pragma solidity ^0.8.10;

import "./interfaces/IDelegateRegistry.sol";
import "./interfaces/IProofOfHumanity.sol";

/**
 *  @title POHDelegationDecay
 *  A proxy contract for ProofOfHumanity that implements a token interface to interact with other dapps.
 *  Note that it isn't an ERC20 and only implements its interface in order to be compatible with Snapshot.
 */
contract POHDelegationDecay {
    /* Errors */
    error MathOperationError();
    error CallerIsNotADelegator(address caller);

    /* Storage */
    IProofOfHumanity public PoH;
    IDelegateRegistry public delegateRegistry;
    uint public contractInitialTimeStamp;
    bytes32 public snapshotSpace;
    address public governor;
    string public name = "Human Vote w decay";
    string public symbol = "VOTEDECAY";
    uint8 public immutable decimals = 2;
    uint public decayCooldown; // two months
    uint public totalDecayTime; // six months
    mapping (address => uint) public delegatorTimeStamp; // the initial timestamp for each delegator. If not defined, it will be contractInitialTimeStamp   
    
    /* Events */ 
    event DelegationRenewed(address indexed delegator);

    /** @dev Constructor.
     *  @param _PoH The address of the related ProofOfHumanity contract.
     *  @param _delegateRegistry The address of the snapshot delegate registry contract.
     *  @param _snapshotSpace The specific space for snapshot voting poh.eth.
     */
    constructor(
        IProofOfHumanity _PoH, 
        IDelegateRegistry _delegateRegistry,
        bytes32 _snapshotSpace,
        uint _decayCooldown,
        uint _totalDecayTime) 
    {
        PoH = _PoH;
        delegateRegistry = _delegateRegistry;
        contractInitialTimeStamp = block.timestamp;
        governor = msg.sender;
        snapshotSpace = _snapshotSpace;
        decayCooldown = _decayCooldown;
        totalDecayTime = _totalDecayTime;
    }

    /** @dev Changes the address of the the related ProofOfHumanity contract.
     *  @param _PoH The address of the new contract.
     */
    function changePoH(IProofOfHumanity _PoH) external {
        require(msg.sender == governor, "The caller must be the governor.");
        PoH = _PoH;
    }

    /** @dev Changes the address of the the related DelegateRegistry contract.
     *  @param _newDelegateRegistry The address of the new contract.
     */
    function changeDelegateRegistry(IDelegateRegistry _newDelegateRegistry) external {
        require(msg.sender == governor, "The caller must be the governor.");
        delegateRegistry = _newDelegateRegistry;
    }
    
    /** @dev Changes the address of the the governor.
     *  @param _governor The address of the new governor.
     */
    function changeGovernor(address _governor) external {
        require(msg.sender == governor, "The caller must be the governor.");
        governor = _governor;
    }

    /** @dev Changes the snapshot space.
     *  @param _newSpace The new specific space for snapshot.
     */
    function changeSnapshotSpace(bytes32 _newSpace) external {
        require(msg.sender == governor, "The caller must be the governor.");
        snapshotSpace = _newSpace;
    }
    
    /** @dev Changes the decay cooldown.
     *  @param _newDecayCooldown The new decay cooldown.
     */
    function changeDecayCooldown(uint _newDecayCooldown) external {
        require(msg.sender == governor, "The caller must be the governor.");
        decayCooldown = _newDecayCooldown;
    }

    /** @dev Changes the total decay time.
     *  @param _newTotalDecayTime The new total decay cooldown.
     */
    function changeTotalDecayTime(uint _newTotalDecayTime) external {
        require(msg.sender == governor, "The caller must be the governor.");
        totalDecayTime = _newTotalDecayTime;
    }

    // *********************  //
    // * Proof of Humanity * //
    // *********************  //

    /** @dev Returns true if the submission is registered and not expired.
     *  @param _submissionID The address of the submission.
     *  @return Whether the submission is registered or not.
     */
    function isRegistered(address _submissionID) public view returns (bool) {
        return PoH.isRegistered(_submissionID);
    }

    // ******************** //
    // *      IERC20      * //
    // ******************** //

    /** @dev Returns the balance of a particular voter of the ProofOfHumanity contract.
     *  Note that this function takes the expiration date into account.
     *  @param _voterId The address of the voter.
     *  @return The balance of the voter.
     */
    function balanceOf(address _voterId) external view returns (uint256) {
        if (!isRegistered(_voterId)) {
            return 0;
        }
        if (_isDelegator(_voterId)) {
            return _calculateBalanceWithDecay(_voterId);
        }
        return 100;
    }

    /** @dev Returns the count of all submissions that made a registration request at some point, including those that were added manually.
     *  Note that with the current implementation of ProofOfHumanity it'd be very costly to count only the submissions that are currently registered.
     *  @return The total count of PoH submissions.
     */
    function totalSupply() external view returns (uint256) {
        return PoH.submissionCounter();
    }

    function transfer(address, uint256) external returns (bool) { return false; }

    function allowance(address, address) external view returns (uint256) {}

    function approve(address, uint256) external returns (bool) { return false; }

    function transferFrom(address, address, uint256) external returns (bool) { return false; }

     // ******************** //
    // *    Delegation    * //
    // ******************** //

    /** @dev Query the snapshot delegate registry to check if the current submission id
     *       has a delegation over the specific space. 
     *       No-specific delegations are assigned to space 0x0
     * @param _voterId The address of the voter
     * @return Wheter the submission has delegated to someone else over the specific
     *         snapshot space or the general delegation. 
     */
    function _isDelegator(address _voterId) internal view returns (bool) {
        return delegateRegistry.delegation(_voterId, snapshotSpace) != address(0) ||
            delegateRegistry.delegation(_voterId, 0x0) != address(0);
    }


    /** @dev Calculates a lineal decay since the initial timestamp delegation to the final timestamp.
     * The voting power will be voting_power = 1 - (current_timestamp - initial_timestamp)/(final_timestamp - initial_timestamp)
     * @param _voterId The address of the voter
     * @return A value between 1 to 0 with 2 decimals.
     */
    function _calculateBalanceWithDecay(address _voterId) internal view returns (uint256) {
        uint initialTime; 
        if (delegatorTimeStamp[_voterId] == 0) {
            initialTime = contractInitialTimeStamp;
        } else {
            initialTime = delegatorTimeStamp[_voterId];
        }
        uint initialTimeWithCooldownOffset = initialTime + decayCooldown;
        if (initialTimeWithCooldownOffset < initialTime) {
            revert MathOperationError();
        }
        // cooldown has not passed
        if (block.timestamp <= initialTimeWithCooldownOffset) {
            return 100;
        }
        uint finalTime = initialTimeWithCooldownOffset + totalDecayTime;
        if (finalTime < initialTimeWithCooldownOffset 
                || initialTimeWithCooldownOffset > block.timestamp
                || initialTimeWithCooldownOffset > finalTime) {
            revert MathOperationError();
        }
        if (block.timestamp > finalTime) {
            return 0;
        }
        uint dividend = 100 * (block.timestamp - initialTimeWithCooldownOffset);
        uint divider = finalTime - initialTimeWithCooldownOffset;
        return 100 - (dividend/divider);
    }

    /**
     * @dev Reset the initial timestamp for the delegation. 
     */
    function renewDelegation() external {
        if (!_isDelegator(msg.sender)) {
            revert CallerIsNotADelegator(msg.sender);
        }
        delegatorTimeStamp[msg.sender] = block.timestamp;   
        emit DelegationRenewed(msg.sender);
    }
}