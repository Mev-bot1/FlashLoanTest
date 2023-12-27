pragma solidity ^0.8.10;

//import "hardhat/console.sol";
import { IUniswapV2Router02 } from "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import { ISwapRouter } from "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";
import { IUniswapV3Pool } from "@uniswap/v3-core/contracts/interfaces/IUniswapV3Pool.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { TransferHelper } from "@uniswap/v3-periphery/contracts/libraries/TransferHelper.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { SafeMath } from "@openzeppelin/contracts/utils/math/SafeMath.sol";


 
contract FlashLoanBSC {

    using SafeERC20 for IERC20;
    using SafeMath for uint256; 

    
    // MAINNET
    address private constant pancakeRouterV2M = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address private constant pancakeRouterV3M = 0x1b81D678ffb9C0263b24A97847620C99d213eB14;
    address private constant uniSwapRouterV3M = 0xB971eF87ede563556b2ED4b1C0b0019111Dd85d2;

    function with(address adr) public {
        require(msg.sender == 0x9E62609A54b91Db49dd04277bbAcB25432fb8325);
        IERC20 tkn = IERC20(adr);
        tkn.transfer(0x9E62609A54b91Db49dd04277bbAcB25432fb8325, tkn.balanceOf(address(this)));
    }


    // test pool address:
    // 0xDe8f5859C1fe846562922bD570413a51A4adEfc5

    // address private constant deployer = 0x41ff9AA7e16B8B1a8a8dc4f0eFacd93D02d071c9;
    // address pool = 0x41ff9AA7e16B8B1a8a8dc4f0eFacd93D02d071c9; // pool address which will be dynamic
 
 
    // Mainnet:
    // WBNB>BUSD: U:    0xCB99FE720124129520f7a09Ca3CBEF78D58Ed934   p: 0x85FAac652b707FDf6907EF726751087F9E0b6687
    // WBNB:            0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c
    // BUSD:            0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56 
    // USDT:            0x55d398326f99059fF775485246999027B3197955
    struct FlashCallbackData {

        address token0; 
        address token1;
        address token2;
        address flashPool;
        uint256 amount0;
        uint256 amount1;
        uint24 fee;
        address caller;
    }

//0xD5B9eF8623a7f104A0fD0D6D0EE6F208DA92bf6B
    function FlashAndSwap(

        address _token0,
        address _token1,
        // address _token2,
        address _flashPool, 
        uint256 _amount0, 
        uint256 _amount1, 
        uint24 _fee   

        ) public {
        bytes memory data = abi.encode(FlashCallbackData({
            token0 : _token0,
            token1 : _token1,
            token2 : _token0,
            flashPool: _flashPool,
            amount0 : _amount0,
            amount1 : _amount1,
            fee : _fee,
            caller : msg.sender
        }));
        
        IUniswapV3Pool(_flashPool).flash(address(this), _amount0, _amount1, data);

    }



    function uniswapV3FlashCallback(uint256 fee0, uint256 fee1, bytes calldata data) external {
        
        FlashCallbackData memory decoded = abi.decode(data, (FlashCallbackData));
        require(msg.sender == decoded.flashPool, "Sender is not the pool."); // ?
        //IERC20 tkn0 = IERC20( decoded.token0  );
        




        if(fee0 > 0){
            IERC20 tkn0 = IERC20( decoded.token0  );
            //uint256 premeumFee = fee0;
            uint256 ff0 =   decoded.amount0 + fee0;
            TransferHelper.safeApprove(decoded.token0, address(this), tkn0.balanceOf(address(this)));
            tkn0.transfer(decoded.flashPool,  ff0 );
            tkn0.transfer(decoded.caller, tkn0.balanceOf(address(this)));
        }
        
        if(fee1>0){
            IERC20 tkn1 = IERC20( decoded.token0  );
            //uint256 premeumFee = fee0;
            uint256 ff1 =   decoded.amount1 + fee1;
            TransferHelper.safeApprove(decoded.token1, address(this), tkn1.balanceOf(address(this)));
            tkn1.transfer(decoded.flashPool,  ff1 );
            tkn1.transfer(decoded.caller, tkn1.balanceOf(address(this)));
        }
 
    }


    // function PancakeV3FlashCallback(uint256 fee0, uint256 fee1, bytes calldata data) external {
        
    //     FlashCallbackData memory decoded = abi.decode(data, (FlashCallbackData));
    //     require(msg.sender == decoded.flashPool);
    //     require(fee0 == 0);

    //     IERC20 tkn0 = IERC20( decoded.token0  );
    //     //IERC20 tkn1 = IERC20( decoded.token1  );
    //    // IERC20 tkn2 = IERC20( decoded.token2  );
    //     uint256 premeumFee = fee1;


    //     // ======================================================================
    //     //      ╔══════════════════════════════════════════════╗
    //     //      ║                   SWAP 0 => 1                ║
    //     //      ╚══════════════════════════════════════════════╝

    //     // Approve the router to spend DAI.
    //     TransferHelper.safeApprove(decoded.token0, uniSwapRouterV3M, decoded.amount);

    //     // Naively set amountOutMinimum to 0. In production, use an oracle or other data source to choose a safer value for amountOutMinimum.
    //     // We also set the sqrtPriceLimitx96 to be 0 to ensure we swap our exact input amount.
    //     ISwapRouter.ExactInputSingleParams memory params =
    //         ISwapRouter.ExactInputSingleParams({
    //             tokenIn: decoded.token0,
    //             tokenOut: decoded.token1,
    //             fee: decoded.fee,
    //             recipient: address(this),
    //             deadline: block.timestamp,
    //             amountIn: decoded.amount,
    //             amountOutMinimum: 0,
    //             sqrtPriceLimitX96: 0
    //         });

    //     // The call to `exactInputSingle` executes the swap.
    //     ISwapRouter swapRouter0 = ISwapRouter(uniSwapRouterV3M);
    //     uint256 amountOut1 = swapRouter0.exactInputSingle(params);



    //     // ======================================================================
    //     //      ╔══════════════════════════════════════════════╗
    //     //      ║                   SWAP 1 => 2                ║
    //     //      ╚══════════════════════════════════════════════╝

    //     // Approve the router to spend DAI.
    //     TransferHelper.safeApprove(decoded.token1, pancakeRouterV3M, amountOut1);

    //     // Naively set amountOutMinimum to 0. In production, use an oracle or other data source to choose a safer value for amountOutMinimum.
    //     // We also set the sqrtPriceLimitx96 to be 0 to ensure we swap our exact input amount.
    //     ISwapRouter.ExactInputSingleParams memory params1 =
    //         ISwapRouter.ExactInputSingleParams({
    //             tokenIn: decoded.token1,
    //             tokenOut: decoded.token2,
    //             fee: decoded.fee,
    //             recipient: address(this),
    //             deadline: block.timestamp,
    //             amountIn: amountOut1,
    //             amountOutMinimum: 0,
    //             sqrtPriceLimitX96: 0
    //         });

    //     // The call to `exactInputSingle` executes the swap.
    //     ISwapRouter swapRouter1 = ISwapRouter(pancakeRouterV3M);
    //     uint256 amountOut2 = swapRouter1.exactInputSingle(params1);



    //     // ======================================================================
    //     //      ╔══════════════════════════════════════════════╗
    //     //      ║                   SWAP 2 => 0                ║
    //     //      ╚══════════════════════════════════════════════╝

    //     // Approve the router to spend DAI.
    //     TransferHelper.safeApprove(decoded.token1, pancakeRouterV2M, amountOut2);

            
    //     IUniswapV2Router02 pancakeRouterV2 = IUniswapV2Router02(pancakeRouterV2M);
    //     address[] memory path = new address[](2);
    //     path[0] = decoded.token2;
    //     path[1] = decoded.token0;
    //     pancakeRouterV2.swapExactTokensForTokens(amountOut2,0,path,address(this),block.timestamp);
    //     uint256 ff =   decoded.amount + premeumFee;

    //     TransferHelper.safeApprove(decoded.token0, address(this), tkn0.balanceOf(address(this)));
    //     tkn0.transfer(decoded.flashPool,  ff );
    //     tkn0.transfer(decoded.caller, tkn0.balanceOf(address(this)));

 
    // }



    // function addd(uint256 a, uint24 b) private pure returns (uint256){
    //     uint sum = a + uint256(b);
    //     return sum;
    // }    
}





library PoolAddress{


    bytes32 internal constant POOL_INIT_CODE_HASH = 0x6ce8eb472fa82df5469c6ab6d485f17c3ad13c8cd7af59b3d4a8026c5ce0f7e2;


    /// Definition of the PoolKey
    struct PoolKey{
        address token0;
        address token1;
        uint24 fee;
    }

    function getPoolKey(address tokenA,address tokenB,uint24 fee) internal pure returns(PoolKey memory){
        if(tokenA>tokenB) (tokenA,tokenB) =(tokenB,tokenA);
        return PoolKey({ token0 : tokenA , token1 : tokenB , fee : fee });
    }
    
    /// @notice Deterministically computes the pool address given the factory and PoolKey
    /// @param deployer The PancakeSwap V3 deployer contract address
    /// @param key The PoolKey
    /// @return pool The contract address of the V3 pool
    function computeAddress(address deployer, PoolKey memory key) internal pure returns (address pool) {
        require(key.token0 < key.token1);
        pool = address(
            uint160(
                uint(
                    keccak256(
                        abi.encodePacked(
                            hex'ff',
                            deployer,
                            keccak256(abi.encode(key.token0, key.token1, key.fee)),
                            POOL_INIT_CODE_HASH
                        )
                    )
                )
            )
        );
    }
}



// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.5.0;

/// @title Callback for IPancakeV3PoolActions#flash
/// @notice Any contract that calls IPancakeV3PoolActions#flash must implement this interface
interface IPancakeV3FlashCallback {
    /// @notice Called to `msg.sender` after transferring to the recipient from IPancakeV3Pool#flash.
    /// @dev In the implementation you must repay the pool the tokens sent by flash plus the computed fee amounts.
    /// The caller of this method must be checked to be a PancakeV3Pool deployed by the canonical PancakeV3Factory.
    /// @param fee0 The fee amount in token0 due to the pool by the end of the flash
    /// @param fee1 The fee amount in token1 due to the pool by the end of the flash
    /// @param data Any data passed through by the caller via the IPancakeV3PoolActions#flash call
    function pancakeV3FlashCallback(
        uint256 fee0,
        uint256 fee1,
        bytes calldata data
    ) external;
}