// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.7.6;
pragma abicoder v2;

import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import "@uniswap/lib/contracts/libraries/TransferHelper.sol";

contract V2Swap {
    // For the scope of these swap examples,
    // we will detail the design considerations when using
    // `exactInput`, `exactInputSingle`, `exactOutput`, and  `exactOutputSingle`.

    // It should be noted that for the sake of these examples, we purposefully pass in the swap router instead of inherit the swap router for simplicity.
    // More advanced example contracts will detail how to inherit the swap router safely.

    IUniswapV2Router02 public immutable swapRouter;
        
    // This example swaps DAI/WETH9 for single path swaps and DAI/USDC/WETH9 for multi path swaps.

    address public immutable DAI;
    address public immutable WETH9;

    constructor(address router, address dai,address weth9){
        swapRouter = IUniswapV2Router02(router);
        DAI = dai;
        WETH9 = weth9;
    }

    /// @notice swapExactInputSingle swaps a fixed amount of DAI for a maximum possible amount of WETH9
    /// @dev The calling address must approve this contract to spend at least `amountIn` worth of its DAI for this function to succeed.
    /// @param amountIn The exact amount of DAI that will be swapped for WETH9.
    /// @return amountOut The amount of WETH9 received.
    function swapExactInputSingle(uint256 amountIn)
        external
        returns (uint256 amountOut)
    {
        // msg.sender must approve this contract

        // Transfer the specified amount of DAI to this contract.
        TransferHelper.safeTransferFrom(
            DAI,
            msg.sender,
            address(this),
            amountIn
        );

        // Approve the router to spend DAI.
        TransferHelper.safeApprove(DAI, address(swapRouter), amountIn);

        address[] memory path = new address[](2);
        path[0] = DAI;
        path[1] = WETH9;
        // The call to `swapExactETHForTokens` executes the swap.
        uint256[] memory amountOuts = swapRouter.swapExactTokensForTokens(
            amountIn,
            0,
            path,
            msg.sender,
            block.timestamp
        );

        amountOut = amountOuts[0];
    }

    /// @notice swapExactOutputSingle swaps a minimum possible amount of DAI for a fixed amount of WETH.
    /// @dev The calling address must approve this contract to spend its DAI for this function to succeed. As the amount of input DAI is variable,
    /// the calling address will need to approve for a slightly higher amount, anticipating some variance.
    /// @param amountOut The exact amount of WETH9 to receive from the swap.
    /// @param amountInMaximum The amount of DAI we are willing to spend to receive the specified amount of WETH9.
    /// @return amountIn The amount of DAI actually spent in the swap.
    function swapExactOutputSingle(uint256 amountOut, uint256 amountInMaximum)
        external
        returns (uint256 amountIn)
    {
        // Transfer the specified amount of DAI to this contract.
        TransferHelper.safeTransferFrom(
            DAI,
            msg.sender,
            address(this),
            amountInMaximum
        );

        // Approve the router to spend the specifed `amountInMaximum` of DAI.
        // In production, you should choose the maximum amount to spend based on oracles or other data sources to acheive a better swap.
        TransferHelper.safeApprove(DAI, address(swapRouter), amountInMaximum);

        address[] memory path = new address[](2);
        path[0] = DAI;
        path[1] = WETH9;

        // Executes the swap returning the amountIn needed to spend to receive the desired amountOut.
        uint256[] memory amountIns = swapRouter.swapTokensForExactTokens(
            amountOut,
            amountInMaximum,
            path,
            msg.sender,
            block.timestamp
        );

        amountIn = amountIns[0];
        // For exact output swaps, the amountInMaximum may not have all been spent.
        // If the actual amount spent (amountIn) is less than the specified maximum amount, we must refund the msg.sender and approve the swapRouter to spend 0.
        if (amountIn < amountInMaximum) {
            TransferHelper.safeApprove(DAI, address(swapRouter), 0);
            TransferHelper.safeTransfer(
                DAI,
                msg.sender,
                amountInMaximum - amountIn
            );
        }
    }
}