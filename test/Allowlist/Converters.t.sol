// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import {Test} from "forge-std/Test.sol";
import {LibString} from "solady/utils/LibString.sol";

import {MockContract} from "../mocks/MockContract.sol";

contract ConvertersTest is Test {
    MockContract mock;

    function setUp() public {
        mock = new MockContract();
    }

    function test_toBytes32_lowerCase() public {
        string memory listNameStr = "abcdefghijklmnopqrstuvwxyz";
        assertTrue(LibString.toSmallString(listNameStr) == mock.toBytes32(listNameStr));
    }

    function test_toBytes32_upperCase() public {
        string memory listNameStr = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
        assertTrue(LibString.toSmallString(listNameStr) == mock.toBytes32(listNameStr));
    }

    function test_toBytes32_numbersSpecial() public {
        string memory listNameStr = "0123456789_-";
        assertTrue(LibString.toSmallString(listNameStr) == mock.toBytes32(listNameStr));
    }

    function test_toString_lowerCase() public {
        string memory listNameStr = "abcdefghijklmnopqrstuvwxyz";
        bytes32 listName = mock.toBytes32(listNameStr);
        assertTrue(LibString.eq(listNameStr, mock.toString(listName)));
    }

    function test_toString_upperCase() public {
        string memory listNameStr = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
        bytes32 listName = mock.toBytes32(listNameStr);
        assertTrue(LibString.eq(listNameStr, mock.toString(listName)));
    }

    function test_toString_numbersSpecial() public {
        string memory listNameStr = "0123456789_-";
        bytes32 listName = mock.toBytes32(listNameStr);
        assertTrue(LibString.eq(listNameStr, mock.toString(listName)));
    }
}
