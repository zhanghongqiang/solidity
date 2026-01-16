import {expect} from "chai";
import { ethers , upgrades} from "hardhat";
import { loadFixture } from "@nomicfoundation/hardhat-toolbox/network-helpers";
describe("NFTAuctionMarket", function () {
    async function deployContractsFixture() {
        const [owner,seller,buyer1,buyer2] = await ethers.getSigners();

        const priceConsumer = await ethers.deployContract("PriceConsumer");

        //const PriceConsumer = await ethers.getContractFactory("PriceConsumer");
        //const priceConsumer = await PriceConsumer.deploy();

        const myNFT = await ethers.deployContract("MyNFT",["MyNFT","MNFT"]);

        //const MyNFT = await ethers.getContractFactory("MyNFT");
        //const myNFT = await MyNFT.deploy("TestNFT", "TNFT");

        const nftAuctionMarket = await ethers.getContractFactory("NFTAuctionMarket");

        const nftAuctionMarketProxy = await upgrades.deployProxy(nftAuctionMarket, [
            await priceConsumer.getAddress()
        ],{
            initializer: "initialize"
        });

        await myNFT.mintNFT(seller.address, "https://example.com/token/1");

        return {owner,seller,buyer1,buyer2,priceConsumer,myNFT,nftAuctionMarketProxy};
    }

    it("应该成功创建拍卖", async function () {
        const {seller,myNFT,nftAuctionMarketProxy} = await loadFixture(deployContractsFixture);
        
        console.log("getTokenId :", await myNFT.getTokenId());
        await myNFT.connect(seller).approve(await nftAuctionMarketProxy.getAddress(), 0);

        await expect(nftAuctionMarketProxy.connect(seller).createAuction(
            await myNFT.getAddress(),
            0,
            ethers.ZeroAddress,
            ethers.parseEther("1.0"),
            3600 
        )).to.emit(nftAuctionMarketProxy,"AuctionCreate");
    });

    it("应该成功出价并比较USD价值", async function () {
        const {seller,buyer1,myNFT,nftAuctionMarketProxy} = await loadFixture(deployContractsFixture);
        await myNFT.connect(seller).approve(await nftAuctionMarketProxy.getAddress(), 0);
        
        await nftAuctionMarketProxy.connect(seller).createAuction(
            await myNFT.getAddress(),
            0,
            ethers.ZeroAddress,
            ethers.parseEther("0.5"),
            3600 
        )
        let auction = await nftAuctionMarketProxy.getAuction(1);
        console.log("Auction End Time:",auction.endTime.toString(),"highestBid:",auction.startPrice.toString());
        await expect(nftAuctionMarketProxy.connect(buyer1).bid(1,ethers.parseEther("1.0"), {
            value: ethers.parseEther("1.0")})
        ).to.emit(nftAuctionMarketProxy,"BidPlaced");
    });
    

    it("应该正确结束拍卖并分配资产",async function() {
        const {seller,buyer1,myNFT,nftAuctionMarketProxy} = await loadFixture(deployContractsFixture);
        await myNFT.connect(seller).approve(await nftAuctionMarketProxy.getAddress(), 0);
        await nftAuctionMarketProxy.connect(seller).createAuction(
            await myNFT.getAddress(),
            0,
            ethers.ZeroAddress,
            ethers.parseEther("1.0"),
            3600
        );
       
        await nftAuctionMarketProxy.connect(buyer1).bid(1,ethers.parseEther("2.0"), {
            value: ethers.parseEther("2.0")});

        //等待拍卖时间结束
        //await new Promise(resolve => setTimeout(resolve, 12000));

        await expect(nftAuctionMarketProxy.connect(seller).endAuction(1)).to.emit(nftAuctionMarketProxy,"AuctionEnded");


    });

    it("应该支持合约升级",async function() {
        const {nftAuctionMarketProxy} = await loadFixture(deployContractsFixture);
        const NFTAuctionMarketV2 = await ethers.getContractFactory("NFTAuctionMarketV2");
        const upgradedNFTAuctionMarketV2 = await upgrades.upgradeProxy(
            await nftAuctionMarketProxy.getAddress(),
            NFTAuctionMarketV2
        );

        expect(await upgradedNFTAuctionMarketV2.version()).to.equal("V2");

    });


});
    
describe("NFTAuctionMarketV2", function () {
  it("应该包含新功能", async function () {
    const NFTAuctionMarketV2 = await ethers.getContractFactory("NFTAuctionMarketV2");
    
  });
});