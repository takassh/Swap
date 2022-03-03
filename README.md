# What 
- This is swap contract
- support `IUniswapV2Router02` and `ISwapRouter`

# contract address that implements IUniswapV2Router02
- sushiswap 0x1b02dA8Cb0d097eB8D57A175b88c7D8b47997506
- pancakeswap 0xD99D1c33F9fC3444f8101754aBC46c52416550D1

# contract address that implements ISwapRouter
- uniswap 0xE592427A0AEce92De3Edee1F18E0157C05861564

# ERC20 ropsten token address
- WETH9 0xc778417E063141139Fce010982780140Aa0cD5Ab
- DAI 0xaD6D458402F60fD3Bd25163575031ACDce07538D

# ERC20 BSC test token address
- WBNB 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd
- DAI 0x8a9424745056Eb399FD19a0EC26A14316684e274

# set up
- [typechain on hardhat](https://www.npmjs.com/package/@typechain/hardhat)

# Deploy
- `npx hardhat run scripts/*.ts --network ropsten`