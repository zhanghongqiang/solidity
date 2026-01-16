// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

contract PriceConsumer{
    mapping (address => address) public priceFeeds;

    address public constant ETH_USD_PRICE_FEED = 0x694AA1769357215DE4FAC081bf1f309aDC325306;

    event PriceFeedAdded(address indexed token, address indexed priceFeed);

    constructor(){
        priceFeeds[address(0)] = ETH_USD_PRICE_FEED;   
    }

     function addPriceFeed(address token, address priceFeed) external {
        require(priceFeed != address(0), "Invalid price feed address");
        priceFeeds[token] = priceFeed;
        emit PriceFeedAdded(token, priceFeed);
    }

    function getLatestPrice(address token) public view returns (int256,uint8){
        address feed = priceFeeds[token];
        require(feed != address(0), "Price feed not found");
        AggregatorV3Interface priceFeed = AggregatorV3Interface(feed);
        (,int256 price,,,) = priceFeed.latestRoundData();
        uint8 decimals = priceFeed.decimals();
        return (price, decimals);
    }

    function convertToUSD(address asset, uint256 amount) public view returns (uint256){
        (int256 price, uint8 decimals) = getLatestPrice(asset);
        require(price > 0, "Invalid price");
        uint256 priceMultiplier = 10 ** uint256(decimals);
        return (amount * uint256(price)) / priceMultiplier;
    }
}