pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {IWETH} from "../src/interfaces/IWETH.sol";
import {IERC20} from "../src/interfaces/IERC20.sol";
import {IUniswapV2Router02} from "../src/interfaces/uniswap-v2/IUniswapV2Router02.sol";
import { DAI,WETH, MKR, UNISWAP_V2_ROUTER_02 } from "../src/constants.sol";
import {ERC20} from "../src/ERC20.sol";
import {IUniswapV2Factory} from "../src/interfaces/uniswap-v2/IUniswapV2Factory.sol";
import {UNISWAP_V2_FACTORY} from "../src/Constants.sol";
import {IUniswapV2Pair} from "../src/interfaces/uniswap-v2/IUniswapV2Pair.sol";
contract UniswapV2SwapAmountsTest is Test {
    IWETH weth = IWETH(WETH);
    IERC20 dai = IERC20(DAI);
    IERC20 mkr = IERC20(MKR);
    IUniswapV2Router02 private router = IUniswapV2Router02(UNISWAP_V2_ROUTER_02);
    IUniswapV2Factory private factory = IUniswapV2Factory(UNISWAP_V2_FACTORY);
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

    function test_swapTokensForExactTokens() public {
        address[] memory path = new address[](3);
        path[0] = WETH;
        path[1] = DAI;
        path[2] = MKR;

        uint amountOut = 0.01 * 1e18; // user want
        uint amountInMax = 1e18; // user ready to put
        console.log(mkr.balanceOf(user));
        vm.prank(user);
        uint256[] memory amounts = router.swapTokensForExactTokens(amountOut, amountInMax, path, user, block.timestamp);

        console.log("WETH", amounts[0]);
        console.log("DAI", amounts[1]);
        console.log("MKR", amounts[2]);
        console.log(mkr.balanceOf(user));

        assertEq(mkr.balanceOf(user), amountOut, "MKR balance of user");
    }

    function test_createPair() public {
        ERC20 token = new ERC20("test", "Test", 18);
        address pair = factory.createPair(address(token), WETH);

        address token0 = IUniswapV2Pair(pair).token0();
        address token1 = IUniswapV2Pair(pair).token1();

        if(address(token) < WETH){
            assertEq(token0, address(token), "token 0");
            assertEq(token1, WETH, "token 1");
        }
        else {
            assertEq(token0, WETH, "token 0");
            assertEq(token1, address(token), "token 1");
        }
    }

}

//spot price calculations
// (address token0, address token1) = (pair.token0(), pair.token1());
// (uint112 reserve0, uint112 reserve1, ) = pair.getReserves();

// uint price0in1 = uint(reserve1) * 1e18 / reserve0; // Token0 price in Token1
// uint price1in0 = uint(reserve0) * 1e18 / reserve1; // Token1 price in Token0
