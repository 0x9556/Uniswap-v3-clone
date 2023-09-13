// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.21;

library BitMath {
    function mostSignificantBit(uint x) internal pure returns (uint8 r) {
        require(x > 0);
        //32
        if (x >= 0x100000000000000000000000000000000) {
            x >>= 128;
            r += 128;
        }
        //16
        if (x >= 0x10000000000000000) {
            x >>= 64;
            r += 64;
        }
        //8
        if (x >= 0x100000000) {
            x >>= 32;
            r += 32;
        }
        //4
        if (x >= 0x10000) {
            x >>= 16;
            r += 16;
        }
        //2
        if (x >= 0x100) {
            x >>= 8;
            r += 8;
        }
        //1
        if (x >= 0x10) {
            x >>= 4;
            r += 4;
        }
        //0b100
        if (x >= 0x4) {
            x >>= 2;
            r += 2;
        }
        //0b10
        if (x >= 0x2) {
            r += 1;
        }
    }

    function leastSignificantBit(uint x) internal pure returns (uint r) {
        require(x > 0);
        r = 255;
        //32
        if (x & 0xffffffffffffffffffffffffffffffff > 0) r -= 128;
        else x >> 128;
        //16
        if (x & 0xffffffffffffffff > 0) r -= 64;
        else x >> 64;
        //8
        if (x & 0xffffffff > 0) r -= 32;
        else x >> 32;
        //4
        if (x & 0xffff > 0) r -= 16;
        else x >> 16;
        //2
        if (x & 0xff > 0) r -= 8;
        else x >> 8;
        //1
        if (x & 0xf > 0) r -= 4;
        else x >> 4;
        //0b11
        if (x & 0x3 > 0) r -= 2;
        else x >> 2;
        //0b1
        if (x & 0x1 > 0) r -= 1;
    }
}