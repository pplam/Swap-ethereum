-include ./atn_address
-include ./swap_address
-include ./authority_address

ETH_GAS=4700000
ETH_RPC_HOST=localhost
ETH_RPC_PORT=7545
ETH_FROM=0x627306090abaB3A6e1400e9345bC60c78a8BEf57
ETH_CHAIN_ID=0x000000000000000000000000000000000000000000000000657468657265756d
SWAP_REQUIRED_PROOF_NUMBER=1

prove_sig=`./bin/func_sig 'prove(bytes32,uint256,address,uint256)'`
mint_sig=`./bin/func_sig 'mint(address,uint256)'`
burn_sig=`./bin/func_sig 'burn(address,uint256)'`
