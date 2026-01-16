import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

export default buildModule("NFTAuctionMarketModule",(m) => {
    const priceConsumer = m.contract("PriceConsumer");

    const myNFT = m.contract("MyNFT",["MyNFT","MNFT"]);

    const nftAuctionMarketImpl = m.contract("NFTAuctionMarket",[],{
        id:"nftAuctionMarketImpl"
    });

    const nftAuctionMarketProxy = m.contract("NFTAuctionMarket", [], {
        id: "nftAuctionMarketProxy"
    });
    m.call(nftAuctionMarketProxy, "initialize", [priceConsumer]);

    return{
        priceConsumer,
        myNFT,
        nftAuctionMarketProxy
    }
});