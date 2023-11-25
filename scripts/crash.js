require("dotenv").config();
const hre = require("hardhat");

async function main() {
  const Crash = await hre.ethers.getContractFactory("Crash");
  const crash = await Crash.deploy();
  await crash.deployTransaction.wait();
  console.log("crash deployed to:", crash.address);

  console.log("yarn hardhat verify --network mumbai", crash.address);

  //console.log("yarn hardhat verify --network poly", crash.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
