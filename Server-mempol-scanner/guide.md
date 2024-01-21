## Part 1: Retrieving tx data.


The address of pancakeswap router: "0x10ED43C718714eb63d5aA57B78B54704E256024E"

wsProvider = new ethers.WebSocketProvider("wss://mainnet.infura.io/ws/v3/a427de2cb7934d87b56cadcd4e4db704"); //a427de2cb7934d87b56cadcd4e4db704 => is API key. Replace with your API key (Generate a new API key on your dashboard specified for the Binance Smar chain).

baseUrl : "https://api.bscscan.com/api"

binanceApiKey = E5HBPC633PQYABW64DEH3ZFK6RPHCWUXGT

wsProvider.on('pending', async (tx) => {    //Your code here....    })

example of code:

const txInfo = await wsProvider.getTransaction(tx)

// Example of the output:

`
{
   "blockNumber": "13818584",
   "timeStamp": "1639689761",
   "hash": "0xbcb35488fc97f6567a7bfe4b48e153ba410b59ab2f4a68bd997877ba4b1c6c11",
   "from": "0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2",
   "to": "0x10ED43C718714eb63d5aA57B78B54704E256024E",
   "value": "250000000000000000",
   "contractAddress": "0x10ED43C718714eb63d5aA57B78B54704E256024E",
   "input": "",
   "type": "call",
   "gas": "172070",
   "gasUsed": "23974",
   "traceId": "0_0",
   "isError": "1",
   "errCode": "",
   "data": "0xfb3bdb4100000000000000000000000000000000000000000000003635c9adc5dea000000000000000000000000000000000000000000000000000000000000000000080000000000000000000000000749b4ef53854e2d80c99eb70c4ec89d28b8994410000000000000000000000000000000000000000000000000000000065ad243d0000000000000000000000000000000000000000000000000000000000000002000000000000000000000000bb4cdb9cbd36b01bd1cbaebf2de08d9173bc095c000000000000000000000000ea7cded1cc03f921bcb94dd699dc5fa6c301e789"


}


`


## Part 2: Decoding tx data.


var DATA;
// check  if its for our target router
 if (txInfo.to == '0x10ED43C718714eb63d5aA57B78B54704E256024E') {  


  DATA = analyze(txInfo) 

  // Do part 3


}


analyze( data ){

            const deData = abiDecoder.decodeMethod(data.data)  // initial decode
            let second = deData.params[1].value[0];            // used to encode
            let secDecode = abiDecoder.decodeMethod(second)    // use that method to decode.

            return ({ txData: secDecode.params[0].value, txHash: data.hash, txValue: data.value })

}




## Part 3: Quoting price.

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






