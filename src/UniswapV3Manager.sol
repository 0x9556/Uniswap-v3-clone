// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.21;

import "./UniswapV3Pool.sol";
import "./interfaces/IUniswapV3MintCallback.sol";
import "./interfaces/IUniswapV3SwapCallback.sol";
import "./interfaces/IERC20.sol";

contract UniswapV3Manager is IUniswapV3MintCallback, IUniswapV3SwapCallback {
    function mint(
        address poolAddress,
        address owner,
        int24 lowerTick,
        int24 upperTick,
        uint128 liquidity,
        bytes calldata data
    ) external returns (uint amount0, uint amount1) {
        (amount0, amount1) = UniswapV3Pool(poolAddress).mint(
            owner,
            lowerTick,
            upperTick,
            liquidity,
            data
        );
    }

    function swap(
        address poolAddress,
        address recipient,
        bytes calldata data
    ) external returns (int amount0, int amount1) {
        (amount0, amount1) = UniswapV3Pool(poolAddress).swap(recipient, data);
    }

    function uniswapV3MintCallback(
        uint amount0,
        uint amount1,
        bytes calldata data
    ) external {
        UniswapV3Pool.CallbackData memory extraData = abi.decode(
            data,
            (UniswapV3Pool.CallbackData)
        );

        IERC20(extraData.token0).transferFrom(
            extraData.payer,
            msg.sender,
            amount0
        );

        IERC20(extraData.token1).transferFrom(
            extraData.payer,
            msg.sender,
            amount1
        );
    }

    function uniswapV3SwapCallback(
        int amount0,
        int amount1,
        bytes calldata data
    ) external {
        UniswapV3Pool.CallbackData memory extraData = abi.decode(
            data,
            (UniswapV3Pool.CallbackData)
        );

        if (amount0 > 0) {
            IERC20(extraData.token0).transferFrom(
                extraData.payer,
                msg.sender,
                uint(amount0)
            );
        }
        if (amount1 > 0) {
            IERC20(extraData.token1).transferFrom(
                extraData.payer,
                msg.sender,
                uint(amount1)
            );
        }
    }
}
