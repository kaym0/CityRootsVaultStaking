/// SPDX-License-Identifier: MIT
/// Author: kaymo.eth

pragma solidity 0.8.12;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./interface/IVault.sol";

contract VaultToken is ERC20, Ownable {

    Vault vault;

    /// By default, this is equal to 1 token per week.
    uint256 public rewardRate = 1653439153439; 

    struct Collection {
        mapping(address => uint256) rewardDebt;
    }

    mapping(address => Collection) collections;

    mapping(address => mapping(address => uint256)) rewardDebt;

    constructor(address _vault) ERC20("CityRoots Vault", "Vault") {
        vault = Vault(_vault);
    }

    error NoRewards();

    /**
     * @dev Sets the vault address. Since this is handled in the constructor, this may not ever be used.
     */
    function setVault(address _vault) external onlyOwner {
        vault = Vault(_vault);
    }

    /**
     *
     *  @dev Sets the rewards per second for each NFT within a contract.
     *  @notice It's important to note that this value is on an individual basis.
     *  example: If 100 accounts are staking NFTs for a collection, 100 tokens will be claimable per week (at the default reward rate).
     *
     *  @param amount The amount of tokens to allocate per second
     *
     */
    function setRewardRate(uint256 amount) external onlyOwner {
        rewardRate = amount;
    }

    /**
     *
     *  @dev Claims any tokens an account is entitled to.
     *  @notice Reverts if claimable amount is 0. This is to help prevent from sending redundant transactions
     *
     *  @param collection - Collection address
     *
     */

    function claim(address collection) external {
        uint256 amount = _claimable(collection, msg.sender);

        if (amount == 0) revert NoRewards();

        _mint(msg.sender, amount);
        rewardDebt[collection][msg.sender] = rewardDebt[collection][msg.sender] + amount;
    }


    /// @dev See _claimable(address collection, address owner)
    function claimable(address collection, address owner) public view returns (uint256) {
        return _claimable(collection, owner);
    }

    /**
     *
     *  @dev Gets the claimable amount by a given account
     *  @notice This returns the claimable amount, any amount already claimed is subtracted.
     *
     *  @param collection - Collection address
     *  @param owner - Account claiming
     *
     */
    function _claimable(address collection, address owner) internal view returns (uint256) {
        (uint256 multiplier, uint256 numStakedByOwner, uint256 stakeTime) = vault.getUserCollectionValues(collection, msg.sender);
        uint256 timeStaked = block.timestamp - stakeTime;
        uint256 amount = (multiplier * numStakedByOwner * rewardRate * timeStaked) / 10000;
        return amount - rewardDebt[collection][owner];
    }

    /**
     * @dev See: Vault.getUserCollectionValues
     */
    function _getCollectionValues(address collection, address account) internal view returns (uint256, uint256, uint256) {
        return vault.getUserCollectionValues(collection, account);
    }
}