// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

import "https://github.com/aave/aave-v3-core/blob/master/contracts/flashloan/base/FlashLoanSimpleReceiverBase.sol";
import "https://github.com/aave/aave-v3-core/blob/master/contracts/interfaces/IPoolAddressesProvider.sol";
import "https://github.com/Uniswap/v3-periphery/blob/main/contracts/interfaces/ISwapRouter.sol";
//import "https://github.com/aave/aave-v3-core/blob/master/contracts/dependencies/openzeppelin/contracts/IERC20.sol";

contract SimpleFlashLoan is FlashLoanSimpleReceiverBase {
    //
        address payable owner;
        mapping(address => address) public routerAddress;

        constructor(address _addressProvider)
            FlashLoanSimpleReceiverBase(IPoolAddressesProvider(_addressProvider))
        {
            owner = payable (msg.sender);
        }

            // function withdraw() public {
            //     require(msg.sender == owner,"sender is not the owener");
            //     owner.transfer(address(this).balance);
            // }

            function withdrawToken(address receiver,address _token,uint256 amount) public {
                require(msg.sender == owner,"sender is not the owener");
                IERC20(_token).transfer(receiver,amount);
            }

            function setRouting(address _token, address _router) public {
                require(msg.sender == owner,"sender is not the owener");
                routerAddress[_token] = _router;
            }

            // function blanaceOf(address account,address _token) public view returns (uint256){
            //     return IERC20(_token).balanceOf(account);
            // }

    //
    
    function fn_RequestFlashLoan(address _token, uint256 _amount,address _token1,uint24 feeLev) public {
        address receiverAddress = address(this);
        address asset = _token;
        uint256 amount = _amount;
        bytes memory params = [_token1,feeLev];
        uint16 referralCode = 0;

        POOL.flashLoanSimple(
            receiverAddress,
            asset,
            amount,
            params,
            referralCode
        );
    }
    
        //This function is called after your contract has received the flash loaned amount

    function  executeOperation(
        address asset,
        uint256 amount,
        uint256 premium,
        address initiator,
        bytes calldata params
    )  external override returns (bool) {
        
        //Logic goes here

        // Part 1 Uni (token0 => token1)
        IERC20(asset).approve(routerAddress[asset], amount);

        ISwapRouter.ExactInputSingleParams memory params1 = ISwapRouter
            .ExactInputSingleParams({
                tokenIn: asset,
                tokenOut: params[0],
                fee: params[1],
                recipient: address(this),
                deadline: block.timestamp ,
                amountIn: amount,
                amountOutMinimum: 0,
                sqrtPriceLimitX96: 0
            });

        uint256 amountOut = ISwapRouter(routerAddress[asset]).exactInputSingle(params1);

        // part 2 SUSHI


        // Logic End
        uint256 totalAmount = amount + premium;
        IERC20(asset).approve(address(POOL), totalAmount);

        return true;
    }

    receive() external payable {}
}
interface IERC20{
    function approve(address spender, uint256 amount) external returns(bool);
}
// test: 0xc974b8a40Ad52C85f9FcB14c0127758B2dDFce00