// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.8.0;

import "./DudleToken.sol";

contract AddNewOwner is DudleToken {
    struct Pool {
        mapping(address => bool) voter;
        uint256 voterNumber;
    }
    
    mapping(address => Pool) pools;
    
    function vote (address _addr) public onlyOwner {
        require(!ownership[_addr] && !pools[_addr].voter[msg.sender], "this address already voted");
        pools[_addr].voterNumber++;
        pools[_addr].voter[msg.sender] = true;
        if (pools[_addr].voterNumber > owners.length / 2) {
            owners.push(_addr);
            ownership[_addr] = true;
            pools[_addr].voterNumber = 0;
            for (uint256 i = 0; i < owners.length; i++) {
                delete pools[_addr].voter[owners[i]];
            }
        }
    }
}