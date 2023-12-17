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

    // TEXTNET
    address private constant pancakeRouterV2T = 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3;
    address private constant pancakeRouterV3T = 0x1b81D678ffb9C0263b24A97847620C99d213eB14;

    // MAINNET
    address private constant pancakeRouterV2M = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address private constant pancakeRouterV3M = 0x1b81D678ffb9C0263b24A97847620C99d213eB14;


    IUniswapV2Router02 constant pancakeRouterV2 = IUniswapV2Router02(pancakeRouterV2T);
    ISwapRouter constant pancakeRouterV3 = ISwapRouter(pancakeRouterV3T);




    address private constant deployer = 0x41ff9AA7e16B8B1a8a8dc4f0eFacd93D02d071c9;
    address pool = 0x41ff9AA7e16B8B1a8a8dc4f0eFacd93D02d071c9; // pool address which will be dynamic
    IERC20 private immutable tok0;
    IERC20 private immutable tok1;


    constructor(){
        tok0 = IERC20(0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd);
        tok1 = IERC20(0x8d008B313C1d6C7fE2982F62d32Da7507cF43551);
    }
    struct FlashCallbackData {
        uint amount0;
        uint amount1;
        address caller;
        //address[2] path;    //[WBNB,CAKE]
        //uint8[3] exchangeRoute; // [0,1,0]
        uint24 fee;
        // inputs which I added
        address token0;
        address token1;
    }


    function FlashloanRequest(
        // inputs as the tutorial
        //address[2] memory _path,
        uint256 _amount0, 
        uint256 _amount1, 
        uint24 _fee, 
        //uint8[3] memory _route,

        // inputs which I added
        address _token0,
        address _token1 
        ) public returns(address) {
        pool = getPool(_token0, _token1, _fee);
        bytes memory data = abi.encode(FlashCallbackData({
            amount0 : _amount0,
            amount1 : _amount1,
            caller : msg.sender,
            //path : _path,
            //exchangeRoute :_route,
            fee : _fee,
            token0 : _token0,
            token1 : _token1
        }));
        
        IUniswapV3Pool(pool).flash(address(this), _amount0, _amount1, data);
        return pool;
    }

    function PancakeV3FlashCallback(uint24 fee0, uint24 fee1, bytes calldata data) external {
        require(msg.sender == address(pool));
        FlashCallbackData memory decoded = abi.decode(data, (FlashCallbackData));

        IERC20 baseToken = IERC20((fee0 > 0) ? decoded.token0 : decoded.token1);
        //uint256 acquiredAmount = (_fee0 > 0) ? decoded.amount0 : decoded.amount1;

        // IERC20 tok0 = SafeERC20(address(decoded.token0));
        // IERC20 tok1 = IERC20(address(decoded.token1));

        if(fee0 > 0){
            TransferHelper.safeApprove(address(decoded.token0),address(this),baseToken.balanceOf(address(this)));
            tok0.transfer(address(pool),decoded.amount0+fee0);
            tok0.transfer(decoded.caller,baseToken.balanceOf(address(this)));
            //SafeERC20.safeTransfer(baseToken,decoded.caller,baseToken.balanceOf(address(this)));
        }else{
            TransferHelper.safeApprove(address(decoded.token1),address(this),baseToken.balanceOf(address(this)));
            SafeERC20.safeTransfer(baseToken,address(pool),decoded.amount1+fee1);
            SafeERC20.safeTransfer(baseToken,decoded.caller,baseToken.balanceOf(address(this)));            
        }
    }

    function getPool(address _token0,address _token1,uint24 _fee) public pure returns(address){
        // IERC20  token0 = IERC20(_token0);
        // IERC20  token1 = IERC20(_token1);
        PoolAddress.PoolKey memory poolKey = PoolAddress.getPoolKey( _token0 , _token1, _fee);
        return PoolAddress.computeAddress(deployer, poolKey);
    }
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