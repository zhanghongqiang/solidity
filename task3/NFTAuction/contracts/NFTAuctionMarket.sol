// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {UUPSUpgradeable} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import {ReentrancyGuardUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";
import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC721Receiver} from "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import {PriceConsumer} from "./PriceConsumer.sol";
import {console } from "hardhat/console.sol";
contract NFTAuctionMarket is Initializable, UUPSUpgradeable, ReentrancyGuardUpgradeable, OwnableUpgradeable , IERC721Receiver {

    uint256 constant public platformFee = 250;

    uint256 public actionCount;

    PriceConsumer public priceConsumer;

    mapping (uint256 => Auction) public actions;

    mapping (address => uint256) public pendingReturns;

    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {

    }

    /*
    constructor(){
         _disableInitializers();
    }
    */

    function initialize(address _priceConsumer) public initializer {
         __ReentrancyGuard_init();
        __Ownable_init(msg.sender);
        __UUPSUpgradeable_init();
        priceConsumer = PriceConsumer(_priceConsumer);
        actionCount = 0;
    }

    event AuctionCreate(
        uint256 indexed auctionId,
        address indexed seller,
        address indexed nftContract,
        uint256 tokenId,
        uint256 startPrice,
        uint256 endTime,
        address paymentToken
    );

    event BidPlaced(
        uint256 indexed auctionId,
        address indexed bidder,
        uint256 amount,
        uint256 usdAmount,
        address paymentToken
    );

    event AuctionEnded(
        uint256 indexed auctionId,
        address indexed bidder,
        uint256 amount
    );

    event AuctionCancel(
        uint256 indexed auctionId
    );

    event NFTReceived(address indexed operator, address indexed from, uint256 tokenId, bytes data);

    enum ActionStatus {
        Active,Ended,Cancelled 
    }

    struct Auction {
        address seller;
        address nftAddress;
        uint256 tokenId;
        uint256 highestBid; 
        address highestBidder;
        uint256 endTime;
        uint256 startPrice;
        address paymentToken;
        ActionStatus status;
    }

    function createAuction(address ntfContract,uint256 tokenId,address paymentToken,uint256 price,uint256 duration) public returns(uint256){
        require(duration >= 1 hours ,"Duration too short");
        require(price > 0,"Start price must be positive");
        IERC721 nft = IERC721(ntfContract);
        require(nft.ownerOf(tokenId) == msg.sender,"Not NFT owner");
        
        nft.safeTransferFrom(msg.sender,address(this),tokenId);

        actionCount++;

        actions[actionCount] = Auction({
            seller: msg.sender,
            nftAddress: ntfContract,
            tokenId: tokenId,
            highestBid: 0,
            highestBidder: address(0),
            endTime: block.timestamp + duration,
            startPrice: price,
            paymentToken: paymentToken,
            status: ActionStatus.Active
        });

        emit AuctionCreate(actionCount,msg.sender,ntfContract,tokenId,price,block.timestamp + duration,paymentToken);

        return actionCount;
    }

    function bid(uint256 auctionId,uint256 amount) external payable nonReentrant{
        Auction storage auction = actions[auctionId];
        require(auction.status == ActionStatus.Active,"Auction not active");
        require(block.timestamp < auction.endTime,"Auction ended");
        require(amount> 0,"Bid amount must be positive");
        
        uint256 usdAmount = priceConsumer.convertToUSD(auction.paymentToken,amount);

        uint256 usdHighestBid = priceConsumer.convertToUSD(auction.paymentToken,auction.highestBid);

        require(usdAmount > usdHighestBid,"Bid too low");

        if(auction.paymentToken == address(0)){
            require(msg.value == amount,"Incorrect ETH amount sent");
        } else {
            IERC20 token = IERC20(auction.paymentToken);
            require(token.transferFrom(msg.sender,address(this),amount),"Payment failed");
        }

        if(auction.highestBidder != address(0)){
            pendingReturns[auction.highestBidder] += auction.highestBid;
        }
        auction.highestBid = amount;
        auction.highestBidder = msg.sender;
        emit BidPlaced(auctionId,msg.sender,amount,usdAmount,auction.paymentToken);

    }

    function endAuction(uint256 auctionId) external nonReentrant{
        Auction storage auction = actions[auctionId];
        require(auction.status == ActionStatus.Active,"Auction not active");
        require(block.timestamp >= auction.endTime,"Auction not yet ended");

        auction.status = ActionStatus.Ended;

        IERC721 nft = IERC721(auction.nftAddress);
        if(auction.highestBidder != address(0)){
            uint256 feeAmount = (auction.highestBid * platformFee) / 10000;
            uint256 sellerAmount = auction.highestBid - feeAmount;

            if(auction.paymentToken == address(0)){
                payable(auction.seller).transfer(sellerAmount);
                payable(owner()).transfer(feeAmount);
            } else {
                IERC20 token = IERC20(auction.paymentToken);
                require(token.transfer(auction.seller,sellerAmount),"Payment to seller failed");
                require(token.transfer(owner(),feeAmount),"Payment of fee failed");
            }

            nft.safeTransferFrom(auction.seller,auction.highestBidder,auction.tokenId);

            emit AuctionEnded(auctionId,auction.highestBidder,auction.highestBid);
        } else {
           
            nft.safeTransferFrom(address(this),auction.seller,auction.tokenId);
            emit AuctionEnded(auctionId,address(0),0);
        }
    }   

    function withdraw() external nonReentrant{
        uint256 amount = pendingReturns[msg.sender];
        require(amount > 0,"No funds to withdraw");
        pendingReturns[msg.sender] = 0;
        payable(msg.sender).transfer(amount);
    }   

    function cancelAuction(uint256 auctionId) external nonReentrant{
        Auction storage auction = actions[auctionId];
        require(auction.status == ActionStatus.Active,"Auction not active");
        require(auction.seller == msg.sender,"Not auction seller");
        require(auction.highestBidder == address(0),"Cannot cancel, bids already placed");

        auction.status = ActionStatus.Cancelled;

        IERC721 nft = IERC721(auction.nftAddress);
        nft.safeTransferFrom(address(this),auction.seller,auction.tokenId);

        emit AuctionCancel(auctionId);
    }

     function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external override returns (bytes4) {
        emit NFTReceived(operator, from, tokenId, data);
        return this.onERC721Received.selector;
    }

    function getAuction(uint256 auctionId)  external view returns (Auction memory){
        return actions[auctionId];  
    }
}