// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract IntegerToRoman{
    function intToRoman(uint256 num) public pure returns(string memory){
        require(num > 0 && num < 4000,"Number must be 1 and 3999");

        string[4] memory thousands = ["","M","MM","MMM"];
        string[10] memory hundreds = ["","C","CC","CCC","CD","D","DC","DDC","DCCC","CM"];
        string[10] memory tens = ["","X","XX","XXX","XL","L","LX","LXX","LXXX","XC"];
        string[10] memory ones = ["","I","II","III","IV","V","VI","VII","VIII","IX"];

        uint256 thousandDigit = num / 1000;
        uint256 hundredDigit = (num % 1000) / 100;
        uint256 tenDigit = (num % 100) / 10;
        uint256 unitDigit = num % 10;

        return string(abi.encodePacked(
            thousands[thousandDigit],
            hundreds[hundredDigit],
            tens[tenDigit],
            ones[unitDigit]
        ));

    }
}