-include ./atn_address
-include ./swap_address
-include ./authority_address

ETH_GAS=4700000
ETH_RPC_HOST=localhost
ETH_RPC_PORT=8080
ETH_FROM=0xa0fc22b2d6d1cf06312134ac90fa4b87ee403842
ETH_CHAIN_ID=0x000000000000000000000000000000000000000000000000000000007174756d
SWAP_REQUIRED_PROOF_NUMBER=1

prove_sig=`./bin/func_sig 'prove(bytes32,uint256,address,uint256)'`
mint_sig=`./bin/func_sig 'mint(address,uint256)'`
burn_sig=`./bin/func_sig 'burn(address,uint256)'`
