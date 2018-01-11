include ./config.mk


.PHONY: all
all:
	@echo '+++++++++++++++++++++++++++++[Compile]++++++++++++++++++++++++++++++++'
	$(MAKE) build >/dev/null 2>&1
	@echo
	@echo '+++++++++++++++++++++++++++++[Deployment]++++++++++++++++++++++++++++++++'
	$(MAKE) deploy-all
	$(eval include atn_address)
	$(eval include swap_address)
	$(eval include authority_address)
	@echo
	@echo '+++++++++++++++++++++++++++[Set-Authorities]+++++++++++++++++++++++++++++'
	$(MAKE) set-authority-all
	@echo
	@echo '+++++++++++++++++++++++++++[Set-Perissions]++++++++++++++++++++++++++++++'
	$(MAKE) permit-swap-all
	@echo
	@echo '========================================================================='
	@echo 'Next steps:'
	@echo '1. Register swap destination chains by: make register-chain'
	@echo '2. Permit accounts to prove on swap by: make permit-prove'


.PHONY: install-deps build clean test
install-deps:
	@dapp install ATNIO/atn-contracts
build: clean
	@dapp build >/dev/null 2>&1
	@cp out/Swap.abi worker/Swap.abi.json
clean:
	@dapp clean
test:
	@dapp test


# Deployments
.PHONY: deploy-all deploy-atn deploy-swap deploy-authority
deploy-all:
	@echo '.................................................................'
	@echo 'Deploying ATN...'
	$(MAKE) deploy-atn
	$(eval include atn_address)
	@echo '.................................................................'
	@echo 'Deploying SWAP...'
	$(MAKE) deploy-swap
	@echo '.................................................................'
	@echo 'Deploying AUTHORITY...'
	$(MAKE) deploy-authority
deploy-atn:
	@dapp create ATN \
		--rpc-host $(ETH_RPC_HOST) \
		--rpc-port $(ETH_RPC_PORT) \
		-G $(ETH_GAS) \
		-F $(ETH_FROM) \
		| grep '^0[xX].*' \
		| sed "s/\(0[xX][0-9a-fA-F]\{40\}\)/CONTRACT_ATN=\1/" \
		| xargs echo > ./atn_address
deploy-swap:
	@dapp create Swap \
		--rpc-host $(ETH_RPC_HOST) \
		--rpc-port $(ETH_RPC_PORT) \
		-G $(ETH_GAS) \
		-F $(ETH_FROM) \
		$(ETH_CHAIN_ID) $(CONTRACT_ATN) $(SWAP_REQUIRED_PROOF_NUMBER) \
		| grep '^0[xX].*' \
		| sed "s/\(0[xX][0-9a-fA-F]\{40\}\)/CONTRACT_SWAP=\1/" \
		| xargs echo > ./swap_address
deploy-authority:
	@dapp create Authority \
		--rpc-host $(ETH_RPC_HOST) \
		--rpc-port $(ETH_RPC_PORT) \
		-G $(ETH_GAS) \
		-F $(ETH_FROM) \
		| grep '^0[xX].*' \
		| sed "s/\(0[xX][0-9a-fA-F]\{40\}\)/CONTRACT_AUTHORITY=\1/" \
		| xargs echo > ./authority_address


# Set authorities
.PHONY: set-authority-all set-authority-atn set-authority-swap
set-authority-all: set-authority-atn set-authority-swap
set-authority-atn:
	@echo '.................................................................'
	@echo 'Setting ATN authority...'
	@seth send \
		--rpc-host $(ETH_RPC_HOST) \
		--rpc-port $(ETH_RPC_PORT) \
		-G $(ETH_GAS) \
		-F $(ETH_FROM) \
		$(CONTRACT_ATN) \
		"setAuthority(address)" \
		$(CONTRACT_AUTHORITY)
set-authority-swap:
	@echo '.................................................................'
	@echo 'Setting SWAP authority...'
	@seth send \
		--rpc-host $(ETH_RPC_HOST) \
		--rpc-port $(ETH_RPC_PORT) \
		-G $(ETH_GAS) \
		-F $(ETH_FROM) \
		$(CONTRACT_SWAP) \
		"setAuthority(address)" \
		$(CONTRACT_AUTHORITY)


# Get authorities
.PHONY: check-authorities
check-authorities:
	@echo 'Authority of ATN:'
	@seth call \
		--rpc-host $(ETH_RPC_HOST) \
		--rpc-port $(ETH_RPC_PORT) \
		-G $(ETH_GAS) \
		-F $(ETH_FROM) \
		$(CONTRACT_ATN) \
		"authority()"
	@echo 'Authority of SWAP:'
	@seth call \
		--rpc-host $(ETH_RPC_HOST) \
	  --rpc-port $(ETH_RPC_PORT) \
		-G $(ETH_GAS) \
		-F $(ETH_FROM) \
		$(CONTRACT_SWAP) \
		"authority()"


# Register swap destination chain
.PHONY: register-chain check-register
register-chain:
	@read -p 'Enter chain name: ' chain_name; \
	chain_id=0x`./bin/string2bytes32 $$chain_name`; \
	seth send \
		--rpc-host $(ETH_RPC_HOST) \
		--rpc-port $(ETH_RPC_PORT) \
		-G $(ETH_GAS) \
		-F $(ETH_FROM) \
		$(CONTRACT_SWAP) \
		"registerChain(bytes32)" \
		$$chain_id
check-register:
	@read -p 'Enter chain id: ' chain_id; \
	chain_id=0x`./bin/string2bytes32 $$chain_id`; \
	seth call \
		--rpc-host $(ETH_RPC_HOST) \
		--rpc-port $(ETH_RPC_PORT) \
		-G $(ETH_GAS) \
		-F $(ETH_FROM) \
		$(CONTRACT_SWAP) \
		"dstChains(bytes32)" \
		$$chain_id


# Set permissions
.PHONY: permit-swap-all permit-mint permit-burn permit-prove
permit-swap-all: permit-mint permit-burn
permit-mint:
	@echo '.................................................................'
	@echo 'Setting mint permissoin to SWAP...'
	@seth send \
		--rpc-host $(ETH_RPC_HOST) \
		--rpc-port $(ETH_RPC_PORT) \
		-G $(ETH_GAS) \
		-F $(ETH_FROM) \
		$(CONTRACT_AUTHORITY) \
		"permit(address,address,bytes4)" \
		$(CONTRACT_SWAP) $(CONTRACT_ATN) $(mint_sig)
permit-burn:
	@echo '.................................................................'
	@echo 'Setting burn permissoin to SWAP...'
	@seth send \
		--rpc-host $(ETH_RPC_HOST) \
		--rpc-port $(ETH_RPC_PORT) \
		-G $(ETH_GAS) \
		-F $(ETH_FROM) \
		$(CONTRACT_AUTHORITY) \
		"permit(address,address,bytes4)" \
		$(CONTRACT_SWAP) $(CONTRACT_ATN) $(burn_sig)
permit-prove:
	@read -p 'Enter account: ' account; \
	seth send \
		--rpc-host $(ETH_RPC_HOST) \
		--rpc-port $(ETH_RPC_PORT) \
		-G $(ETH_GAS) \
		-F $(ETH_FROM) \
		$(CONTRACT_AUTHORITY) \
		"permit(address,address,bytes4)" \
		$$account $(CONTRACT_SWAP) $(prove_sig)


# Check privilages
.PHONY: check-swap-permissions can-mint can-burn can-prove
check-swap-permissoins: can-mint can-burn
can-mint:
	@echo 'Mint permission of SWAP:'
	@seth call \
		--rpc-host $(ETH_RPC_HOST) \
		--rpc-port $(ETH_RPC_PORT) \
		-G $(ETH_GAS) \
		-F $(ETH_FROM) \
		$(CONTRACT_AUTHORITY) \
		"canCall(address,address,bytes4)" \
		$(CONTRACT_SWAP) $(CONTRACT_ATN) $(mint_sig)
can-burn:
	@echo 'Burn permission of SWAP:'
	@seth call \
		--rpc-host $(ETH_RPC_HOST) \
		--rpc-port $(ETH_RPC_PORT) \
		-G $(ETH_GAS) \
		-F $(ETH_FROM) \
		$(CONTRACT_AUTHORITY) \
		"canCall(address,address,bytes4)" \
		$(CONTRACT_SWAP) $(CONTRACT_ATN) $(burn_sig)
can-prove:
	@read -p 'Enter account: ' account; \
	seth call \
		--rpc-host $(ETH_RPC_HOST) \
		--rpc-port $(ETH_RPC_PORT) \
		-G $(ETH_GAS) \
		-F $(ETH_FROM) \
		$(CONTRACT_AUTHORITY) \
		"canCall(address,address,bytes4)" \
		$$account $(CONTRACT_SWAP) $(prove_sig)


# setup demo
.PHONY: demo
demo:
	@./bin/gen_demo_config \
		$(ETH_RPC_HOST) $(ETH_RPC_PORT) $(CONTRACT_ATN) $(CONTRACT_SWAP) $(ETH_FROM)
	@./bin/gen_worker_config \
		$(CONTRACT_SWAP) $(ETH_FROM) $(ETH_RPC_HOST) $(ETH_RPC_PORT) $(ETH_GAS)
	@seth send \
		--rpc-host $(ETH_RPC_HOST) \
		--rpc-port $(ETH_RPC_PORT) \
		-G $(ETH_GAS) \
		-F  $(ETH_FROM) \
		$(CONTRACT_ATN) \
		"mint(address,uint256)" \
		$(ETH_FROM) 1000
	@seth send \
		--rpc-host $(ETH_RPC_HOST) \
		--rpc-port $(ETH_RPC_PORT) \
		-G $(ETH_GAS) \
		-F $(ETH_FROM) \
		$(CONTRACT_SWAP) \
		"registerChain(bytes32)" \
		0x`./bin/string2bytes32 qtum`
	@echo
	@echo
	@echo 'Demo is ready to run. Now you have 1000 ATN to play around, you can swap to \'qtum\' in the demo just generated.'
	@echo '1. npm run listen'
	@echo '2. cd demo && ./swap <chainName>,<toAddress>,<amount>[,gas]'
