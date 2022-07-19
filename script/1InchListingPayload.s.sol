// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.11;

import "forge-std/Test.sol";
import "forge-std/Script.sol";
import "src/1InchListingPayload.sol";


contract OneInchDeployScript is Script, Test {

    function run() external {
        vm.startBroadcast();

        OneInchListingPayload nft = new OneInchListingPayload();

        vm.stopBroadcast();
    }
}