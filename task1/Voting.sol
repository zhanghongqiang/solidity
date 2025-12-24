// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Voting{
    mapping(string => uint256) public votes;
    string [] public candidateList;
    mapping(address => bool) public hasVoted;

    constructor(string[] memory candidates){
        for(uint256 i = 0;i<candidateList.length;i++){
            candidateList.push(candidates[i]);
            votes[candidates[i]] = 0;
        }
    }

    function vote(string memory candidate) public {
        require(!hasVoted[msg.sender],"have already voted");
        hasVoted[msg.sender] = true;
        votes[candidate]++;
    } 

    function getVotes(string memory candidate) public view returns(uint256){
        return votes[candidate];
    }

    function resetVotes() public {
        for(uint256 i = 0 ; i < candidateList.length;i++){
            votes[candidateList[i]] = 0;
        }
    }
}