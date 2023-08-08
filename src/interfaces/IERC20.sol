// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.17;

interface IERC20 {
    function balanceOf(address) external returns (uint);

    function approve(address, uint) external;

    function transfer(address, uint) external;

    function transferFrom(address, address, uint) external;
}
