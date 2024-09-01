// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import {LibString} from "solady/utils/LibString.sol";

import {IAllowlist} from "../interfaces/IAllowlist.sol";

/// @title Allowlist
///
/// @notice General address allowlists with customizable list names.
///
/// @author Conner Swenberg (@ilikesymmetry).
abstract contract Allowlist is IAllowlist {
    /// @notice Mapping of allowlist entries.
    mapping(bytes32 listWord => mapping(address account => bool allowed)) private _allowlist;

    /// @notice Supported characters value for `solady.LibString` which includes: [a-z][A-Z][0-9]-_
    uint128 private immutable ALPHA_NUMERIC_SEPARATOR;

    /// @notice Constructor.
    ///
    /// @dev Instantiates allowed characters for lists.
    constructor() {
        ALPHA_NUMERIC_SEPARATOR =
            LibString.to7BitASCIIAllowedLookup("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_-");
    }

    /// @notice inheritdoc
    function updateAllowlist(string memory list, address account, bool allowed) external virtual {
        _authorizeAllowlistUpdate(list, account, allowed);
        bytes32 listWord = _toBytes32(list);
        _allowlist[listWord][account] = allowed;
        emit AllowlistUpdated(list, account, allowed);
    }

    /// @notice inheritdoc
    function isAllowed(string memory list, address account) public view returns (bool) {
        return _allowlist[_toBytes32(list)][account];
    }

    /// @notice inheritdoc
    function requireAllowed(string memory list, address account) public view virtual {
        if (!isAllowed(list, account)) revert NotAllowed(list, account);
    }

    /// @notice Convert a list string into a single bytes32 word.
    ///
    /// @param list Name of the list.
    ///
    /// @return listWord List cast into single bytes32 word.
    function _toBytes32(string memory list) internal view returns (bytes32 listWord) {
        if (!LibString.is7BitASCII(list, ALPHA_NUMERIC_SEPARATOR)) revert LibString.StringNot7BitASCII();
        return LibString.toSmallString(list);
    }

    /// @notice Authorize allowlist updates.
    ///
    /// @dev Require inheriting contract to implement appropriate checks.
    ///
    /// @param list Name of the list.
    /// @param account Address of the account on the allowlist.
    /// @param allowed True if `account` is now allowed on `list`.
    function _authorizeAllowlistUpdate(string memory list, address account, bool allowed) internal view virtual;
}
