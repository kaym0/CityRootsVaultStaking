/// SPDX-License-Identifier: MIT
/// author: kaymo.eth

pragma solidity 0.8.12;

interface Vault {
    function timeStaked (address collection, address account) external view returns (uint256);
    function timeStakedTest (address collection, address account) external view returns (uint256);
    function getUserCollectionValues(address collection, address account) external view returns (uint256, uint256, uint256);
}