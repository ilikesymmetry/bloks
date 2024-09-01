// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import {Allowlist} from "../../src/mixins/Allowlist.sol";
import {AllowlistEnumerable} from "../../src/mixins/AllowlistEnumerable.sol";

contract MockContract is AllowlistEnumerable {
    function _authorizeAllowlistUpdate(string memory listName, address account, bool allowed) internal view override {
        // ok
    }
}
