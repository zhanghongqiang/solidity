// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MergeSortedArrays{
    function mergeSorted(uint256[] memory arr1,uint256[] memory arr2)public pure returns(uint256[] memory){
        uint256 len1 = arr1.length;
        uint256 len2 = arr2.length;

        uint256[] memory resultArr = new uint256[](len1 + len2);
        
        uint256 i = 0;
        uint256 j = 0;
        uint256 k = 0;

        while(i < len1 && j < len2){
            if(arr1[i] <= arr2[j]){
                resultArr[k] = arr1[i];
                i++;
            }else{
                resultArr[k] = arr2[j];
                j++;
            }
            k++;
        }

        while(i < len1){
            resultArr[k] = arr1[i];
            i++;
            k++;
        }

        while(j < len2){
            resultArr[k] = arr2[j];
            j++;
            k++;
        }
        return resultArr;
    }
}