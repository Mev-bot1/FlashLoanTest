/**
 * This file contains script to fetch data and calculate the profit for arbitrage between UniSwap and SushuSwap.
 * It uses regular swap method.
 * The "socketurl" must be made in quicknode dashboard first and paste here.
 */
const { poolABI, quoterABI, SushiSwapRouter } = require('./activeABI.js')
console.log('Hello UNI2')

const USDC = { address: '0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48', symbol: 'USDC', decimal: 6 }
const WETH = { address: '0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2', symbol: 'WETH', decimal: 18 }
const LINK = { address: '0x514910771AF9Ca656af840dff83E8264EcF986CA', symbol: 'LINK', decimal: 18 }


//#region Addresses

//--UNISWAP
const USDCWETH05 = { address: '0x88e6A0c2dDD26FEEb64F039a2c41296FcB3f5640', fee: 500 }
const USDCWETH30 = { address: '0x8ad599c3A0ff1De082011EFDDc58f1908eb6e6D8', fee: 3000 }
const LINKUSDC05 = { address: '0x22fe40544Ac2b387f9A68C6C53b9A8E34e4dd40E', fee: 500 }
const LINKUSDC30 = { address: '0xFAD57d2039C21811C8F2B5D5B65308aa99D31559', fee: 3000 }
const LINKWETH05 = { address: '0x5d4F3C6fA16908609BAC31Ff148Bd002AA6b8c83', fee: 500 }
const LINKWETH30 = { address: '0xa6Cc3C2531FdaA6Ae1A3CA84c2855806728693e8', fee: 3000 }

//#endregion

//--SUSHISWAP
const _USDCWETH05 = { address: '0x35644Fb61aFBc458bf92B15AdD6ABc1996Be5014', fee: 500 }
const _USDCWETH30 = { address: '0x763d3b7296e7C9718AD5B058aC2692A19E5b3638', fee: 3000 }
//const _LINKUSDC05 = { address: '0x22fe40544Ac2b387f9A68C6C53b9A8E34e4dd40E', fee: 500 }
//const _LINKUSDC30 = { address: '0x763d3b7296e7C9718AD5B058aC2692A19E5b3638', fee: 3000 }
const _LINKWETH05 = { address: '0xD60A872163A6A9C7b157dA621768c8C065778432', fee: 500 }
const _LINKWETH30 = { address: '0xA5F43B0EBaEfbEd5B1f1bFc809AF15254EA1e9c4', fee: 3000 }




let socketurl = 'wss://alpha-lively-model.quiknode.pro/9a9a3a619e9da7c8e5d162107c1378a8b6f44fdb/';
const { ethers } = require('ethers');
const provider = new ethers.WebSocketProvider(socketurl)
const signer = new ethers.Wallet('0xf4a2b939592564feb35ab10a8e04f6f2fe0943579fb3c9c33505298978b74893', provider)
const defaultUSDCAmount = 10000
const defaultWETHAmount = 4
const defaultFeeLevel = 500

const quoterContractUNI = new ethers.Contract('0xb27308f9F90D607463bb33eA1BeBb41C27CE5AB6', quoterABI, signer)
const quoterContractSushi = new ethers.Contract('0xd9e1cE17f2641f24aE83637ab66a2cca9C378B9F', SushiSwapRouter, signer)



async function UNItoSUSHI(_tokenIn, _tokenOut, amount, feeLevel) {
      const quoteUNI = await quoterContractUNI.quoteExactInputSingle.staticCall(
            _tokenIn.address,
            _tokenOut.address,
            feeLevel,
            BigInt(amount * (10 ** _tokenIn.decimal)),
            0
      )

      let quoteSUH = await quoterContractSushi.getAmountsOut(quoteUNI, [_tokenOut.address, _tokenIn.address])

      let profit = (Number(quoteSUH[1]) / (10 ** _tokenIn.decimal)) - amount
      console.log(` --- profit    UNI(${_tokenIn.symbol} > ${_tokenOut.symbol}) > SUSHI(${_tokenOut.symbol} > ${_tokenIn.symbol}) :    ${profit}`)
}


async function SUSHItoUNI(_tokenIn, _tokenOut, amount, feeLevel) {
      let quoteSUH = await quoterContractSushi.getAmountsOut(BigInt(amount * (10 ** _tokenIn.decimal)), [_tokenIn.address, _tokenOut.address])
      const quoteUNI = await quoterContractUNI.quoteExactInputSingle.staticCall(
            _tokenOut.address,
            _tokenIn.address,
            feeLevel,
            quoteSUH[1],
            0
      )
      let profit = (Number(quoteUNI) / (10 ** _tokenIn.decimal)) - amount
      console.log(` --- profit    SUSHI(${_tokenIn.symbol} > ${_tokenOut.symbol}) > UNI(${_tokenOut.symbol} > ${_tokenIn.symbol}) :    ${profit}`)
}


function calc() {

      UNItoSUSHI(USDC, WETH, defaultUSDCAmount, defaultFeeLevel)
      UNItoSUSHI(WETH, USDC, defaultWETHAmount, defaultFeeLevel)
      SUSHItoUNI(USDC, WETH, defaultUSDCAmount, defaultFeeLevel)
      SUSHItoUNI(WETH, USDC, defaultWETHAmount, defaultFeeLevel)
}

calc()





async function comp() {
      var quoterContract = new ethers.Contract('0xb27308f9F90D607463bb33eA1BeBb41C27CE5AB6', quoterABI, signer)

      const quoteLW05A = await quoterContract.quoteExactInputSingle.staticCall(
            LINK.address,
            WETH.address,
            feeLevel,
            BigInt(amount * 10 ** 18),
            0
      )
      console.log('quote5 A : ' + quoteLW05A)

      const quoteLW05B = await quoterContract.quoteExactInputSingle.staticCall(
            WETH.address,
            USDC.address,
            feeLevel,
            quoteLW05A,
            0
      )

      console.log('')
      console.log('quote5 B : ' + quoteLW05B)

      const quoteLW05C = await quoterContract.quoteExactInputSingle.staticCall(
            USDC.address,
            LINK.address,
            feeLevel,
            quoteLW05B,
            0
      )

      console.log('')
      console.log('quote5 C : ' + quoteLW05C)
      console.log('')
      let FinalBalance = ReadablePrice(quoteLW05C, WETH.decimal)
      console.log('Final Balance : ' + FinalBalance)
      console.log('')
      let Profit = (Number(FinalBalance) - amount)
      console.log(' Profit:  ' + Profit)
      record(Profit)
}

async function fetchPrice() {
      const provider = new ethers.WebSocketProvider(socketurl)

      var signer = new ethers.Wallet('0xf4a2b939592564feb35ab10a8e04f6f2fe0943579fb3c9c33505298978b74893', provider)

      const UWcontract05 = new ethers.Contract(USDCWETH05.address, poolABI, signer)
      const LUcontract05 = new ethers.Contract(LINKUSDC05.address, poolABI, signer)
      const LWcontract05 = new ethers.Contract(LINKWETH05.address, poolABI, signer)
      const UWcontract30 = new ethers.Contract(USDCWETH30.address, poolABI, signer)
      const LUcontract30 = new ethers.Contract(LINKUSDC30.address, poolABI, signer)
      const LWcontract30 = new ethers.Contract(LINKWETH30.address, poolABI, signer)

      const UW05sl0 = Kick(await UWcontract05.slot0(), USDC.decimal, WETH.decimal)
      const LU05sl0 = Kick(await LUcontract05.slot0(), LINK.decimal, USDC.decimal)
      const LW05sl0 = Kick(await LWcontract05.slot0(), LINK.decimal, WETH.decimal)

      const UW30sl0 = Kick(await UWcontract30.slot0(), USDC.decimal, WETH.decimal)
      const LU30sl0 = Kick(await LUcontract30.slot0(), LINK.decimal, USDC.decimal)
      const LW30sl0 = Kick(await LWcontract30.slot0(), LINK.decimal, WETH.decimal)

      console.log('')


      console.log('----    0.05%')
      console.log('USDC WETH: ' + UW05sl0)
      console.log('Link USDC: ' + LU05sl0)
      console.log('LINK WETH: ' + LW05sl0)
      console.log('')
      console.log('Link inUW: ' + Number(UW05sl0) * Number(LU05sl0))
      console.log('Link inWU: ' + Number(LW05sl0) / Number(UW05sl0))

      console.log('')
      console.log('')


      console.log('----    0.3%')
      console.log('USDC WETH: ' + UW30sl0)
      console.log('Link USDC: ' + LU30sl0)
      console.log('LINK WETH: ' + LW30sl0)
      console.log(' ')
      console.log('Link inUW: ' + Number(UW30sl0) * Number(LU30sl0))
      console.log('Link inWU: ' + Number(LW30sl0) / Number(UW30sl0))



}


function ReadablePrice(inp, token0Decimal) {
      const sqrtPriceX96 = Number(inp)
      var res = (sqrtPriceX96) / (10 ** token0Decimal)
      return res
}
function Kick(inp, token0Decimal, token1Decimal) {
      const sqrtPriceX96 = Number(inp[0])
      const base = (2 ** 192) * ((10 ** token1Decimal) / (10 ** token0Decimal))
      var res = (sqrtPriceX96 ** 2) / base
      return res
}

//fetchPrice()
const go = () => {
      setInterval(() => {
            take()
      }, 10000);
}
//go(0)


var fs = require("fs");


function record(inp) {
      const tn = new Date();
      var stmp = tn.getHours() + ' : ' + tn.getMinutes() + ' : ' + tn.getSeconds() + '  ------       '
      var existing = fs.readFileSync('arbit.txt', 'utf8')
      fs.writeFile('arbit.txt', existing + '\n' + stmp + inp, (err, data) => {
            // console.log('startDecode => writing the file')
            // console.log(err)
            // console.log(data)
      });
}



///
