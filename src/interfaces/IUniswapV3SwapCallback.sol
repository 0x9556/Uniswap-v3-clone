// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.17;

interface IUniswapV3SwapCallback {
    function uniswapV3SwapCallback(uint amount0, uint amount1) external;
}
