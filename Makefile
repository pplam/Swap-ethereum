ETH_GAS=4700000
ETH_RPC_PORT=2000
ETH_FROM=`cat ~/.dapp/testnet/2000/config/account`

atn_addr="0x90f9488adea4282ef2f56f5337c8343f774abd0f"
swap_addr='0x302dfda75eabae5de35a413393e8028abbb30167'

account1=$(ETH_FROM)
account2='0x87ed9019c3a23e788eb095ed1e5805dcbd46d0c7'
account3='0x30480776de6664e03763ea79bcc340c527300555'

install-deps:
	dapp install ATNIO/atn-contracts

build: clean
	dapp build

clean:
	dapp clean

deploy:
	dapp create Swap --rpc-port $(ETH_RPC_PORT) \
		-G $(ETH_GAS) \
		-F $(ETH_FROM) \
		"ethereum" $(atn_addr) 1

test:
	dapp test

prove:
	seth send --rpc-port $(ETH_RPC_PORT) \
		-G $(ETH_GAS) \
		-F $(ETH_FROM) \
		$(swap_addr) \
		"prove(string,uint,address,uint)" \
		"qtum" 1 $(account2) 100

check:
	seth call --rpc-port $(ETH_RPC_PORT) \
		-G $(ETH_GAS) \
		-F $(ETH_FROM) \
		$(atn_addr) \
		"balanceOf(address)" \
		$(account2)

supply:
	seth call --rpc-port $(ETH_RPC_PORT) \
		$(atn_addr) \
		"totalSupply()" \

mint:
	seth send --rpc-port $(ETH_RPC_PORT) \
		-G $(ETH_GAS) \
		-F $(ETH_FROM) \
		$(atn_addr) \
		"mint(address,uint)" \
		$(account2) 100

.PHONY: deploy build install-deps clean test prove check supply mint
