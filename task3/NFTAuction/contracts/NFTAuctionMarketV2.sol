// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;
import "./NFTAuctionMarket.sol";

contract NFTAuctionMarketV2 is NFTAuctionMarket {
    function version() public pure returns (string memory) {
        return "V2";
    }
}