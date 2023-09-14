// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.21;

import "./FixedPoint96.sol";

library Math {
    function calculateAmount0Delta(uint160 sqrtPriceAX96, uint160 sqrtPriceBX96, uint128 liquidity)
        internal
        pure
        returns (uint256 amount0)
    {
        if (sqrtPriceAX96 > sqrtPriceBX96) {
            (sqrtPriceAX96, sqrtPriceBX96) = (sqrtPriceBX96, sqrtPriceAX96);
        }
        require(sqrtPriceAX96 > 0);

        amount0 = divRoundingUp(
            mulDivRoundingUp(
                uint256(liquidity) << FixedPoint96.RESOLUTION, (sqrtPriceBX96 - sqrtPriceAX96), sqrtPriceBX96
            ),
            sqrtPriceAX96
        );
    }

    function calculateAmount1Delta(uint160 sqrtPriceAX96, uint160 sqrtPriceBX96, uint128 liquidity)
        internal
        pure
        returns (uint256 amount1)
    {
        if (sqrtPriceAX96 > sqrtPriceBX96) {
            (sqrtPriceAX96, sqrtPriceBX96) = (sqrtPriceBX96, sqrtPriceAX96);
        }
        require(sqrtPriceAX96 > 0);

        amount1 = mulDivRoundingUp(liquidity, (sqrtPriceBX96 - sqrtPriceAX96), FixedPoint96.Q96);
    }

    function mulDivRoundingUp(uint256 a, uint256 b, uint256 denominator) private pure returns (uint256 result) {
        result = PRBMath.muldiv(a, b, denominator);
        if (mulmod(a, b, denominator) > 0) {
            require(result < type(uint256).max);
            result++;
        }
    }

    function divRoundingUp(uint256 numerator, uint256 denominator) private pure returns (uint256 result) {
        assembly {
            result := add(div(numerator, denominator), gt(mod(numerator, denominator), 0))
        }
    }
}
