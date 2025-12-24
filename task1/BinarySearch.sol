// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract  BinarySearch {
   function binarySearch(uint256[] memory arr,uint256 target) public pure returns(int256){
        int256 left = 0;
        int256 right = int256(arr.length) - 1;

        while(left <= right){
            int256 middle = left + (right - left) / 2;
            uint256 middleValue = arr[uint256(middle)];

            if(middleValue == target){
                return middle;
            }else if(middleValue < target){
                 left = middle + 1;
            }else{
                right = middle - 1;
            }
        }
        return -1;
   }
}