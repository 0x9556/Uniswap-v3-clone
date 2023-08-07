// Since every pool contract is an exchange market of two tokens, we need to track the two token addresses. And these addresses will be static, set once and forever during pool deployment (thus, they will be immutable).
// Each pool contract is a set of liquidity positions. We’ll store them in a mapping, where keys are unique position identifiers and values are structs holding information about positions.
// Each pool contract will also need to maintain a ticks registry–this will be a mapping with keys being tick indexes and values being structs storing information about ticks.
// Since the tick range is limited, we need to store the limits in the contract, as constants.
// Recall that pool contracts store the amount of liquidity, L. So we’ll need to have a variable for it.
// Finally, we need to track the current price and the related tick. We’ll store them in one storage slot to optimize gas consumption: these variables will be often read and written together, so it makes sense to benefit from the state variables packing feature of Solidity.

// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.17;

contract UniswapV3Pool {
    int24 internal constant MIN_TICK = -887272;
    int24 internal constant MAX_TICK = 887272;

    address public immutable token0;
    address public immutable token1;

    struct Slot0 {
        uint160 sqrtPriceX96;
        int24 tick;
    }

    Slot0 public slot0;

    uint128 public liquidity;

    mapping(int24 => Tick.Info) public ticks;
    mapping(bytes32 => Position.Info) public positions;
}
