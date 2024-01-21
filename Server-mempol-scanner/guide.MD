## Part 1: Retrieving tx data.


The address of pancakeswap router: "0x10ED43C718714eb63d5aA57B78B54704E256024E"

wsProvider = new ethers.WebSocketProvider("wss://mainnet.infura.io/ws/v3/a427de2cb7934d87b56cadcd4e4db704"); //a427de2cb7934d87b56cadcd4e4db704 => is API key. Replace with your API key (Generate a new API key on your dashboard specified for the Binance Smar chain).

baseUrl : "https://api.bscscan.com/api"

binanceApiKey = E5HBPC633PQYABW64DEH3ZFK6RPHCWUXGT

wsProvider.on('pending', async (tx) => {    //Your code here....    })

example of code:

const txInfo = await wsProvider.getTransaction(tx)




## Part 2: deciding tx data.


var DATA;
 if (txInfo.to == '0x68b3465833fb72A70ecDF485E0e4C7bD8665Fc45') { 
  DATA = analyze(txInfo) 
  // Do part 3
}


analyze( data ){

            const deData = abiDecoder.decodeMethod(data.data)  // initial decode
            let second = deData.params[1].value[0];            // used to encode
            let secDecode = abiDecoder.decodeMethod(second)    // use that method to decode.

            return ({ txData: secDecode.params[0].value, txHash: data.hash, txValue: data.value })

}




## Part 3: fetching price.

import Quoter_V2 from "https://github.com/Mev-bot1/FlashLoanTest/blob/main/ArbitrageBots/ServerTools/contractAddress.json"

params =    {
                tokenIn: DATA.tokenIn,
                tokenOut: DATA.tokenOut,
                amountIn: DATA.amountIn,               
                fee: DATA.fee,
                sqrtPriceLimitX96: DATA.sqrtPriceLimitX96
            }


var quote = Quoter_V2.quoteExactInputSingle( params ); 

//Note: quote[0]  is the amount out. quote[1] is the price after the swap operation is done.

var sqrtPriceX96After = quote[1];

// Convert the sqrtPriceX96After to regular price.






