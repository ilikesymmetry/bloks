// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import {Test} from "forge-std/Test.sol";
import {LibString} from "solady/utils/LibString.sol";

import {AllowlistEnumerable} from "../../src/AllowlistEnumerable.sol";

import {MockContract} from "../mocks/MockContract.sol";

contract UpdateAllowlistTest is Test {
    MockContract mock;

    function setUp() public {
        mock = new MockContract();
    }

    function test_updateAllowlist_add(address account) public {
        string memory listName = "a";
        mock.updateAllowlist(listName, account, true);
        assertTrue(mock.isAllowed(listName, account));
        assertEq(mock.totalEntryCount(), 1);
        assertEq(
            abi.encode(mock.getAllAllowlistEntries()[0]),
            abi.encode(AllowlistEnumerable.Entry({listName: "a", account: account}))
        );
    }
}
