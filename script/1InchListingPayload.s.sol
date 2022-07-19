// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.11;

import "forge-std/Script.sol";
import "src/1InchListingPayload.sol";


contract OneInchDeployScript is Script {

    function run() external {
        vm.startBroadcast();

        OneInchListingPayload one = new OneInchListingPayload();

        vm.stopBroadcast();
    }
}