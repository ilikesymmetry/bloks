// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import {LibString} from "solady/utils/LibString.sol";

import {IAllowlist} from "./interfaces/IAllowlist.sol";

abstract contract Allowlist is IAllowlist {
    // supported characters: [a-z][A-Z][0-9]-_
    uint128 private immutable ONLY_ALPHA_NUMERICS;

    mapping(bytes32 listName => mapping(address account => bool allowed)) private _allowlist;

    constructor() {
        ONLY_ALPHA_NUMERICS =
            LibString.to7BitASCIIAllowedLookup("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_-");
    }

    function updateAllowlist(string memory listName, address account, bool allowed) external virtual {
        _authorizeAllowlistUpdate(listName, account, allowed);
        bytes32 listNameWord = _toBytes32(listName);
        _allowlist[listNameWord][account] = allowed;
        emit AllowlistUpdated(listName, account, allowed);
    }

    function isAllowed(string memory listName, address account) public view returns (bool) {
        return _allowlist[_toBytes32(listName)][account];
    }

    function requireAllowed(string memory listName, address account) public view virtual {
        if (!isAllowed(listName, account)) revert NotAllowed(listName, account);
    }

    function _toBytes32(string memory listName) internal view returns (bytes32) {
        if (!LibString.is7BitASCII(listName, ONLY_ALPHA_NUMERICS)) revert LibString.StringNot7BitASCII();
        return LibString.toSmallString(listName);
    }

    function _authorizeAllowlistUpdate(string memory listName, address account, bool allowed) internal view virtual;
}
