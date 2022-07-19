// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.11;

import "forge-std/Test.sol";
import "forge-std/Script.sol";

import {AaveGovHelpers, IAaveGov} from "src/test/utils/AaveGovHelpers.sol";

contract OneInchDeployScript is Script, Test {

    address internal constant DELEGATE_ADDRESS = 0xd2362DbB5Aa708Bc454Ce5C3F11050C016764fA6;
    address internal constant PAYLOAD = 0xD417d07c20e31F6e129fa68182054B641FbEC8Bd;

    bytes32 internal constant IPFS_HASH = bytes32(0xec9d2289ab7db9bfbf2b0f2dd41ccdc0a4003e9e0d09e40dee09095145c63fb5);

    IAaveGov internal constant GOV =
        IAaveGov(0xEC568fffba86c094cf06b22134B23074DFE2252c);

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

        uint256 proposalId = GOV.create(
            AaveGovHelpers.SHORT_EXECUTOR,
            targets,
            values,
            signatures,
            calldatas,
            withDelegatecalls,
            IPFS_HASH
        );

        vm.stopBroadcast();
    }
}