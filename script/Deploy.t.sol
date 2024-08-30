// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import {Script} from "forge-std/Script.sol";

import {MockContract} from "../test/mocks/MockContract.sol";

// forge script Deploy --account dev --sender $SENDER --rpc-url $BASE_SEPOLIA_RPC --verify --verifier-url $SEPOLIA_BASESCAN_API --etherscan-api-key $BASESCAN_API_KEY --broadcast -vvvv
contract Deploy is Script {
    function run() public {
        vm.startBroadcast();

        new MockContract{salt: 0}();
    }
}
