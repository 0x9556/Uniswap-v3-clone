// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.21;

library Tick {
    struct Info {
        bool initialized;
        uint128 liquidity;
    }

    function update(mapping(int24 => Tick.Info) storage self, int24 tick, uint128 liquidityDelta)
        internal
        returns (bool filpped)
    {
        Tick.Info storage tickInfo = self[tick];

        uint128 liquidityBefore = tickInfo.liquidity;
        uint128 liquidityAfter = liquidityBefore + liquidityDelta;

        if (liquidityBefore == 0) tickInfo.initialized = true;
        filpped = (liquidityBefore == 0) != (liquidityAfter == 0);
        tickInfo.liquidity = liquidityAfter;
    }
}
