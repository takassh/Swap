import * as dotenv from "dotenv";
import { ethers } from "hardhat";
import IERC20Artifact from "../artifacts/@openzeppelin/contracts/token/ERC20/IERC20.sol/IERC20.json";
import V2SwapArtifact from "../artifacts/contracts/V2Swap.sol/V2Swap.json";
import { IERC20 } from "../typechain";
import { V2Swap } from "../typechain/V2Swap";
dotenv.config();

async function v2Swap() {
  console.log("start to deploy");

  const Swap = await ethers.getContractFactory("V2Swap");
  const sushiSwapRouter = "0x1b02dA8Cb0d097eB8D57A175b88c7D8b47997506";
  const swap = await Swap.deploy(sushiSwapRouter);

  await swap.deployed();

  console.log("Swap deployed to:", swap.address);

  console.log("start");

  // Connect to the network
  const provider = new ethers.providers.JsonRpcProvider(
    process.env.ROPSTEN_SERVER_URL ?? ""
  );
  const wallet = new ethers.Wallet(process.env.PRIVATE_KEY ?? "", provider);

  const contract = new ethers.Contract(
    swap.address,
    V2SwapArtifact.abi,
    wallet
  ) as V2Swap;

  const weth = new ethers.Contract(
    "0xc778417E063141139Fce010982780140Aa0cD5Ab",
    IERC20Artifact.abi,
    wallet
  ) as IERC20;

  const dai = new ethers.Contract(
    "0xaD6D458402F60fD3Bd25163575031ACDce07538D",
    IERC20Artifact.abi,
    wallet
  ) as IERC20;

  const myAddress = await wallet.getAddress();

  let balance = await weth.balanceOf(myAddress);

  console.log("weth balance before:", balance);

  const amount = ethers.utils.parseUnits("0.1", 18);

  // must approve contract to use your weth
  const approve = await weth.approve(contract.address, amount);

  await approve.wait();

  const result = await contract.swapExactInputSingle(
    amount,
    weth.address,
    dai.address
  );

  await result.wait();

  balance = await weth.balanceOf(myAddress);

  console.log("weth balance after:", balance);

  console.log("contract is here:", result.hash);

  // weth.on("Approval", async (owner, spender, value: BigNumber) => {});
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
v2Swap().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
