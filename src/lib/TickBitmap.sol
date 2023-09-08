// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.21;

library TickBitmap {
    function position(
        int24 tick
    ) private pure returns (int16 wordPos, uint8 bitPos) {
        wordPos = int16(tick >> 8);
        bitPos = uint8(uint24(tick % 256));
    }

    function flipTick(
        mapping(int16 => uint) storage self,
        int24 tick,
        int24 tickSpacing
    ) internal {
        (int16 wordPos, uint8 bitPos) = position(tick / tickSpacing);
        require(tick % tickSpacing == 0);
        uint mask = 1 << bitPos;
        self[wordPos] ^= mask;
    }
}
