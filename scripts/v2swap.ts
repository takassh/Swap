import * as dotenv from "dotenv";
import { ethers } from "hardhat";
import V2SwapArtifact from "../artifacts/contracts/V2Swap.sol/V2Swap.json";
import { V2Swap } from "../typechain/V2Swap";
dotenv.config();

async function v2Swap() {
  console.log("start");

  // Connect to the network
  const provider = ethers.getDefaultProvider("ropsten");
  const wallet = new ethers.Wallet(process.env.PRIVATE_KEY ?? "", provider);
  const swapContractAddress = "";

  const contract = new ethers.Contract(
    swapContractAddress,
    V2SwapArtifact.abi,
    wallet
  ) as V2Swap;

  console.log(contract.functions);

  const result = await contract.swapExactInputSingle(
    100000000000000000,
    "0xc778417E063141139Fce010982780140Aa0cD5Ab",
    "0xaD6D458402F60fD3Bd25163575031ACDce07538D"
  );

  console.log(result.hash);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
v2Swap().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
