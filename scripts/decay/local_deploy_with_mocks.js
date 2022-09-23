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
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    })