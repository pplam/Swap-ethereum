ETH_GAS=4700000
ETH_RPC_PORT=2000
ETH_FROM=`cat ~/.dapp/testnet/2000/config/account`

ATN="0x90f9488adea4282ef2f56f5337c8343f774abd0f"
SWAP='0xfa3410abeaf33cd4514eb18250e15d37d64be32a'
AUTH='0xd027970a7de965d980b99d53d8ece0c839783116'

account1='0x87ed9019c3a23e788eb095ed1e5805dcbd46d0c7'
account2='0x30480776de6664e03763ea79bcc340c527300555'

chain1=`./bin/string2bytes32 'ethereum'`
chain2=`./bin/string2bytes32 'qtum'`

prove_sig=`./bin/func_sig 'prove(bytes32,uint256,address,uint256)'`
mint_sig=`./bin/func_sig 'mint(address,uint256)'`
burn_sig=`./bin/func_sig 'burn(address,uint256)'`
send_data='0x000000000000000000000000000000000000000000000000000000007174756d30480776de6664e03763ea79bcc340c527300555'

install-deps:
	dapp install ATNIO/atn-contracts
build: clean
	dapp build
	cp out/ATN.abi bin/abi/ATN.json
	cp out/Swap.abi bin/abi/Swap.json
	cp out/Authority.abi bin/abi/Authority.json
clean:
	dapp clean
test:
	dapp test


# Deployments
deploy-swap:
	@dapp create Swap --rpc-port $(ETH_RPC_PORT) \
		-G $(ETH_GAS) \
		-F $(ETH_FROM) \
		$(chain1) $(ATN) 2
deploy-authority:
	@dapp create Authority --rpc-port $(ETH_RPC_PORT) \
		-G $(ETH_GAS) \
		-F $(ETH_FROM) \


# Get swap ATN
get-atn:
	seth call --rpc-port $(ETH_RPC_PORT) \
		-G $(ETH_GAS) \
		-F $(ETH_FROM) \
		$(SWAP) \
		"atn()"

register-chain:
	seth send --rpc-port $(ETH_RPC_PORT) \
		-G $(ETH_GAS) \
		-F $(ETH_FROM) \
		$(SWAP) \
		"registerChain(bytes32)" \
		"0x$(chain2)"
check-register:
	seth call --rpc-port $(ETH_RPC_PORT) \
		-G $(ETH_GAS) \
		-F $(ETH_FROM) \
		$(SWAP) \
		"dstChains(bytes32)" \
		"0x$(chain2)"


# Set authorities
set-atn-authority:
	seth send --rpc-port $(ETH_RPC_PORT) \
		-G $(ETH_GAS) \
		-F $(ETH_FROM) \
		$(ATN) \
		"setAuthority(address)" \
		$(AUTH)
set-swap-authority:
	@seth send --rpc-port $(ETH_RPC_PORT) \
		-G $(ETH_GAS) \
		-F $(ETH_FROM) \
		$(SWAP) \
		"setAuthority(address)" \
		$(AUTH)


# Get authorities
get-authority:
	@echo 'ATN:'
	@seth call --rpc-port $(ETH_RPC_PORT) \
		-G $(ETH_GAS) \
		-F $(ETH_FROM) \
		$(ATN) \
		"authority()"
	@echo 'SWAP:'
	@seth call --rpc-port $(ETH_RPC_PORT) \
		-G $(ETH_GAS) \
		-F $(ETH_FROM) \
		$(SWAP) \
		"authority()"


# Permits
permit-mint:
	seth send --rpc-port $(ETH_RPC_PORT) \
		-G $(ETH_GAS) \
		-F $(ETH_FROM) \
		$(AUTH) \
		"permit(address,address,bytes4)" \
		$(SWAP) $(ATN) $(mint_sig)
permit-burn:
	seth send --rpc-port $(ETH_RPC_PORT) \
		-G $(ETH_GAS) \
		-F $(ETH_FROM) \
		$(AUTH) \
		"permit(address,address,bytes4)" \
		$(SWAP) $(ATN) $(burn_sig)
permit-prove:
	@seth send --rpc-port $(ETH_RPC_PORT) \
		-G $(ETH_GAS) \
		-F $(ETH_FROM) \
		$(AUTH) \
		"permit(address,address,bytes4)" \
		$(account1) $(SWAP) $(prove_sig)
	@seth send --rpc-port $(ETH_RPC_PORT) \
		-G $(ETH_GAS) \
		-F $(ETH_FROM) \
		$(AUTH) \
		"permit(address,address,bytes4)" \
		$(account2) $(SWAP) $(prove_sig)


# Check privilages
can-mint:
	@seth call --rpc-port $(ETH_RPC_PORT) \
		-G $(ETH_GAS) \
		-F $(ETH_FROM) \
		$(AUTH) \
		"canCall(address,address,bytes4)" \
		$(SWAP) $(ATN) $(mint_sig)
can-burn:
	@seth call --rpc-port $(ETH_RPC_PORT) \
		-G $(ETH_GAS) \
		-F $(ETH_FROM) \
		$(AUTH) \
		"canCall(address,address,bytes4)" \
		$(SWAP) $(ATN) $(burn_sig)
can-prove:
	@seth call --rpc-port $(ETH_RPC_PORT) \
		-G $(ETH_GAS) \
		-F $(ETH_FROM) \
		$(AUTH) \
		"canCall(address,address,bytes4)" \
		$(account1) $(SWAP) $(prove_sig)
	@seth call --rpc-port $(ETH_RPC_PORT) \
		-G $(ETH_GAS) \
		-F $(ETH_FROM) \
		$(AUTH) \
		"canCall(address,address,bytes4)" \
		$(account2) $(SWAP) $(prove_sig)


# Actions
prove:
	seth send --rpc-port $(ETH_RPC_PORT) \
		-G $(ETH_GAS) \
		-F $(account1) \
		$(SWAP) \
		"prove(bytes32,uint,address,uint)" \
		$(chain2) 3 $(account2) 100
	seth send --rpc-port $(ETH_RPC_PORT) \
		-G $(ETH_GAS) \
		-F $(account2) \
		$(SWAP) \
		"prove(bytes32,uint,address,uint)" \
		$(chain2) 3 $(account2) 100
swap:
	seth send --rpc-port $(ETH_RPC_PORT) \
		-G $(ETH_GAS) \
		-F $(account2) \
		$(SWAP) \
		"swap(bytes32,address,uint)" \
		$(chain2) $(account2) 100
burn:
	seth send --rpc-port $(ETH_RPC_PORT) \
		-G $(ETH_GAS) \
		-F $(ETH_FROM) \
		$(ATN) \
		"burn(address,uint)" \
		$(account2) 100
send:
	seth send --rpc-port $(ETH_RPC_PORT) \
		-G $(ETH_GAS) \
		-F $(account2) \
		$(ATN) \
		"transfer(address,uint,bytes)" \
		$(SWAP) 1 $(send_data)

check-erc:
	@echo 'to_chain:'
	@seth call --rpc-port $(ETH_RPC_PORT) \
		-G $(ETH_GAS) \
		-F $(ETH_FROM) \
		$(SWAP) \
		"to_chain()"
	@echo 'to_addr:'
	@seth call --rpc-port $(ETH_RPC_PORT) \
		-G $(ETH_GAS) \
		-F $(ETH_FROM) \
		$(SWAP) \
		"to_addr()"
	@echo 'len_data:'
	@seth call --rpc-port $(ETH_RPC_PORT) \
		-G $(ETH_GAS) \
		-F $(ETH_FROM) \
		$(SWAP) \
		"len_data()"
	@echo 'tx_data:'
	@seth call --rpc-port $(ETH_RPC_PORT) \
		-G $(ETH_GAS) \
		-F $(ETH_FROM) \
		$(SWAP) \
		"tx_data()"
	# @echo 'r:'
	# @seth call --rpc-port $(ETH_RPC_PORT) \
	# 	-G $(ETH_GAS) \
	# 	-F $(ETH_FROM) \
	# 	$(SWAP) \
	# 	"r()"

# Check balances
get-balance:
	@echo 'swap:'
	@seth call --rpc-port $(ETH_RPC_PORT) \
		-G $(ETH_GAS) \
		-F $(ETH_FROM) \
		$(ATN) \
		"balanceOf(address)" \
		$(SWAP)
	@echo 'personal:'
	@seth call --rpc-port $(ETH_RPC_PORT) \
		-G $(ETH_GAS) \
		-F $(ETH_FROM) \
		$(ATN) \
		"balanceOf(address)" \
		$(ETH_FROM)
	@echo 'account1:'
	@seth call --rpc-port $(ETH_RPC_PORT) \
		-G $(ETH_GAS) \
		-F $(ETH_FROM) \
		$(ATN) \
		"balanceOf(address)" \
		$(account1)
	@echo 'account2:'
	@seth call --rpc-port $(ETH_RPC_PORT) \
		-G $(ETH_GAS) \
		-F $(ETH_FROM) \
		$(ATN) \
		"balanceOf(address)" \
		$(account2)
	@echo 'total supply: '
	@seth call --rpc-port $(ETH_RPC_PORT) \
		$(ATN) "totalSupply()"

get-tx:
	@seth call --rpc-port $(ETH_RPC_PORT) \
		-G $(ETH_GAS) \
		-F $(ETH_FROM) \
		$(SWAP) \
		"outTxs(uint)" \
		0



.PHONY: deploy build install-deps clean test prove check supply mint set-authority
