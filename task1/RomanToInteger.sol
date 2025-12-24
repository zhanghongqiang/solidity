// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract RomanToInteger{
    mapping(bytes1 => uint256) public romanValues;
    constructor(){
        romanValues['I'] = 1;
        romanValues['V'] = 5;
        romanValues['X'] = 10;
        romanValues['L'] = 50;
        romanValues['C'] = 100;
        romanValues['D'] = 500;
        romanValues['M'] = 1000;
    }

    function romanToInt(string memory roman) public view returns(uint256){
        bytes memory romanBytes = bytes(roman);
        uint256 length = romanBytes.length;
        if(length == 0){
            return 0;
        }

        uint256 result = 0;
        for(uint256 i=0;i<length;i++){
            uint256 currentValue = getRomanValue(romanBytes[i]);
            if(i < length - 1){
                uint256 nextValue = getRomanValue(romanBytes[i+1]);
                if(currentValue < nextValue){
                    result += (nextValue - currentValue);
                    i++;
                }else{
                    result += currentValue;
                }
            }else{
                result += currentValue;
            }
        }
        return result;
    }

    function getRomanValue(bytes1 romanChar) public view returns(uint256){
        uint256 value = romanValues[romanChar];
        require(value > 0 , "Invalid roman character");
        return value;
    }
}