// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import {Allowlist} from "../../src/Allowlist.sol";

contract MockContract is Allowlist {
    function _authorizeAllowlistUpdate(bytes32 listName, address account, bool allowed) internal view override {
        // ok
    }
}
