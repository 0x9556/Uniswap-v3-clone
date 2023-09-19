// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.21;

import "./Math.sol";

library SwapMath {
    function computeSwapStep(
        uint160 sqrtPriceCurrentX96,
        uint160 sqrtPriceTargetX96,
        uint128 liquidity,
        uint256 amountRemaining,
        uint24 fee
    ) internal pure returns (uint160 sqrtPriceNextX96, uint256 amountIn, uint256 amountOut, uint256 feeAmount) {
        bool zeroForOne = sqrtPriceCurrentX96 >= sqrtPriceTargetX96;
        sqrtPriceNextX96 = Math.getNextSqrtPriceFromInput(sqrtPriceCurrentX96, liquidity, amountRemaining, zeroForOne);
        uint256 amount0Delta = Math.calculateAmount0Delta(sqrtPriceCurrentX96, sqrtPriceNextX96, liquidity);
        uint256 amount1Delta = Math.calculateAmount1Delta(sqrtPriceCurrentX96, sqrtPriceNextX96, liquidity);

        (amountIn, amountOut) = zeroForOne ? (amount0Delta, amount1Delta) : (amount1Delta, amount0Delta);
    }
}
