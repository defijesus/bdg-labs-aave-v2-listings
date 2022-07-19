# include .env file and export its env vars
# (-include to ignore error if it does not exist)
-include .env

# deps
update:; forge update

# Build & test
build  :; forge build --sizes --via-ir
test   :; forge test -vvv --rpc-url=${ETH_RPC_URL} --fork-block-number 15008553 --via-ir
trace   :; forge test -vvvv --rpc-url=${ETH_RPC_URL} --fork-block-number 15008553 --via-ir
clean  :; forge clean
snapshot :; forge snapshot

# utils
download :; ETHERSCAN_API_KEY=${ETHERSCAN_API_KEY} cast etherscan-source -d src/etherscan/${address} ${address} 
rinkeby-download :; ETHERSCAN_API_KEY=${ETHERSCAN_API_KEY} cast etherscan-source -c rinkeby -d src/etherscan/${address} ${address} 


# deploy
rinkeby-predeploy1INCH :; forge script script/1InchListingPreload.s.sol:OneInchDeployScript --rpc-url=${RINKEBY_RPC_URL} --private-key ${PRIVATE_KEY} --broadcast --verify
rinkeby-deploy1INCH :;  forge script script/1InchListingPayload.s.sol:OneInchDeployScript --rpc-url=${RINKEBY_RPC_URL} --private-key ${PRIVATE_KEY} --broadcast --verify

predeploy1INCH :; forge script script/1InchListingPreload.s.sol:OneInchDeployScript --rpc-url=${ETH_RPC_URL} --ledger --sender 0xde30040413b26d7aa2b6fc4761d80eb35dcf97ad --broadcast --verify --via-ir
deploy1INCH :;  forge script script/1InchListingPayload.s.sol:OneInchDeployScript --rpc-url=${ETH_RPC_URL} --ledger --sender 0xde30040413b26d7aa2b6fc4761d80eb35dcf97ad --broadcast --verify --via-ir