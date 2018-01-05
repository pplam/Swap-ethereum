#!/bin/sh

cd ../..
mkdir bak
mv *_address config.mk bak/

mv demo/ethereum/config.mk .
make
mv *_address config.mk demo/ethereum/

mv bak/* .
rm -rf bak

cd demo/ethereum

ETH_GAS=4700000
ETH_FROM=0x627306090abaB3A6e1400e9345bC60c78a8BEf57
ETH_RPC_HOST=localhost
ETH_RPC_PORT=7545
eval `cat ./swap_address`
chain_id=0x000000000000000000000000000000000000000000000000000000007174756d
seth send \
  --rpc-host $ETH_RPC_HOST \
  --rpc-port $ETH_RPC_PORT \
  -G $ETH_GAS \
  -F $ETH_FROM \
  $CONTRACT_SWAP \
  "registerChain(bytes32)" \
  $chain_id


eval `cat ./authority_address`
prove_sig=0x4c88384a
prefix=network/chain_data/account
for account in 0xf17f52151EbEF6C7334FAD080c5704D77216b732 0xC5fdf4076b8F3A5357c5E395ab970B5B54098Fef 0x821aEa9a577a9b44299B9c15c88cf3087F3b5544
do
  seth send \
    --rpc-host $ETH_RPC_HOST \
    --rpc-port $ETH_RPC_PORT \
    -G $ETH_GAS \
    -F $ETH_FROM \
    $CONTRACT_AUTHORITY \
    "permit(address,address,bytes4)" \
    $account $CONTRACT_SWAP $prove_sig
done
