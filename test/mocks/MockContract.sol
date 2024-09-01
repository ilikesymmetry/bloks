// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import {Allowlist} from "../../src/Allowlist/Allowlist.sol";
import {AllowlistEnumerable} from "../../src/Allowlist/AllowlistEnumerable.sol";

contract MockContract is AllowlistEnumerable {
    function _authorizeAllowlistUpdate(string memory listName, address account, bool allowed) internal view override {
        // ok
    }
}
