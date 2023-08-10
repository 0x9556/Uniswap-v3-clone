// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.17;

interface IUniswapV3SwapCallback {
    function uniswapV3SwapCallback(int amount0, int amount1,bytes calldata data) external;
}
