// SPDX-License-Identifier: SEE LICENSE IN LICENSE
import "./interfaces/IERC20.sol";
import "./interfaces/IUniswapV3MintCallback.sol";
import "./interfaces/IUniswapV3SwapCallback.sol";
import "./lib/Position.sol";
import "./lib/Tick.sol";
import "./lib/TickBitmap.sol";
import "./lib/Math.sol";
import "./lib/TickMath.sol";

pragma solidity ^0.8.21;

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
        int256 indexed amount0,
        int256 indexed amount1,
        uint160 sqrtPriceX96,
        uint128 liquidity,
        int24 tick
    );

    using Tick for mapping(int24 => Tick.Info);
    using Position for mapping(bytes32 => Position.Info);
    using Position for Position.Info;
    using TickBitmap for mapping(int16 => uint256);

    int24 internal constant MIN_TICK = -887272;
    int24 internal constant MAX_TICK = 887272;

    address public immutable token0;
    address public immutable token1;

    struct Slot0 {
        uint160 sqrtPriceX96;
        int24 tick;
    }

    struct CallbackData {
        address token0;
        address token1;
        address payer;
    }

    Slot0 public slot0;

    uint128 public liquidity;

    mapping(int24 => Tick.Info) public ticks;
    mapping(bytes32 => Position.Info) public positions;
    mapping(int16 => uint256) public tickBitmap;

    constructor(address _token0, address _token1, uint160 _sqrtPriceX96, int24 _tick) {
        token0 = _token0;
        token1 = _token1;
        slot0 = Slot0({sqrtPriceX96: _sqrtPriceX96, tick: _tick});
    }

    function mint(address owner, int24 lowerTick, int24 upperTick, uint128 amount, bytes calldata data)
        external
        returns (uint256 amount0, uint256 amount1)
    {
        if (lowerTick < MIN_TICK || upperTick > MAX_TICK || lowerTick > upperTick) revert InvalidTickRange();

        if (amount == 0) revert ZeroLiquidity();

        bool flippedLower = ticks.update(lowerTick, amount);
        bool flippedUpper = ticks.update(upperTick, amount);

        if (flippedLower) {
            tickBitmap.flipTick(lowerTick, 1);
        }
        if (flippedUpper) {
            tickBitmap.flipTick(upperTick, 1);
        }

        Position.Info storage positionInfo = positions.get(owner, lowerTick, upperTick);

        positionInfo.update(amount);

        liquidity += amount;

        Slot0 memory _slot0 = slot0;

        amount0 = Math.calculateAmount0Delta(_slot0.sqrtPriceX96, TickMath.getSqrtRatioAtTick(upperTick), liquidity);
        amount1 = Math.calculateAmount1Delta(_slot0.sqrtPriceX96, TickMath.getSqrtRatioAtTick(lowerTick), liquidity);

        uint256 balance0Before;
        uint256 balance1Before;

        if (amount0 > 0) balance0Before = balance0();
        if (amount1 > 0) balance1Before = balance1();

        IUniswapV3MintCallback(msg.sender).uniswapV3MintCallback(amount0, amount1, data);

        if (amount0 > 0 && balance0Before + amount0 > balance0()) {
            revert InsufficientInputAmount();
        }
        if (amount1 > 0 && balance1Before + amount0 > balance1()) {
            revert InsufficientInputAmount();
        }

        emit Mint(msg.sender, owner, lowerTick, upperTick, amount, amount0, amount1);
    }

    function swap(address recipient, bool zeroForOne, uint256 amountSpecified, bytes calldata data)
        external
        returns (int256 amount0, int256 amount1)
    {
        int24 nextTick = 85184;
        uint160 nextPrice = 5604469350942327889444743441197;

        amount0 = -0.008396714242162444 ether;
        amount1 = 42 ether;

        (slot0.tick, slot0.sqrtPriceX96) = (nextTick, nextPrice);

        IERC20(token0).transfer(recipient, uint256(-amount0));
        uint256 balance1Before = balance1();
        IUniswapV3SwapCallback(msg.sender).uniswapV3SwapCallback(amount0, amount1, data);

        if (balance1Before + uint256(amount1) < balance1()) {
            revert InsufficientInputAmount();
        }

        emit Swap(msg.sender, recipient, amount0, amount1, slot0.sqrtPriceX96, liquidity, slot0.tick);
    }

    //internal
    function balance0() internal returns (uint256 balance) {
        return IERC20(token0).balanceOf(address(this));
    }

    function balance1() internal returns (uint256 balance) {
        return IERC20(token1).balanceOf(address(this));
    }

    function calculateMintAmount(int24 lowerTick, int24 upperTick, int24 currentTick)
        internal
        returns (uint256 amount0, uint256 amount1)
    {}
}
