// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.17;

import "forge-std/Script.sol";
import "../src/ERC20Mintable.sol";
import "../src/UniswapV3Pool.sol";

contract DeployDev is Script {
    function run() public {
        uint wethBalance = 1 ether;
        uint usdcBalance = 5042 ether;
        int24 currentTick = 85176;
        uint160 currentSqrtP = 5602277097478614198912276234240;

        vm.startBroadcast();

        ERC20Mintable token0 = new ERC20Mintable("USDC", "USDC", 18);
        ERC20Mintable token1 = new ERC20Mintable("Ether", "ETH", 18);

        UniswapV3Pool pool = new UniswapV3Pool(
            address(token0),
            address(token1),
            currentSqrtP,
            currentTick
        );
        vm.stopBroadcast();
    }
}
