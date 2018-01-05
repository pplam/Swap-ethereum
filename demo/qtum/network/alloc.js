const fs = require('fs')
const Web3 = require('web3')

const accountFile = `${process.env['HOME']}/.dapp/testnet/2000/config/account`
const endpoint = 'http://localhost:2000'
const from = fs.readFileSync(accountFile).toString().trim()

const provider = new Web3.providers.HttpProvider(endpoint)
const web3 = new Web3(provider)

web3.eth.getAccounts((err, accounts) => {
  accounts.forEach((account) => {
    const args = {
      from: '0x' + from,
      to: account,
      value: web3.utils.toWei('100', "ether")
    }
    web3.eth.sendTransaction(args)
  })
})
