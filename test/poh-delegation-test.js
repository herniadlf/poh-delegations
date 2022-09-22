const { expect } = require('chai');
const { ethers } = require('hardhat');

describe('PoH Delegation Contract', function() {

    const snapshotSpace = '0x706f682e65746800000000000000000000000000000000000000000000000000';
    const decayCooldown = 7776000;
    const fourMonths = 10368000;
    const sixMonths = 15552000;
    let contractFactory, provider, pohDelegation, delegationRegistry, pohMock, deployer, userOne, userTwo, userThree;

    beforeEach(async function() {
        contractFactory = await ethers.getContractFactory('DelegateRegistryMock');
        delegationRegistry = await contractFactory.deploy();
        await delegationRegistry.deployed();

        contractFactory = await ethers.getContractFactory('PoHMock');
        pohMock = await contractFactory.deploy();
        await pohMock.deployed();
        
        contractFactory = await ethers.getContractFactory('ProofOfHumanityDelegation');
        pohDelegation = await contractFactory.deploy(pohMock.address, 
            delegationRegistry.address,
            snapshotSpace,
            decayCooldown);
        await pohDelegation.deployed();

        accounts = await ethers.getSigners();
        provider = ethers.provider;
        deployer = accounts[0];
        userOne = accounts[1];
        userTwo = accounts[2];
        userThree = accounts[4];
    });

    describe('Non delegated voting power', function() {
        it('should have balance 0 because the address is not registered in poh', async function() {
            const balanceOf = await pohDelegation.balanceOf(userOne.address);
            await expect(balanceOf).to.be.eq(0);
        });

        it('should have balance 1 because the address is registered in poh', async function() {
            await pohMock.connect(userOne).addSubmission('some', 'thing');
            const balanceOf = await pohDelegation.balanceOf(userOne.address);
            await expect(balanceOf).to.be.eq(1);
        });

        it('should have balance 1 during time (4 months)', async function() {
            await pohMock.connect(userOne).addSubmission('some', 'thing');
            await provider.send("evm_increaseTime", [fourMonths]);
            await provider.send("evm_mine");
            
            const balanceOf = await pohDelegation.balanceOf(userOne.address);
            await expect(balanceOf).to.be.eq(1);
        });

    });

    describe('Delegated voting power', function() {

        beforeEach(async function() {
            await pohMock.connect(userOne).addSubmission('some', 'thing');
            await pohMock.connect(userTwo).addSubmission('some', 'thing');
        });
        
        it('both should have balance 1 because the addresses are registered in poh', async function() {
            await delegationRegistry.connect(userOne).setDelegate(ethers.constants.HashZero, userTwo.address);
            await expect(await pohDelegation.balanceOf(userOne.address)).to.be.eq(1);
            await expect(await pohDelegation.balanceOf(userTwo.address)).to.be.eq(1);
        });

        it('should have balance 0 because the delegator addresses is not registered in poh', async function() {
            await delegationRegistry.connect(userThree).setDelegate(ethers.constants.HashZero, userTwo.address);
            await expect(await pohDelegation.balanceOf(userThree.address)).to.be.eq(0);
            await expect(await pohDelegation.balanceOf(userTwo.address)).to.be.eq(1);
        });

        it('the delegator balance should decay to 0 without renovation', async function() {
            await delegationRegistry.connect(userOne).setDelegate(ethers.constants.HashZero, userTwo.address);
            await provider.send("evm_increaseTime", [decayCooldown + sixMonths]);
            await provider.send("evm_mine");
            await expect(await pohDelegation.balanceOf(userOne.address)).to.be.eq(0);
            await expect(await pohDelegation.balanceOf(userTwo.address)).to.be.eq(1);
        });

        it('the delegator balance should return to 1 if renowal is called', async function() {
            await delegationRegistry.connect(userOne).setDelegate(ethers.constants.HashZero, userTwo.address);
            await provider.send("evm_increaseTime", [decayCooldown + sixMonths]);
            await provider.send("evm_mine");
            await expect(await pohDelegation.balanceOf(userOne.address)).to.be.eq(0);
        });

    });

});
