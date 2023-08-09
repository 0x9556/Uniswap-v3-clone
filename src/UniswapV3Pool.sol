// Since every pool contract is an exchange market of two tokens, we need to track the two token addresses. And these addresses will be static, set once and forever during pool deployment (thus, they will be immutable).
// Each pool contract is a set of liquidity positions. We’ll store them in a mapping, where keys are unique position identifiers and values are structs holding information about positions.
// Each pool contract will also need to maintain a ticks registry–this will be a mapping with keys being tick indexes and values being structs storing information about ticks.
// Since the tick range is limited, we need to store the limits in the contract, as constants.
// Recall that pool contracts store the amount of liquidity, L. So we’ll need to have a variable for it.
// Finally, we need to track the current price and the related tick. We’ll store them in one storage slot to optimize gas consumption: these variables will be often read and written together, so it makes sense to benefit from the state variables packing feature of Solidity.

// SPDX-License-Identifier: SEE LICENSE IN LICENSE
import "./interfaces/IERC20.sol";
import "./interfaces/IUniswapV3MintCallback.sol";
import "./interfaces/IUniswapV3SwapCallback.sol";
import "./lib/Position.sol";
import "./lib/Tick.sol";

pragma solidity ^0.8.17;

contract UniswapV3Pool {
    error InvalidTickRange();
    error ZeroLiquidity();
    error InsufficientInputAmount();

    event Mint(
        address sender,
        address indexed owner,
        int24 indexed tickLower,
        int24 indexed tickUpper,
        uint128 amount,
        uint256 amount0,
        uint256 amount1
    );

    event Swap(
        address sender,
        address indexed recipient,
        uint indexed amount0,
        uint indexed amount1,
        uint160 sqrtPriceX96,
        uint128 liquidity,
        int24 tick
    );

    using Tick for mapping(int24 => Tick.Info);
    using Position for mapping(bytes32 => Position.Info);
    using Position for Position.Info;

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

    constructor(
        address _token0,
        address _token1,
        uint160 _sqrtPriceX96,
        int24 _tick
    ) {
        token0 = _token0;
        token1 = _token1;
        slot0 = Slot0({sqrtPriceX96: _sqrtPriceX96, tick: _tick});
    }

    function mint(
        address owner,
        int24 lowerTick,
        int24 upperTick,
        uint128 amount
    ) external returns (uint amount0, uint amount1) {
        if (
            lowerTick < MIN_TICK ||
            upperTick > MAX_TICK ||
            lowerTick > upperTick
        ) revert InvalidTickRange();

        if (amount == 0) revert ZeroLiquidity();

        ticks.update(lowerTick, amount);
        ticks.update(upperTick, amount);

        Position.Info storage positionInfo = positions.get(
            owner,
            lowerTick,
            upperTick
        );

        positionInfo.update(amount);

        liquidity += amount;

        //hardcode amount0,amount1
        amount0 = 0.998976618347425280 ether;
        amount1 = 5000 ether;

        uint balance0Before;
        uint balance1Before;

        if (amount0 > 0) balance0Before = balance0();
        if (amount1 > 0) balance1Before = balance1();

        IUniswapV3MintCallback(msg.sender).uniswapV3MintCallback(
            amount0,
            amount1
        );

        if (amount0 > 0 && balance0Before + amount0 > balance0())
            revert InsufficientInputAmount();
        if (amount1 > 0 && balance1Before + amount0 > balance1())
            revert InsufficientInputAmount();

        emit Mint(
            msg.sender,
            owner,
            lowerTick,
            upperTick,
            amount,
            amount0,
            amount1
        );
    }

    function swap(
        address recipient
    ) external returns (uint amount0, uint amount1) {
        int24 nextTick = 85184;
        uint160 nextPrice = 5604469350942327889444743441197;

        amount0 = 0.008396714242162444 ether;
        amount1 = 42 ether;

        (slot0.tick, slot0.sqrtPriceX96) = (nextTick, nextPrice);

        IERC20(token0).transfer(recipient, amount0);
        uint balance1Before = balance1();
        IUniswapV3SwapCallback(msg.sender).uniswapV3SwapCallback(
            amount0,
            amount1
        );

        if (balance1Before + amount1 < balance1())
            revert InsufficientInputAmount();

        emit Swap(
            msg.sender,
            recipient,
            amount0,
            amount1,
            slot0.sqrtPriceX96,
            liquidity,
            slot0.tick
        );
    }

    //internal
    function balance0() internal returns (uint balance) {
        return IERC20(token0).balanceOf(address(this));
    }

    function balance1() internal returns (uint balance) {
        return IERC20(token1).balanceOf(address(this));
    }
}
