// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.7.6;
pragma abicoder v2;

import "@uniswap/v3-periphery/contracts/libraries/TransferHelper.sol";
import "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";

contract V3Swap {
    ISwapRouter public immutable swapRouter;

    constructor(address router) {
        swapRouter = ISwapRouter(router);
    }

    uint24 public constant poolFee = 3000;

    function swapExactInputSingle(
        uint256 amountIn,
        address from,
        address to
    ) external returns (uint256 amountOut) {
        TransferHelper.safeTransferFrom(
            from,
            msg.sender,
            address(this),
            amountIn
        );

        TransferHelper.safeApprove(from, address(swapRouter), amountIn);

        ISwapRouter.ExactInputSingleParams memory params = ISwapRouter
            .ExactInputSingleParams({
                tokenIn: from,
                tokenOut: to,
                fee: poolFee,
                recipient: msg.sender,
                deadline: block.timestamp,
                amountIn: amountIn,
                amountOutMinimum: 0,
                sqrtPriceLimitX96: 0
            });

        amountOut = swapRouter.exactInputSingle(params);
    }

    function swapExactOutputSingle(
        uint256 amountOut,
        uint256 amountInMaximum,
        address from,
        address to
    ) external returns (uint256 amountIn) {
        TransferHelper.safeTransferFrom(
            from,
            msg.sender,
            address(this),
            amountInMaximum
        );

        TransferHelper.safeApprove(from, address(swapRouter), amountInMaximum);

        ISwapRouter.ExactOutputSingleParams memory params = ISwapRouter
            .ExactOutputSingleParams({
                tokenIn: from,
                tokenOut: to,
                fee: poolFee,
                recipient: msg.sender,
                deadline: block.timestamp,
                amountOut: amountOut,
                amountInMaximum: amountInMaximum,
                sqrtPriceLimitX96: 0
            });

        amountIn = swapRouter.exactOutputSingle(params);

        if (amountIn < amountInMaximum) {
            TransferHelper.safeApprove(from, address(swapRouter), 0);
            TransferHelper.safeTransfer(
                from,
                msg.sender,
                amountInMaximum - amountIn
            );
        }
    }
}
