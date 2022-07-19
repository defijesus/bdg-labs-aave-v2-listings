// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.11;

import "forge-std/Test.sol";
import "forge-std/Script.sol";

import {AaveGovHelpers, IAaveGov} from "src/test/utils/AaveGovHelpers.sol";


contract OneInchDeployScript is Script, Test {

    address internal constant DELEGATE_ADDRESS = 0xd2362DbB5Aa708Bc454Ce5C3F11050C016764fA6;
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