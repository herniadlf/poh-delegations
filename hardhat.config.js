require("@nomiclabs/hardhat-waffle")
require("@nomiclabs/hardhat-etherscan")
require("hardhat-deploy")
require("solidity-coverage")
require("hardhat-gas-reporter")
require("hardhat-contract-sizer")
require("dotenv").config()

/**
 * @type import('hardhat/config').HardhatUserConfig
 */

const MAINNET_RPC_URL =
    process.env.MAINNET_RPC_URL ||
    process.env.ALCHEMY_MAINNET_RPC_URL ||
    "https://eth-mainnet.alchemyapi.io/v2/<your_key>"

module.exports = {
    defaultNetwork: "hardhat",
    networks: {
        hardhat: {
            // // If you want to do some forking, uncomment this
            // forking: {
            //   url: MAINNET_RPC_URL,
            //   blockNumber: 15480189
            // },
            chainId: 31337
        },
        localhost: {
            chainId: 31337,
        }
    },
    contractSizer: {
        runOnCompile: false,
        only: ["Raffle"],
    },
    solidity: {
        compilers: [
            {
                version: "0.8.10",
            },
            {
                version: "0.7.0"
            },
            {
                version: "0.8.0"
            }
        ],
    },
    mocha: {
        timeout: 500000, // 500 seconds max for running tests
    },
}