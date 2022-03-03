require("@nomiclabs/hardhat-waffle");
require("dotenv").config();
require("hardhat-gas-reporter");
require("@nomiclabs/hardhat-etherscan");
require("@nomiclabs/hardhat-ganache");
require('dotenv').config();
// This is a sample Hardhat task. To learn how to create your own go to
// https://hardhat.org/guides/create-task.html

const key = process.env.PRIVATE_KEY;
const coinmarketcap_key = process.env.COINMARKETCAP_KEY;
const gasPriceAPI = `https://api.etherscan.io/api?module=proxy&action=eth_gasPrice&apikey=${process.env.GASPRICE_API_KEY}`;
const rpc_mainnet = process.env.MAINNET;
const rpc_rinkeby = process.env.RINKEBY;
const etherscan_key = process.env.ETHERSCAN_API_KEY;

console.log(rpc_rinkeby);

task("accounts", "Prints the list of accounts", async (taskArgs, hre) => {
    const accounts = await hre.ethers.getSigners();

    for (const account of accounts) {
        console.log(account.address);
    }
});

// You need to export an object to set up your config
// Go to https://hardhat.org/config/ to learn more

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
    solidity: {
        version: "0.8.12",
        settings: {
            optimizer: {
                enabled: true,
                runs: 1,
            },
        },
    },
    gasReporter: {
        currency: "USD",
        token: "ETH",
        //gasPrice: 86,
        gasPriceApi: gasPriceAPI,
        coinmarketcap: coinmarketcap_key,
    },
    etherscan: {
        apiKey: {
            mainnet: etherscan_key,
            rinkeby: etherscan_key,
        },
    },

    networks: {
        hardhat: {
            gasPrice: 100000000000,
            maxFeePerGas: 100000000000,
        },
        localhost: {
            gasPrice: 100000000000,
            maxFeePerGas: 100000000000,
        },
        rinkeby: {
            url: rpc_rinkeby,
            accounts: [key],
        },
        mainnet: {
            url: rpc_mainnet,
            accounts: [key],
        },
    },
};
