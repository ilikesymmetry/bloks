// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import {AllowlistEnumerable} from "../../src/mixins/AllowlistEnumerable.sol";
import {Owner2Step} from "../../src/mixins/Owner2Step.sol";

contract MockContract is Owner2Step, AllowlistEnumerable {
    constructor(address initialOwner) Owner2Step(initialOwner) AllowlistEnumerable() {}

    function _authorizeAllowlistUpdate(string memory listName, address account, bool allowed)
        internal
        view
        override
        onlyOwner
    {}
}
