ETH_GAS=4700000
ETH_RPC_PORT=2000
ETH_FROM=`cat ~/.dapp/testnet/2000/config/account`

all: clean install-deps build deploy

install-deps:
	dapp install ds-auth

build: clean
	dapp build

clean:
	dapp clean

deploy:
	dapp create Swap --rpc-port $(ETH_RPC_PORT) -G $(ETH_GAS) -F $(ETH_FROM)

test:
	dapp test

.PHONY: deploy build install-deps clean test all
