const { expect } = require("chai");
const { ethers } = require("hardhat");
const truffleAssert = require("truffle-assertions");
const { advanceTimeAndBlock } = require("./functions");
const numeral = require("numeral");
const { assert } = require("console");
const { fn } = require("numeral");

const toWei = (amount) => {
    return ethers.utils.parseUnits(amount, "18");
};

const fromWei = (amount) => {
    return ethers.utils.formatUnits(amount, "18");
}

const getOneWeekAmount = () => {
    const a = ethers.utils.parseUnits("1", "18");

    return a.div("7").div("86400");
}

const testAmount = () => {
    const a  = ethers.BigNumber.from("1653439153439");

    return a.mul("86400").mul("7").mul(4);
}

console.log(getOneWeekAmount());
console.log(testAmount());

describe("FullFeature", async () => {
    let stake;
    let token;
    let nft;
    let accounts;

    const advanceOneWeek = async (account, Fn) => {
        const oneWeek = 604800;
        await advanceTimeAndBlock(oneWeek, ethers);
        const amount = await Fn;
        return amount;
    };

    before(async () => {
        const FullFeature = await ethers.getContractFactory("FullFeature");
        const NFT = await ethers.getContractFactory("NFT");
        const Token = await ethers.getContractFactory("VaultToken");
        stake = await FullFeature.deploy();
        nft = await NFT.deploy();
        token = await Token.deploy(stake.address);
        [...accounts] = await ethers.getSigners();
        //await stake.deployed();
        //await nft.deployed();
        //await token.deployed();
        accounts = accounts.map((account) => account.address);
    });

    describe("mints a few nfts", async () => {
        it("mints a few nfts", async () => {
            await nft.mint();
            await nft.mint();
            await nft.mint();
            await nft.mint();
            await nft.mint();
            await nft.mint();
            await nft.mint();
        });
    });

    describe("createCollection", async () => {
        it("Creates a collection", async () => {
            await stake.createCollection(nft.address);
        });

        it("Fails to create a collection which already exists", async () => {
            await truffleAssert.fails(stake.createCollection(nft.address));
        });
    });

    describe("stake", async () => {
        it("successfuly stakes", async () => {
            await nft.approve(stake.address, "0");
            await stake.stake(nft.address, "0", {
                from: accounts[0],
            });
        });

        it("successfuly stakes", async () => {
            await nft.approve(stake.address, "1");
            await stake.stake(nft.address, "1", {
                from: accounts[0],
            });
        });
    });

    describe("VaultToken.claimable()", async () => {
        it("Successfully gets claimable amount", async () => {
            const amount = await advanceOneWeek(accounts[0], token.claimable(nft.address, accounts[0]));
            //const amount = await token.claimable(nft.address, accounts[0]);
            expect(amount).to.equal(ethers.BigNumber.from("1999999999999814400"));
        });
    });

    describe("VaultToken.claim()", async () => {
        it("Claims tokens for staking", async () => {
            const preBalance = await token.balanceOf(accounts[0]);

            await advanceOneWeek(accounts[0], token.claim(nft.address, {
                from: accounts[0]
            }));

            const balance = await token.balanceOf(accounts[0]);

            expect(balance.sub(preBalance)).to.equal(ethers.BigNumber.from("3999999999999628800"));
        });
    });

    describe("timeStaked", async () => {
        it("returns the amount of time the user is staked", async () => {
            await stake.timeStaked(nft.address, accounts[0]);
        });
    });

    describe("withdraw", async () => {
        it("successfully withdraws", async () => {
            await stake.withdraw(nft.address, "0", {
                from: accounts[0],
            });
        });
    });

    describe("collections", async () => {
        it("fetches collection which exists", async () => {
            const c = await stake.collections(nft.address);
        });

        it("fetches collection which doesn't exist", async () => {
            const c = await stake.collections(accounts[0]);
        });
    });

    describe("setCollectionMultiplier", async () => {
        it("successfully sets multipler as owner", async () => {
            await stake.setCollectionMultiplier(nft.address, "20000");
        });

        it("fails as non-owner", async () => {
            await truffleAssert.fails(
                stake.setCollectionMultiplier(nft.address, "20000", {
                    from: accounts[9],
                })
            );
        });
    });
});
