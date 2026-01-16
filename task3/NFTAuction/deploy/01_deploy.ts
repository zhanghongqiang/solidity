import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";
import { upgrades } from "hardhat";

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployments, getNamedAccounts } = hre;
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();

  console.log("Deploying contracts with the account:", deployer);

 
  const priceConsumer = await deploy("PriceConsumer", {
    from: deployer,
    args: [],
    log: true,
  });

 
  const myNFT = await deploy("MyNFT", {
    from: deployer,
    args: ["MyNFT", "MNFT"],
    log: true,
  });


  const NFTAuctionMarket = await hre.ethers.getContractFactory("NFTAuctionMarket");
  const nftAuctionMarket = await upgrades.deployProxy(NFTAuctionMarket, [
    priceConsumer.address
  ], {
    initializer: "initialize",
    kind: "uups"
  });

  await nftAuctionMarket.waitForDeployment();
  const nftAuctionMarketAddress = await nftAuctionMarket.getAddress();

  console.log("PriceConsumer deployed to:", priceConsumer.address);
  console.log("MyNFT deployed to:", myNFT.address);
  console.log("AuctionMarket (proxy) deployed to:", nftAuctionMarketAddress);
};

export default func;
func.tags = ["all", "auction"];