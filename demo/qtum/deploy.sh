#!/bin/sh

cd ../..
mkdir bak
mv *_address config.mk bak/

mv demo/qtum/config.mk .
make
mv *_address config.mk demo/qtum/

mv bak/* .
rm -rf bak

cd demo/qtum

ETH_GAS=4700000
ETH_FROM=0x`cat ~/.dapp/testnet/2000/config/account`
ETH_RPC_HOST=localhost
ETH_RPC_PORT=2000
eval `cat ./swap_address`
chain_id=0x000000000000000000000000000000000000000000000000657468657265756d
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
for i in {1..3}
do
  account=`cat $prefix$i`
  seth send \
    --rpc-host $ETH_RPC_HOST \
    --rpc-port $ETH_RPC_PORT \
    -G $ETH_GAS \
    -F $ETH_FROM \
    $CONTRACT_AUTHORITY \
    "permit(address,address,bytes4)" \
    $account $CONTRACT_SWAP $prove_sig
done
