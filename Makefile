-include .env

.PHONY: all test deploy

build :; forge build

test :; forge test

install :; forge install cyfrin/foundry-devops@0.2.2 --no-commit && forge install smartcontractkit/chainlink@42c74fcd30969bca26a9aadc07463d1c2f473b8c --no-commit && forge install foundry-rs/forge-std@v1.7.0 --no-commit && forge install smartcontractkit/chainlink-brownie-contracts@1.1.1 --no-commit && forge install foundry-rs/forge-std@1.8.1 --no-commit && forge install transmissions11/solmate@v6 --no-commit

deploy-sepolia :
	@forge script script/DeployRaffle.s.sol:DeployRaffle --rpc-url ${SEPOLIA_RPC_URL} --account SepoliaKey --broadcast --verify --etherscan-api-key ${ETHERSCAN_API_KEY} -vvvv

add-sub:
	@forge script script/Interactions.s.sol:AddConsumer --rpc-url ${SEPOLIA_RPC_URL} --account SepoliaKey --broadcast -vvvv

deploy-anvil :
	@forge script script/DeployRaffle.s.sol:DeployRaffle --rpc-url http://127.0.0.1:8545 --account DefaultAnvil --broadcast
