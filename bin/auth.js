const Web3 = require('web3')
const abi = require('./abi/Authority.json')
const atnabi = require('./abi/ATN.json')

const endpoint = 'http://localhost:2000'

const provider = new Web3.providers.HttpProvider(endpoint)
const web3 = new Web3(provider)

const SWAP = '0x08a795ac3206293657e2142c149d445cf8dd0dd3'
const ATN = "0x90f9488adea4282ef2f56f5337c8343f774abd0f"
const AUTH = "0x91bad80714b5491ddf216a12986056eb97f4fd12"
const mint_sig = '0x40c10f19'
const account1='0x87ed9019c3a23e788eb095ed1e5805dcbd46d0c7'

const Auth = web3.eth.contract(abi)
const auth = Auth.at(AUTH)
const Atn = web3.eth.contract(atnabi)
const atn = Atn.at(ATN)

// const wl = auth.whiteList()
const cancall = auth.canCall(account1, ATN, mint_sig)
const atnAuth = atn.authority()

console.log(`Authority: ${AUTH}, account ${account1} can mint: ${cancall}`)
console.log(`ATN authority: ${atnAuth}`)
console.log(`ATN: ${ATN}`)
