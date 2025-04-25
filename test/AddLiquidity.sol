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
import {UNISWAP_V2_PAIR_DAI_WETH} from "../src/Constants.sol";

contract AddLiquidtyTest is Test {
    IWETH private constant weth = IWETH(WETH);
    IERC20 private constant dai = IERC20(DAI);

    IUniswapV2Router02 private constant router =
        IUniswapV2Router02(UNISWAP_V2_ROUTER_02);
    IUniswapV2Pair private constant pair =
        IUniswapV2Pair(UNISWAP_V2_PAIR_DAI_WETH);

    address private constant user = address(100);
    function setUp() public {
        deal(user, 100*1e18);
        vm.startPrank(user);
        weth.deposit{value: 100*1e18}();
        weth.approve(address(router), type(uint256).max);
        vm.stopPrank();
        
        deal(DAI, user, 1000000 * 1e18);
        vm.startPrank(user);
        dai.approve(address(router), type(uint256).max);
        vm.stopPrank();
    }

    function test_addLiquidity() public {
        vm.prank(user);

        (uint amountA, uint amountB, uint liquidity)=router.addLiquidity(WETH, DAI, 100 * 1e18, 1e6 * 1e18, 1, 1, user, block.timestamp);

        console.log(amountA, amountB, liquidity);
        assertGt(pair.balanceOf(user), 0, "Lp = 0");
    }

}