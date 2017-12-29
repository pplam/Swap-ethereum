const Web3 = require('web3')
const abi = require('./abi/ATN.json')
const abii = require('./abi/Swap.json')

const endpoint = 'http://localhost:2000'

const provider = new Web3.providers.HttpProvider(endpoint)
const web3 = new Web3(provider)

const ATN = '0x90f9488adea4282ef2f56f5337c8343f774abd0f'
const SWAP = '0xfa3410abeaf33cd4514eb18250e15d37d64be32a'

const gas = 470000
const from = '0x30480776de6664e03763ea79bcc340c527300555'
const data = '0x000000000000000000000000000000000000000000000000000000007174756d30480776de6664e03763ea79bcc340c527300555'

const atn = new web3.eth.Contract(abi, ATN, {from, gas})

const swap = new web3.eth.Contract(abii, SWAP, {from, gas})
// const swap = Swap.at(SWAP)

atn.methods.transfer(SWAP,1,data).send().then((res) => {
  console.log(res)

  swap.getPastEvents('SwapTx', console.log)//.then(console.log)
})

// console.log('++++++++++++++++++++++++++++++')
// swap.methods.swap_from().call().then(console.log);
// swap.methods.len_data().call().then(console.log)
// swap.methods.tx_data().call().then(console.log)
// swap.methods.to_chain().call().then(console.log)
// swap.methods.to_addr().call().then(console.log)
// console.log('++++++++++++++++++++++++++++++')


// const logs = atn.allEvents()
// logs.watch((error, result) => {
//   console.log('===================')
//   console.log('Error: ', error)
//   console.log('Result: ', result)
//   console.log('===================')
//   console.log()
// })
