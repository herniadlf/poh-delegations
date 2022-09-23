const decayCooldown = 5184000; // two months
const fourMonths = 10368000;
const sixMonths = 15552000;

async function main() {
    let contractFactory = await ethers.getContractFactory('DelegateRegistryMock');
    const delegationRegistry = await contractFactory.deploy();
    await delegationRegistry.deployed();

    contractFactory = await ethers.getContractFactory('PoHMock');
    const pohMock = await contractFactory.deploy();
    await pohMock.deployed();
    
    contractFactory = await ethers.getContractFactory('POHDelegationDecay');
    const delegationDecay = await contractFactory.deploy(
        pohMock.address, 
        delegationRegistry.address,
        '0x706f682e65746800000000000000000000000000000000000000000000000000',
        5184000,
        15552000
    );
    await delegationDecay.deployed();

    console.log('POHDelegationDecay Contract address ' + delegationDecay.address);

    const accounts = await ethers.getSigners();
    const provider = ethers.provider;
    const userOne = accounts[1];
    const userTwo = accounts[2];

    await pohMock.connect(userOne).addSubmission('some', 'thing');
    await pohMock.connect(userTwo).addSubmission('some', 'thing');
    await delegationRegistry.connect(userOne).setDelegate(ethers.constants.HashZero, userTwo.address);
    await provider.send("evm_increaseTime", [decayCooldown + sixMonths]);
    await provider.send("evm_mine");

    await delegationDecay.connect(userOne).renewDelegation();
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    })