const Web3 = require('web3')
const abi = require('./abi/Swap.json')

const endpoint = 'http://localhost:2000'
const SWAP = ''

const provider = new Web3.providers.HttpProvider(endpoint)
const web3 = new Web3(provider)

const Swap = web3.eth.contract(abi)
const swap = Swap.at(SWAP)



// const num = swap.requiredProofNumber.call().toString()
// console.log('requiredProofNumber: ', num)
// process.stdout.write(num)

const logs = swap.allEvents()
logs.watch((error, result) => {
  console.log('===================')
  console.log('Error: ', error)
  console.log('Result: ', result)
  console.log('===================')
  console.log()
})
