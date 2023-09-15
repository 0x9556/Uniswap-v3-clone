// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.21;

library SwapMath {
    function computeSwapStep(
        uint160 sqrtPriceCurrentX96,
        uint160 sqrtPriceTargetX96,
        uint128 liquidity,
        uint amountRemaining,
        uint24 fee
    ) internal pure returns(
        uint160 sqrtPriceNextX96,
        uint amountIn,
        uint amountOut,
        uint feeAmount
    ){
        
    }
}

