## Triangular Arbitrage

RobotFlashSwapBSC smart contract deployed on Binance Smar Chain at 0xb4750167Fb0DCD7d818f35D71fbba3310396cC3c


### path

The input _path defines where to do swaps. 
Since it works in a triangular manner,  each of the _path indexes defines each step.


0: Uniswap V3
1: Pancakeswap V3
2: Pancakeswap V2


**example**:
_path = [0,1,2] means the first swap will be placed through the Uniswap V3 router. Then the second swap will be placed through the Pancakeswap V3 router,
and the third swap will be placed through the Pancakeswap V2 router.


### pools
Before calling the contract make sure that the router you are going to use has an active pool for the input tokens.

**example**:
If the _token0 is "WBNB" and the _token1 is "BTCB" and the _token2 is "USDT"  and the _path is [0,1,2], there must be an active pool on Uniswap V3 for "WBNB/BTCB" 
and also there must be an active pool on Pancakeswap V3 for "BTCB/USDT" and also there must be an active pool on Pancakeswap V2 for "USDT/WBNB".
Make Sure the fee for all V3 pools are the same and passed to the contract correctly.




### flashpool
The flashpool is a V3 pool where the loan will be taken from. The pool contract .token0 must be equal to the token we want to borrow. 
The flashpool can't be the same as the pools we want to swap:

**example**:
In case a swap is performing through Uniswap V3 for "WBNB/BTCB" we cannot use the WBNB/BTCB pool as the origin of the loan and it should take the loan from another pool where its token0 is WBNB.



### errors
explanation about Uniswap smart contract error codes: (Pancakeswap error codes are the same)
https://docs.uniswap.org/contracts/v3/reference/error-codes
 
