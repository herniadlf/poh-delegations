# Proof of Humanity voting delegations

Some research about an ERC-20 implementations to handle some votation strategies for Proof Of Humanity DAO.

## POHDelegationDecay.sol

It checks if an address has a delegation in snapshot to calculate the balance between 0 to 1. Important attributes:

- `decayCooldown` is the time during which the delegated voting power continues to be 1.
- After `decayCooldown` pass, `totalDecayTime` is the time during which the delegated voting power will falls in linear way up to 0.
- `contractInitialTimeStamp` is the starting line for every delegation. From the moment the contract is deployed, we set this attribute with the current block timestamp.

Examples:

I deploy the contract on "January 1st" with decayCooldown of two months and totalDecayTime of six months. contractInitialTimeStamp will be set to "January 1st". 

- 1 month after deploy: the delegation voting power will be 1.
- 2 months after deploy: the delegation voting power will be 1, but it will start to fall in linear way up to 0.
- 5 months after deploy: the delegation voting power will be 0.5.
- 8 months after deploy: the delegation voting power will be 0.

If a delegator wants to recover his delegation voting power, a renewal needs to be invoked with `renewDelegation` method. It will reset the initialTimeStamp for that specific delegation.

