// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.21;

import "./BitMath.sol";

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

    function nextInitializedTickWithinOneWord(
        mapping(int16 => uint) storage self,
        int24 tick,
        int24 tickSpacing,
        bool lte
    ) internal view returns (int24 next, bool initialized) {
        int24 compressed = tick / tickSpacing;

        if (lte) {
            (int16 wordPos, uint8 bitPos) = position(compressed);
            //making a mask where all bits to the right of the current bit position, including it, are ones
            uint mask = (1 << bitPos) - 1 + (1 << bitPos);
            uint masked = self[wordPos] & mask;

            initialized = masked != 0;
            next = initialized
                ? (compressed -
                    int24(
                        uint24(bitPos - BitMath.mostSignificantBit(masked))
                    )) * tickSpacing
                : (compressed - int24(uint24(bitPos))) * tickSpacing;
        } else {
            (int16 wordPos, uint8 bitPos) = position(compressed + 1);
            //making a mask, where all bits to the left of the current bit position are ones and all the bits to the right are zeros
            uint mask = ~((1 << bitPos) - 1);
            uint masked = self[wordPos] & mask;

            initialized = masked != 0;
            next = initialized
                ? (compressed +
                    1 +
                    int24(
                        uint24(BitMath.leastSignificantBit(masked) - bitPos)
                    )) * tickSpacing
                : (compressed + 1 + int24(uint24(type(uint8).max - bitPos))) *
                    tickSpacing;
        }
    }
}
