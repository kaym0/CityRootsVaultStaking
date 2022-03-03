const { ethers } = require("ethers");
const { MerkleTree } = require("merkletreejs");
const keccak256 = require("keccak256");

const abi = ethers.utils.defaultAbiCoder;

const generateTestList = (accounts) => {
    accounts.pop(0);
    const list = [];
    accounts.forEach((account) => {
        list.push({
            account: account,
            startAmount: ethers.utils.parseUnits("100", "18").toString(),
        });
    });

    return list;
};

const getMerkleRoot = (testList) => {
    try {
        const leafNodes = testList.map((item) =>
            ethers.utils.hexStripZeros(
                abi.encode(["address", "uint256"], [item.account, item.startAmount])
            )
        );
        const merkleTree = new MerkleTree(leafNodes, keccak256, {
            hashLeaves: true,
            sortPairs: true,
        });
        const root = merkleTree.getHexRoot();
        return {
            root,
        };
    } catch (error) {
        console.log("Account does not exist");
    }
};

const getMerkleData = (account, startAmount, testList) => {
    try {
        const accountData = testList.find((o) => o.account == account);
        const leafNodes = testList.map((item) =>
            ethers.utils.hexStripZeros(
                abi.encode(["address", "uint256"], [item.account, item.startAmount])
            )
        );
        const merkleTree = new MerkleTree(leafNodes, keccak256, {
            hashLeaves: true,
            sortPairs: true,
        });
        const root = merkleTree.getHexRoot();
        const leaf = keccak256(
            ethers.utils.hexStripZeros(abi.encode(["address", "uint256"], [account, startAmount]))
        );
        const proof = merkleTree.getHexProof(leaf);

        return {
            root,
            leaf,
            proof,
        };
    } catch (error) {
        console.log("Account does not exist");
    }
};

const advanceTime = (time, ethers) => {
    return new Promise(async (resolve, reject) => {
        await ethers.provider.send(
            "evm_increaseTime",
            [time] //id: new Date().getTime(),),
        );
        resolve();
    });
};

const advanceTimeAndBlock = async (time, ethers) => {
    await advanceTime(time, ethers);
    await advanceBlock(ethers);
    //return Promise.resolve(ethers.provider.getBlock("latest"));
};

const advanceBlock = (ethers) => {
    return new Promise(async (resolve, reject) => {
        await ethers.provider.send("evm_mine");
        resolve();
    });
};

module.exports = {
    getMerkleRoot: getMerkleRoot,
    generateTestList: generateTestList,
    getMerkleData: getMerkleData,
    advanceTime: advanceTime,
    advanceTimeAndBlock: advanceTimeAndBlock,
};
