// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract BeggingContract is Ownable{

    mapping(address => uint256) public donations;

    uint256 public immutable donationEndtime;

    uint256 public totalDonations;

    struct TopDonor{
        address donor;
        uint256 amount;
    }

    TopDonor[3] public topDonors;

    event Donation(address indexed donor,uint256 amount);

    event Withdrawal(address indexed owner,uint256 amount);

    constructor(uint256 _donationEndtime) Ownable(msg.sender){
        donationEndtime = block.timestamp + (_donationEndtime * 1 hours);
    }

    function donate() external payable {
        require(block.timestamp < donationEndtime,"Donation period has ended");
        require(msg.value > 0,"The donation amount must be greater than 0");
        donations[msg.sender] += msg.value;
        totalDonations += msg.value;
        updateTopDonors(msg.sender,donations[msg.sender]);
        emit Donation(msg.sender, msg.value);
    }

    function updateTopDonors(address donor,uint256 amount) private {
        int256 existingIndex = -1;
        for(uint256 i = 0 ; i < 3 ; i++){
            if(topDonors[i].donor == donor){
                existingIndex = int256(i);
                break;
            }
        }

        if(existingIndex > -1){
            topDonors[uint256(existingIndex)].amount = amount;
        }else{
            uint256 minAmount = amount;
            uint256 minIndex = 3;
            for(uint256 i = 0;i<3;i++){
                if(topDonors[i].amount < minAmount){
                    minAmount = topDonors[i].amount;
                    minIndex = i;
                }
            }

            if(minIndex < 3){
                topDonors[minIndex] = TopDonor({
                    donor:donor,
                    amount:amount
                });
            }
        }
    }

    function withdraw() external onlyOwner(){
        uint256 balance = address(this).balance;
        require(balance > 0 ,"No funds to withdraw");
        (bool withDrawSucc,) = payable(owner()).call{value:balance}("");
        require(withDrawSucc,"With draw transfer failed");
        emit Withdrawal(owner(), balance);
    }

    function getTopDonors() external view returns(TopDonor[3] memory){
        return topDonors;
    }

    function getDonation(address donor) external view returns(uint256){
        return donations[donor];
    }
}