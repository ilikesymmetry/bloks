// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import {LibString} from "solady/utils/LibString.sol";

abstract contract Allowlist {
    // supported characters: [a-z][A-Z][0-9]-_
    uint128 private immutable ONLY_ALPHA_NUMERICS;

    mapping(bytes32 listName => mapping(address account => bool allowed)) private _allowlist;

    event AllowlistUpdated(string listName, address account, bool allowed);

    error NotAllowed(bytes32 listName, address account);

    constructor() {
        ONLY_ALPHA_NUMERICS =
            LibString.to7BitASCIIAllowedLookup("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_-");
    }

    function updateAllowlist(bytes32 listName, address account, bool allowed) external virtual {
        _updateAllowlist(listName, account, allowed);
    }

    function updateAllowlist(string calldata listName, address account, bool allowed) external virtual {
        _updateAllowlist(toBytes32(listName), account, allowed);
    }

    function isAllowed(bytes32 listName, address account) public view virtual returns (bool) {
        return _allowlist[listName][account];
    }

    function isAllowed(string memory listName, address account) public view returns (bool) {
        return isAllowed(toBytes32(listName), account);
    }

    function requireAllowed(bytes32 listName, address account) public view virtual {
        if (!isAllowed(listName, account)) revert NotAllowed(listName, account);
    }

    function requireAllowed(string memory listName, address account) public view virtual {
        requireAllowed(toBytes32(listName), account);
    }

    function toBytes32(string memory listName) public view returns (bytes32) {
        _validateListName(listName);
        return LibString.toSmallString(listName);
    }

    function toString(bytes32 listName) public view returns (string memory) {
        string memory s = LibString.fromSmallString(listName);
        _validateListName(s);
        return s;
    }

    function _updateAllowlist(bytes32 listName, address account, bool allowed) internal virtual {
        _authorizeAllowlistUpdate(listName, account, allowed);
        string memory s = LibString.fromSmallString(listName);
        _validateListName(s);
        _allowlist[listName][account] = allowed;
        emit AllowlistUpdated(s, account, allowed);
    }

    function _validateListName(string memory listName) internal view {
        if (!LibString.is7BitASCII(listName, ONLY_ALPHA_NUMERICS)) revert LibString.StringNot7BitASCII();
    }

    function _authorizeAllowlistUpdate(bytes32 listName, address account, bool allowed) internal view virtual;
}
