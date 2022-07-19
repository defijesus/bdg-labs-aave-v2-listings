// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.11;

import "forge-std/Test.sol";
import "forge-std/Script.sol";

import {AaveGovHelpers, IAaveGov} from "src/test/utils/AaveGovHelpers.sol";


contract OneInchDeployScript is Script, Test {

    address internal constant ONEINCH = 0x111111111117dC0aa78b770fA6A738034120C302;

    uint8 public constant ONEINCH_DECIMALS = 18;

    address internal constant DAI = 0x6B175474E89094C44Da98b954EedeAC495271d0F;

    address internal constant POOL = 0x7d2768dE32b0b80b7a3454c06BdAc94A69DDc7A9;

    address internal constant RESERVE_TREASURY_ADDRESS = 0x464C71f6c2F760DdA6093dCB91C24c39e5d6e18c;

    address internal constant LENDING_POOL_ADDRESSES_PROVIDER = 0xB53C1a33016B2DC2fF3653530bfF1848a515c8c5;

    address internal constant INCENTIVES_CONTROLLER = address(0);

    string internal constant ATOKEN_NAME = "Aave interest bearing 1INCH";

    string internal constant ATOKEN_SYMBOL = "a1INCH";

    string internal constant STABLE_DEBT_TOKEN_NAME = "Aave stable debt bearing 1INCH";

    string internal constant STABLE_DEBT_TOKEN_SYMBOL = "stableDebt1INCH";

    string internal constant VARIABLE_DEBT_TOKEN_NAME = "Aave variable debt bearing 1INCH";
    
    string internal constant VARIABLE_DEBT_TOKEN_SYMBOL = "variableDebt1INCH";

    // artifacts
    string internal constant aTokenArtifact = "AToken.sol:AToken";
    string internal constant stableDebtArtifact = "stableDebt.sol:StableDebtToken";
    string internal constant variableDebtArtifact = "varDebt.sol:VariableDebtToken";


    address internal constant DELEGATE_ADDRESS = address(0);
    address internal constant PAYLOAD = address(0);

    bytes32 internal constant IPFS_HASH = bytes32(0);


    function run() external {
        vm.startBroadcast();

        address[] memory targets = new address[](1);
        targets[0] = PAYLOAD;
        uint256[] memory values = new uint256[](1);
        values[0] = 0;
        string[] memory signatures = new string[](1);
        signatures[0] = "execute()";
        bytes[] memory calldatas = new bytes[](1);
        calldatas[0] = "";
        bool[] memory withDelegatecalls = new bool[](1);
        withDelegatecalls[0] = true;

        uint256 proposalId = AaveGovHelpers._createProposal(
            vm,
            DELEGATE_ADDRESS,
            IAaveGov.SPropCreateParams({
                executor: AaveGovHelpers.SHORT_EXECUTOR,
                targets: targets,
                values: values,
                signatures: signatures,
                calldatas: calldatas,
                withDelegatecalls: withDelegatecalls,
                ipfsHash: IPFS_HASH
            })
        );

        vm.stopBroadcast();
    }
}