const Web3 = require('web3')
const config = require('./config')
const abi = require('./Swap.abi.json')

class Worker {
  constructor(opts = {}) {
    this.id = opts.id
    this.name = opts.name
    this.endpoint = opts.endpoint

    const httpRegex = /^http:\/\//i
    const wsRegex = /^ws:\/\//i
    if (httpRegex.test(opts.endpoint)) {
      const provider = new Web3.providers.HttpProvider(endpoint)
      const web3 = new Web3(provider)
      // const provider = new Web3.providers.HttpProvider(opts.endpoint)
      // this.web3 = new Web3(provider)
    } else if (wsRegex.test(opts.endpoint)) {
      this.web3 = new Web3(opts.endpoint)
    }

    // this.swap = new this.web3.eth.Contract(abi, opts.swap, {
    //   gas: opts.gas || 400000,
    //   from: opts.account
    // })
    this.swap = web3.eth.contract(abi).at(opts.swap)
  }

  listen() {
    return new Promise((resolve, reject) => {
      // this.swap.events.SwapTx((e) => {
      //   const res = e.returnValue
      //   res.from_chain = this.id
      //   resolve(res)
      // })
      this.swap.SwapTx((e) => {
        const res = e.returnValue
        res.from_chain = this.id
        resolve(res)
      })
    })
  }

  prove(proof) {
    console.log(proof)
  }
}

const workers = {}

function handler(e) {
  const toChain = e.to_chain
  delete e.toChain

  const target = workers[toChain]
  target.prove(e)
}

config.forEach((c) => {
  const worker = new Worker(c)
  workers[c.id] = worker
})

Object.getOwnPropertyNames(workers).forEach((id) => {
  workers[id].listen().then(handler)
})
