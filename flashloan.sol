// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

// import "https://github.com/aave/aave-v3-core/blob/master/contracts/flashloan/base/FlashLoanSimpleReceiverBase.sol";
// import "https://github.com/aave/aave-v3-core/blob/master/contracts/interfaces/IPoolAddressesProvider.sol";
// import "https://github.com/aave/aave-v3-core/blob/master/contracts/dependencies/openzeppelin/contracts/IERC20.sol";
//import "https://github.com/Uniswap/v3-core/blob/v1.0.0/contracts/interfaces/IUniswapV3Factory.sol";
//import "https://github.com/Uniswap/v3-periphery/contracts/libraries/TransferHelper.sol";
//import "https://github.com/Uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";
import
    "https://github.com/Uniswap/v3-periphery/blob/main/contracts/interfaces/ISwapRouter.sol";
import
    "https://github.com/Uniswap/v3-periphery/blob/main/contracts/libraries/TransferHelper.sol";

//contract SimpleFlashLoan is FlashLoanSimpleReceiverBase {
contract DDDSimpleFlashLoan {
    address payable owner;
    //ISwapRouter public immutable swapRouter;
    //constructor(){}
    // test address: 0xda9d4f9b69ac6C22e444eD9aF0CfC043b7a7f53f

    constructor(address _addressProvider)
        FlashLoanSimpleReceiverBase(IPoolAddressesProvider(_addressProvider))
    {}

    function fn_RequestFlashLoan(address _token, uint256 _amount) public {
        address receiverAddress = address(this);
        address asset = _token;
        uint256 amount = _amount;
        bytes memory params = "";
        uint16 referralCode = 0;

        POOL.flashLoanSimple(
            receiverAddress, asset, amount, params, referralCode
        );
    }

    /**
     * This function is called after your contract has received the flash loaned amount
     */
    function executeOperation(
        address asset,
        uint256 amount,
        uint256 premium,
        address initiator,
        bytes calldata params
    ) external override returns (bool) {
        //Logic goes here

        uint256 totalAmount = amount + premium;
        IERC20(asset).approve(address(POOL), totalAmount);

        return true;
    }

    /**
     *
     * Addrees
     *
     */

    //address _factory = 0x0227628f3F023bb0B980b67D528571c95c6DaC1c;
    address public address2 = 0x29f2D40B0605204364af54EC677bD022dA425d03; //WBTC
    address public address0 = 0xfFf9976782d46CC05630D1f6eBAb18b2324d6B14; //WETH
    address public address1 = 0xdAC17F958D2ee523a2206206994597C13D831ec7; //USDT 0xdc2E37A79Ee93906c4665e49f82C1b895dFc7092
    address public address3 = 0xFF34B3d4Aee8ddCd6F9AFFFB6Fe49bD371b8a357; //DAI
    address public address4 = 0xda9d4f9b69ac6C22e444eD9aF0CfC043b7a7f53f; // USDC  0x2296282e2e2a4158140E3b4B99855ADa4a06a4B8
    address public address5 = 0xda9d4f9b69ac6C22e444eD9aF0CfC043b7a7f53f; // WETH10 0x1f9840a85d5af5bf1d1762f925bdaddc4201f984
    //address public address6 = 0x1f9840a85d5af5bf1d1762f925bdaddc4201f984 ; //UNI

    // WBTC/DAi 500, 3000,
    // test address 0xD63bc7ff16E680aA43d8cA89DFfFB706b29ba35A

    /*
    function  getQoute() public view returns (uint256){

        return 0;
    }
    */
    function getPoolAD(
        address facAdr,
        address tokenA,
        address tokenB,
        uint24 fee
    ) public view returns (address) {
        return IUniswapV3Factory(facAdr).getPool(tokenA, tokenB, fee);
    }

    function swap(address swapAdr, uint256 amountIn)
        public
        returns (uint256 amountOut)
    {
        return Swap(swapAdr).swapExactInputSingle(amountIn);
    }

    /// @notice swapExactInputSingle swaps a fixed amount of DAI for a maximum possible amount of WETH9
    /// using the DAI/WETH9 0.3% pool by calling `exactInputSingle` in the swap router.
    /// @dev The calling address must approve this contract to spend at least `amountIn` worth of its DAI for this function to succeed.
    /// @param amountIn The exact amount of DAI that will be swapped for WETH9.
    /// @return amountOut The amount of WETH9 received.
    function swapExactInputSingle(
        address routerAddress,
        uint256 amountIn,
        address TokenIn,
        address TokenOut,
        uint24 poolFee
    ) public returns (uint256 amountOut) {
        // msg.sender must approve this contract

        // Transfer the specified amount of DAI to this contract.
        TransferHelper.safeTransferFrom(
            TokenIn, msg.sender, address(this), amountIn
        );

        // Approve the router to spend DAI.
        TransferHelper.safeApprove(TokenIn, address(routerAddress), amountIn);

        // Naively set amountOutMinimum to 0. In production, use an oracle or other data source to choose a safer value for amountOutMinimum.
        // We also set the sqrtPriceLimitx96 to be 0 to ensure we swap our exact input amount.
        ISwapRouter.ExactInputSingleParams memory params = ISwapRouter
            .ExactInputSingleParams({
            tokenIn: TokenIn,
            tokenOut: TokenOut,
            fee: poolFee,
            recipient: msg.sender,
            deadline: block.timestamp,
            amountIn: amountIn,
            amountOutMinimum: 0,
            sqrtPriceLimitX96: 0
        });

        // The call to `exactInputSingle` executes the swap.
        amountOut = ISwapRouter(routerAddress).exactInputSingle(params);
        //amountOut = swapRouter(routerAddress).exactInputSingle(params);
    }

    function doApprove(address tokenAdr, address spenderAdr, uint256 amount)
        public
        returns (bool)
    {
        return IERC20(tokenAdr).approve(spenderAdr, amount);
    }
}

interface IUniswapV3Factory {
    function getPool(address tokenA, address tokenB, uint24 fee)
        external
        view
        returns (address pool);
}

interface Swap {
    function swapExactInputSingle(uint256 amountIn)
        external
        returns (uint256 amountOut);
}
// interface IERC20{
//     function approve(address guy, uint wad) public returns (bool);
// }
