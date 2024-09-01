// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import {LibString} from "solady/utils/LibString.sol";

import {IAllowlist} from "../interfaces/IAllowlist.sol";

/// @title AllowlistEnumerable
///
/// @notice Allowlist with full enumerability without indexers.
///
/// @author Conner Swenberg (@ilikesymmetry).
abstract contract AllowlistEnumerable is IAllowlist {
    /// @notice Individual allowlist entry.
    struct Entry {
        /// @param list Name of the list.
        string list;
        /// @param account Address of the account on the allowlist.
        address account;
    }

    /// @notice Key for allowlist mapping
    struct Key {
        /// @param account Address of the account on the allowlist.
        address account;
        /// @param listSelector bytes4 selector of the list, used for unique identification.
        bytes4 listSelector;
        /// @param listPrefix First 8 bytes of the list to free up storage in `Value`.
        bytes8 listPrefix;
    }

    /// @notice Value for allowlist mapping.
    struct Value {
        /// @param listSuffix Last 24 bytes of the list to be concatenated with `Key.listPrefix`.
        bytes24 listSuffix;
        /// @param index Location within the array of all allowlist entries.
        uint56 index;
        /// @param exists Convenience marker to detect if an allowlist entry exists.
        bool exists;
    }

    /// @notice Array of keys for all allowlist entries.
    Key[] internal _keys;

    /// @notice Mapping of keys (packed) to `Value` structs.
    mapping(bytes32 packedKey => Value) internal _values;

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
        (Key memory key, bytes32 packedKey) = _getKey(listWord, account);
        Value memory value = _values[packedKey];
        if (allowed) {
            // revert if value present but does not match list
            if (value.exists && _concat(key.listPrefix, value.listSuffix) != listWord) revert();

            bytes24 suffix = bytes24(listWord << 64);
            _values[packedKey] = Value({listSuffix: suffix, index: uint56(_keys.length), exists: true});
            _keys.push(key);
        } else if (!allowed) {
            // early return if value does not exist
            if (!value.exists) return;

            uint256 lastIndex = _keys.length - 1;
            if (value.index < lastIndex) {
                Key memory lastKey = _keys[lastIndex];
                bytes32 packedLastKey = _packKey(lastKey);
                Value memory lastValue = _values[packedLastKey];
                lastValue.index = value.index;
                _keys[value.index] = lastKey;
                _values[packedLastKey] = lastValue;
            }
            delete _values[packedKey];
            _keys.pop();
        }

        emit AllowlistUpdated(list, account, allowed);
    }

    /// @notice inheritdoc
    function isAllowed(string memory list, address account) public view virtual returns (bool) {
        bytes32 listWord = _toBytes32(list);
        (Key memory key, bytes32 packedKey) = _getKey(listWord, account);
        Value memory value = _values[packedKey];
        return value.exists && _concat(key.listPrefix, value.listSuffix) == listWord;
    }

    /// @notice inheritdoc
    function requireAllowed(string memory list, address account) public view virtual {
        if (!isAllowed(list, account)) revert NotAllowed(list, account);
    }

    /// @notice Get all allowlist entries.
    ///
    /// @return entries Array of allowlist `Entry` structs.
    function allowlistEntries() public view returns (Entry[] memory entries) {
        return allowlistEntriesSlice(0, allowlistEntriesCount());
    }

    /// @notice Get total count of allowlist entries.
    ///
    /// @return count Total number of allowlsit entries.
    function allowlistEntriesCount() public view returns (uint256) {
        return _keys.length;
    }

    /// @notice Get a slice of allowlist entries.
    ///
    /// @param startIndex First index to take in slice (inclusive).
    /// @param endIndex Last index to take in slice (exclusive).
    ///
    /// @return entries Array of allowlist `Entry` structs.
    function allowlistEntriesSlice(uint256 startIndex, uint256 endIndex) public view returns (Entry[] memory entries) {
        // early return if range length is zero
        if (startIndex == endIndex) return new Entry[](0);

        // check startIndex < endIndex
        if (startIndex > endIndex) revert();

        // check range length within stored length
        uint256 len = endIndex - startIndex;
        if (len > _keys.length) revert();

        entries = new Entry[](len);
        for (uint256 i = startIndex; i < len; i++) {
            Key memory key = _keys[i];
            bytes32 packedKey = _packKey(key);
            Value memory value = _values[packedKey];

            entries[i] = Entry({
                list: LibString.fromSmallString(_concat(key.listPrefix, value.listSuffix)),
                account: key.account
            });
        }
        return entries;
    }

    /// @notice Generate key for list and account allowlist entry.
    ///
    /// @param listWord List cast into single bytes32 word.
    /// @param account Address of the account on the allowlist.
    ///
    /// @return key Key struct.
    /// @return packed Packed version of `key` into bytes32 for use in `this._values` mapping.
    function _getKey(bytes32 listWord, address account) internal pure returns (Key memory key, bytes32 packed) {
        bytes4 listSelector = bytes4(keccak256(abi.encode(listWord)));
        bytes8 listPrefix = bytes8(listWord);
        key = Key(account, listSelector, listPrefix);
        return (key, _packKey(key));
    }

    /// @notice Pack a `Key` into a single bytes32 word.
    ///
    /// @param key Key struct.
    ///
    /// @return packed Packed version of `key` into bytes32 for use in `this._values` mapping.
    function _packKey(Key memory key) internal pure returns (bytes32 packed) {
        return bytes32(abi.encodePacked(key.account, key.listSelector, key.listPrefix));
    }

    /// @notice Concatenate a list prefix and suffix into a full word.
    ///
    /// @param listPrefix First 8 bytes of the list to free up storage in `Value`.
    /// @param listSuffix Last 24 bytes of the list to be concatenated with `Key.listPrefix`.
    ///
    /// @return listWord List cast into single bytes32 word.
    function _concat(bytes8 listPrefix, bytes24 listSuffix) internal pure returns (bytes32 listWord) {
        return bytes32(abi.encodePacked(listPrefix, listSuffix));
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
