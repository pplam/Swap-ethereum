-include ./atn_address
-include ./swap_address
-include ./authority_address

prove_sig=`./bin/func_sig 'prove(bytes32,uint256,address,uint256)'`
mint_sig=`./bin/func_sig 'mint(address,uint256)'`
burn_sig=`./bin/func_sig 'burn(address,uint256)'`

ETH_GAS=4700000
ETH_CHAIN_ID=0x000000000000000000000000000000000000000000000000000000007174756d
SWAP_REQUIRED_PROOF_NUMBER=1
ETH_FROM=0x`cat ~/.dapp/testnet/2000/config/account`
ETH_RPC_HOST=localhost
ETH_RPC_PORT=2000
