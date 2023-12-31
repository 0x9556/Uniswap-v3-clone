// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "../src/ERC20Mintable.sol";
import "../src/UniswapV3Pool.sol";

contract UniswapV3PoolTest is Test {
    ERC20Mintable token0;
    ERC20Mintable token1;
    UniswapV3Pool pool;

    bool shouldTransferInCallback;

    struct TestCaseParams {
        uint wethBalance;
        uint usdcBalance;
        int24 currentTick;
        int24 lowerTick;
        int24 upperTick;
        uint128 liquidity;
        uint160 currentSqrtP;
        bool shouldTransferInCallback;
        bool mintLiqudity;
    }

    function setUp() public {
        token0 = new ERC20Mintable("Ether", "ETH", 18);
        token1 = new ERC20Mintable("USDC", "USDC", 18);
    }

    function testMintSuccess() public {
        TestCaseParams memory params = TestCaseParams({
            wethBalance: 1 ether,
            usdcBalance: 5000 ether,
            currentTick: 85176,
            lowerTick: 84222,
            upperTick: 86129,
            liquidity: 1517882343751509868544,
            currentSqrtP: 5602277097478614198912276234240,
            shouldTransferInCallback: true,
            mintLiqudity: true
        });

        (uint poolBalance0, uint poolBalance1) = setupTestCase(params);
        //test deposite amount
        uint256 expectedAmount0 = 0.998976618347425280 ether;
        uint256 expectedAmount1 = 5000 ether;
        assertEq(
            poolBalance0,
            expectedAmount0,
            "incorrect token0 deposited amount"
        );
        assertEq(
            poolBalance1,
            expectedAmount1,
            "incorrect token1 deposited amount"
        );
        assertEq(token0.balanceOf(address(pool)), expectedAmount0);
        assertEq(token1.balanceOf(address(pool)), expectedAmount1);
        //test position
        bytes32 positionKey = keccak256(
            abi.encodePacked(address(this), params.lowerTick, params.upperTick)
        );

        uint128 posLiquidity = pool.positions(positionKey);
        assertEq(posLiquidity, params.liquidity);
        //test tick
        (bool tickInitialized, uint128 tickLiquidity) = pool.ticks(
            params.lowerTick
        );
        assertTrue(tickInitialized);
        assertEq(tickLiquidity, params.liquidity);

        (tickInitialized, tickLiquidity) = pool.ticks(params.upperTick);
        assertTrue(tickInitialized);
        assertEq(tickLiquidity, params.liquidity);
        //test current sqrt price
        (uint160 sqrtPriceX96, int24 tick) = pool.slot0();
        assertEq(
            sqrtPriceX96,
            5602277097478614198912276234240,
            "invalid current sqrtP"
        );
        assertEq(tick, 85176, "invalid current tick");
        assertEq(
            pool.liquidity(),
            1517882343751509868544,
            "invalid current liquidity"
        );
    }

    function testSwapBuyETH() external {
        TestCaseParams memory params = TestCaseParams({
            wethBalance: 1 ether,
            usdcBalance: 5000 ether,
            currentTick: 85176,
            lowerTick: 84222,
            upperTick: 86129,
            liquidity: 1517882343751509868544,
            currentSqrtP: 5602277097478614198912276234240,
            shouldTransferInCallback: true,
            mintLiqudity: true
        });

        (uint poolBalance0, uint poolBalance1) = setupTestCase(params);

        token1.mint(address(this), 42 ether);

        uint balance0Before = IERC20(address(token0)).balanceOf(address(this));

        (int amount0Delta, int amount1Delta) = pool.swap(address(this), "");

        assertEq(amount0Delta, -0.008396714242162444 ether, "invalid eth out");
        assertEq(amount1Delta, 42 ether, "invalid usdc in");

        assertEq(
            token0.balanceOf(address(pool)),
            uint(int(poolBalance0) + amount0Delta),
            "Pool Balance0"
        );
        assertEq(
            token1.balanceOf(address(pool)),
            uint(int(poolBalance1) + amount1Delta),
            "Pool Balance1"
        );

        assertEq(
            token0.balanceOf(address(this)),
            balance0Before + uint(-amount0Delta),
            "User balance0"
        );

        assertEq(token1.balanceOf(address(this)), 0, "User balance1");
    }

    function uniswapV3MintCallback(
        uint amount0,
        uint amount1,
        bytes calldata
    ) external {
        token0.transfer(msg.sender, amount0);
        token1.transfer(msg.sender, amount1);
    }

    function uniswapV3SwapCallback(
        int amount0,
        int amount1,
        bytes calldata
    ) external {
        if (amount0 > 0) token0.transfer(msg.sender, uint(amount0));
        if (amount1 > 0) token1.transfer(msg.sender, uint(amount1));
    }

    //internal function
    function setupTestCase(
        TestCaseParams memory params
    ) internal returns (uint poolBalance0, uint poolBalance1) {
        token0.mint(address(this), params.wethBalance);
        token1.mint(address(this), params.usdcBalance);

        pool = new UniswapV3Pool(
            address(token0),
            address(token1),
            params.currentSqrtP,
            params.currentTick
        );

        if (params.mintLiqudity) {
            (poolBalance0, poolBalance1) = pool.mint(
                address(this),
                params.lowerTick,
                params.upperTick,
                params.liquidity,
                ""
            );
        }
    }
}
