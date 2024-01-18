## Linear Arbitrage

LinearRobotFlashSwapBSC smart contract deployed on Binance Smar Chain at 0x88eEC75e30ae40f8A2cDbADb249C7818F33c815c


### path

The input _path defines where to do swaps. 
Since it works in a triangular manner,  each of the _path indexes defines each step.


0: Uniswap V3
1: Pancakeswap V3
2: Pancakeswap V2


**example**:
_path = [0,1] means the first swap will be placed through the Uniswap V3 router. Then the second swap will be placed through the Pancakeswap V3 router.


### pools
Before calling the contract make sure that the router you are going to use has an active pool for the input tokens.

**example**:
If the _token0 is "WBNB" and the _token1 is "BTCB" and the _path is [0,1], there must be an active pool on Uniswap V3 for "WBNB/BTCB" 
and also there must be an active pool on Pancakeswap V3 for "BTCB/WBNB".
Make Sure the fee for all V3 pools are the same and passed to the contract correctly.




### flashpool
The flashpool is a V3 pool where the loan will be taken from.  
The flashpool can't be the same as the pools we want to swap:

**example**:
In case a swap is performing through Uniswap V3 for "WBNB/BTCB" we cannot use the WBNB/BTCB pool as the origin of the loan and it should take the loan from another pool.


**borrow token**:

_borrow is the token address loaned from the flshpool.  since it can be defined as an input, Its optional to borrow either token0 or token1 from the flashpool.


### errors
explanation about Uniswap smart contract error codes: (Pancakeswap error codes are the same)
https://docs.uniswap.org/contracts/v3/reference/error-codes
 
