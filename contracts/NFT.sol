/// SPDX-License-Identifier: MIT
/// Author: kaymo.eth
pragma solidity 0.8.12;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract NFT is ERC721 {

    uint256 MAX_SUPPLY = 1000;
    uint256 totalSupply = 0;
    
    constructor() ERC721("Kek", "lolxd") {

    }

    function mint() external {
        _mint(msg.sender, totalSupply);
        totalSupply++;
    }
}