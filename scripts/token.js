require("dotenv").config();
const hre = require("hardhat");

async function main() {
  const Token = await hre.ethers.getContractFactory("Token");
  const token = await Token.deploy();
  await token.deployTransaction.wait();
  console.log("token deployed to:", token.address);

  console.log("yarn hardhat verify --network mumbai", token.address);

  //console.log("yarn hardhat verify --network poly", token.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
