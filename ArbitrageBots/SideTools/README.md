### Instantiation

To calculate swap returns you can instantiate these contracts and execute the function for swap.
the "toExecute" field of each JSON file defines which function should be called.


### Calculation

starting with the token0 and token1 in the first contract. after the result of the function (which represents the amountOut) comes, use it as the input amount for the nest function.


### Note

In order to get quotes without execution, the function must be triggered as a "StaticCall" which simulates the call but will not execute it on the blockchain.
