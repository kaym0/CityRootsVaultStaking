/// SPDX-License-Identifier: MIT
/// Author: kaymo.eth
pragma solidity 0.8.12;

import "./token/utils/ERC721Holder.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract TheVaultStaking is ERC721Holder, Ownable {
    using SafeMath for uint256;
    uint256 public totalSupply = 0;

    mapping (address => Collection) public collections;

    struct Collection {
        address id;
        bool verified;
        uint256 multiplier;
        uint256 numStaked;
        mapping(uint256 => address) tokenOwner;
        mapping(address => uint256) timeStaked;
        mapping(address => uint256) numStakedByOwner;
    }

    constructor() {}


    /// Custom error handling. This saves gas.
    error NotOwner();
    error MustClaim();
    error NegativeMulti();
    error AlreadyExists();


    /**
     *
     * @dev Utility function for the VaultToken contract
     * @return Collection multiplier, along with the amount staked and timeStaked for an individual account.
     *
     */
    function getUserCollectionValues(address _collection, address account) 
        external view returns (uint256, uint256, uint256) {
            Collection storage collection = collections[_collection];
            return (
                collection.multiplier, 
                collection.numStakedByOwner[account],
                collection.timeStaked[account]
            );
    }

    /// @notice Returns the amount of time a given NFT has been staked within this contract
    function timeStaked (address _collection, address account) public view returns (uint256) {
        Collection storage collection = collections[_collection];
        return block.timestamp.sub(collection.timeStaked[account]);
    }

    /// @notice Returns the number of NFTs staked by a given an account for a given collection
    function numStakedByCollection (address _collection, address account) public view returns (uint256) {
        return collections[_collection].numStakedByOwner[account];
    }

    /// @notice Returns the length of time the user has been staking a collection, along with the amount of NFTs staked.
    function timeAndNumberStaked(address _collection, address account) public view returns (uint256, uint256){
        Collection storage collection = collections[_collection];
        uint256 time = block.timestamp.sub(collection.timeStaked[account]);
        uint256 number = collection.numStakedByOwner[account];
        return (time, number);
    }

    /// @notice Returns the amount of NFTs staked for a given collection
    function balanceOfByCollection (address collection) public view returns (uint256) {
        return IERC721(collection).balanceOf(address(this));
    }

    /// @notice Returns true if the collection is verified.
    function collectionVerified(address collection) public view returns (bool) {
        return collections[collection].verified;
    }

    /**
     *
     * @dev Creates a reference to a collection
     * @notice
     * - Creates a collection with default values.
     * - Multiplier at 10000 is equivilant to 1.
     * - By default, collections are not verified.
     *
     * @param _collection - The collection address
     *
     */
    
    function createCollection (address _collection) public {
        Collection storage collection = collections[_collection];
        if (collection.id == _collection) revert AlreadyExists();
        collection.id = _collection;
        collection.verified = false;
        collection.multiplier = 10000;
        collection.numStaked = 0;
        //collections[collection] = Collection(collection, false, 10000, 0, collections[collection]);
    }

    /**
     *
     *  @dev Sets the collection multiplier
     *  @notice 
     * - This cannot be less than 10000.
     * - 10000 is equal to 1x, 20000 is equal to 2x
     *  
     *  @param _collection - The collection address
     *  @param multiplier - The collection token multiplier
     *
     */
    function setCollectionMultiplier (address _collection, uint256 multiplier) external onlyOwner {
        if (multiplier < 10000) revert NegativeMulti();
        Collection storage collection = collections[_collection];
        collection.multiplier = multiplier;
    }

    /**
     *
     *  @dev Sets collection verified status.
     *
     *  @param _collection - Collection address
     *  @param verified - True if the collection is verified
     *
     */
    function setCollectionVerified (address _collection, bool verified) external onlyOwner {
        Collection storage collection = collections[_collection];
        collection.verified = verified;
    }

    /**
     *
     *  @dev Sets both the multiplier and verified for a collection
     *
     *  @param _collection - the NFT collection address
     *  @param multiplier - The token multiplier for staking NFTs from this collection
     *  @param verified - True if the collection is verified by CityRoots
     *
     */
    function setCollectionValues(address _collection, uint256 multiplier, bool verified) external onlyOwner {
        if (multiplier < 10000) revert NegativeMulti();
        Collection storage collection = collections[_collection];
        collection.verified = verified;
        collection.multiplier = multiplier;
    }

    /**
     *
     *  @dev Creates a collection if the collection does not already exist.
     *  @notice
     *  - Transfer NFT to this contract
     *  - Adds data to mapping to associate with the NFT
     *  - Increases the users total staked amount
     *
     *  @param _collection - The collection address of the NFT to be staked
     *  @param tokenId - The tokenId of the NFT to be staked
     *
     */
    function stake(address _collection, uint256 tokenId) external {
        Collection storage collection = collections[_collection];
        if (collection.id != _collection) {
           createCollection(_collection);
        }

        IERC721(_collection).transferFrom(msg.sender, address(this), tokenId);
        
        collection.numStaked = collection.numStaked.add(1);
        collection.numStakedByOwner[msg.sender] = collection.numStakedByOwner[msg.sender] + 1;
        collection.timeStaked[msg.sender] = block.timestamp;
        collection.tokenOwner[tokenId] = msg.sender;
        totalSupply = totalSupply.add(1);
    }

    /**
     *
     *  @dev Withdraws staked NFT from this contract to the original owner.
     *  @notice 
     *  - Transfer NFT to original owner
     *  - Adjusts staked amount values for both the user and collection
     *  - Deletes the entry, this refunds some gas.
     *
     *  @param _collection - The collection address of the NFT to be staked
     *  @param tokenId - The tokenId of the NFT to be staked
     *
     */
    function withdraw(address _collection, uint256 tokenId) external {
        Collection storage collection = collections[_collection];
        if (collection.tokenOwner[tokenId] != msg.sender) revert NotOwner();
        IERC721(_collection).transferFrom(address(this), msg.sender, tokenId);
        collection.numStakedByOwner[msg.sender] = collection.numStakedByOwner[msg.sender] - 1;
        collection.numStaked = collection.numStaked - 1;
        delete collection.tokenOwner[tokenId];
        totalSupply = totalSupply - 1;
    }
}
