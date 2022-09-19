const { expect } = require('chai');
const { ethers } = require('hardhat');

describe.skip('PoH Delegation Contract', function() {

    let contractFactory, ethersProvider, delegationRegistry, pohMock, deployer, userOne, userTwo, userThree;

    beforeEach(async function() {
        contractFactory = await ethers.getContractFactory('DelegateRegistry');
        delegationRegistry = await contractFactory.deploy();
        await delegationRegistry.deployed();

        contractFactory = await ethers.getContractFactory('PoHMock');
        pohMock = await contractFactory.deploy();
        await pohMock.deployed();

        accounts = await ethers.getSigners();
        ethersProvider = ethers.provider;
        deployer = accounts[0];
        userOne = accounts[1];
        userTwo = accounts[2];
        userThree = accounts[4];
    });

    describe('Deployment', function() {
        it('should fail for invalid address', async function() {
            const deployTx = contractFactory.deploy(ethers.constants.AddressZero);
            await expect(deployTx).to.be.revertedWith(ERRORS.INIT_PARAMS_INVALID);
        });

        it('should work for a valid address', async function() {
            const deployTx = await contractFactory.deploy(userOne.getAddress());
    
            expect(deployTx.deployed()).to.not.be.reverted;
        });
    });

});
