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
    address private constant user = address(100);

    function setUp() public {
        deal(user, 100 * 1e18);
        vm.startPrank(user);
        weth.deposit{value: 100 * 1e18}();
        weth.approve(address(router), type(uint256).max); // user has approved route to spent its weth
        vm.stopPrank();
    }
    function test_getAmountsOut() public view {
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

    function test_getAmountsIn() public view {
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

    function test_swapExactTokensForTokens() public {
        address[] memory path = new address[](3);
        path[0] = WETH;
        path[1] = DAI;
        path[2] = MKR;

        uint amountIn = 1e18;
        uint amountOutMin = 1;
        console.log(mkr.balanceOf(user));
        vm.prank(user);
        uint256[] memory amounts = router.swapExactTokensForTokens(amountIn, amountOutMin, path, user, block.timestamp);
        console.log("WETH", amounts[0]);
        console.log("DAI", amounts[1]);
        console.log("MKR", amounts[2]);
        console.log(mkr.balanceOf(user));
        assertGe(mkr.balanceOf(user), amountOutMin, "MKR balance of user");
    }

}