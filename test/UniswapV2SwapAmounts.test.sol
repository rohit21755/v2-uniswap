pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {IWETH} from "../src/interfaces/IWETH.sol";
import {IERC20} from "../src/interfaces/IERC20.sol";
import {IUniswapV2Router02} from "../src/interfaces/uniswap-v2/IUniswapV2Router02.sol";
import { DAI,WETH, MKR, UNISWAP_V2_ROUTER_02 } from "../src/constants.sol";

contract UniswapV2SwapAmountsTest is Test {
    IWETH weth = IWETH(WETH);
    IERC20 dai = IERC20(DAI);
    IERC20 mkr = IERC20(MKR);
    IUniswapV2Router02 private router = IUniswapV2Router02(UNISWAP_V2_ROUTER_02);
    function test_getAmountsOut() public {
        console.log("weth");
        address[] memory path = new address[](3);
        path[0] = address(weth);
        path[1] = address(dai);
        path[2] = address(mkr);
        uint256 amountIn =1e18;
        // this function is use for swapExactTokensForTokens
        uint[] memory amounts = router.getAmountsOut(amountIn, path);
        console.log(amounts.length);
        console.log("WETH",amounts[0]);
        console.log("DAI",amounts[1]);
        console.log("MKR",amounts[2]);
    }

    function test_getAmountsIn() public {
        address[] memory path = new address[](3);
        path[0] = address(weth);
        path[1] = address(dai);
        path[2] = address(mkr);
        uint256 amountOut = 1e18/100;
        uint256[] memory amounts = router.getAmountsIn(amountOut, path);
        console.log(amounts.length);
        console.log("WETH",amounts[0]);
        console.log("DAI",amounts[1]);
        console.log("MKR",amounts[2]);
    }
}