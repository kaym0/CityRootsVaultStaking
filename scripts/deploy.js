async function main() {
    const [deployer] = await ethers.getSigners();

    console.log("Deploying contracts with the account:", deployer.address);

    console.log("Account balance:", (await deployer.getBalance()).toString());

    const Staking = await ethers.getContractFactory("TheVaultStaking");
    const VaultToken = await ethers.getContractFactory("VaultToken");
    //const NFT = await ethers.getContractFactory("NFT");
    //const nft = await NFT.deploy();
    //console.log(getDeploymentCost(nft));

    const staking = await Staking.deploy();
    const token = await VaultToken.deploy(staking.address);

    console.log("Staking deployed to:", staking.address);
    console.log("VaultToken deployed to:", token.address);
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });

const getDeploymentCost = (deployment) => {
    const gasLimit = deployment.deployTransaction.gasLimit;
    const gasPrice = deployment.deployTransaction.gasPrice;
    const deployCost = ethers.utils.formatUnits(gasLimit.mul(gasPrice).toString(), "18");

    return "Deploy cost: ", `${deployCost} ETHER`;
};
