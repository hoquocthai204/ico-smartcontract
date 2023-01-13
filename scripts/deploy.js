const { ethers } = require("hardhat");

async function main() {
  const [deployer] = await ethers.getSigners();
  console.log("Deploying contracts with the account:", deployer.address);
  console.log("Account balance:", (await deployer.getBalance()).toString());

  const Token = await ethers.getContractFactory("SPMToken");
  const token = await Token.deploy(10000);
  console.log("Token address:", token.address);

  const Bulksender = await ethers.getContractFactory("BulkSender");
  const bulksender = await Bulksender.deploy();
  console.log("Bulksender address:", bulksender.address);

  const NftHandler = await ethers.getContractFactory("NFTHandler");
  const nftHandler = await NftHandler.deploy(process.env.NEXT_PUBLIC_NFT_TOKEN_ADDRESS, process.env.NEXT_PUBLIC_SPM_TOKEN_ADDRESS, 1);
  console.log("NftHandler address:", nftHandler.address);

  const Stacking = await ethers.getContractFactory("StackingSPM");
  const stacking = await Stacking.deploy(process.env.NEXT_PUBLIC_SPM_TOKEN_ADDRESS);
  console.log("Stacking address:", stacking.address);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
