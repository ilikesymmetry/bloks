// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import {LibString} from "solady/utils/LibString.sol";

import {IAllowlist} from "./interfaces/IAllowlist.sol";

abstract contract AllowlistEnumerable is IAllowlist {
    struct Key {
        bytes4 listNameSelector;
        bytes8 listNamePrefix;
        address account;
    }

    struct Value {
        bool exists;
        uint56 index;
        bytes24 listNameSuffix;
    }

    struct Entry {
        string listName;
        address account;
    }

    // supported characters: [a-z][A-Z][0-9]-_
    uint128 private immutable ONLY_ALPHA_NUMERICS;

    Key[] public _keys;

    mapping(bytes32 packedKey => Value) internal _values;

    constructor() {
        ONLY_ALPHA_NUMERICS =
            LibString.to7BitASCIIAllowedLookup("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_-");
    }

    function updateAllowlist(string memory listName, address account, bool allowed) external virtual {
        _authorizeAllowlistUpdate(listName, account, allowed);
        bytes32 listNameWord = _toBytes32(listName);
        (Key memory key, bytes32 packedKey) = _getKey(listNameWord, account);
        Value memory value = _values[packedKey];
        if (allowed) {
            // revert if value present but does not match listName
            if (value.exists && _mergeListName(key.listNamePrefix, value.listNameSuffix) != listNameWord) revert();

            bytes24 suffix = bytes24(listNameWord << 64);
            _values[packedKey] = Value({exists: true, index: uint56(_keys.length), listNameSuffix: suffix});
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

        emit AllowlistUpdated(listName, account, allowed);
    }

    function isAllowed(string memory listName, address account) public view virtual returns (bool) {
        bytes32 listNameWord = _toBytes32(listName);
        (Key memory key, bytes32 packedKey) = _getKey(listNameWord, account);
        Value memory value = _values[packedKey];
        return value.exists && _mergeListName(key.listNamePrefix, value.listNameSuffix) == listNameWord;
    }

    function requireAllowed(string memory listName, address account) public view virtual {
        if (!isAllowed(listName, account)) revert NotAllowed(listName, account);
    }

    function totalEntryCount() external view returns (uint256) {
        return _keys.length;
    }

    function getAllAllowlistEntries() external view returns (Entry[] memory entries) {
        uint256 len = _keys.length;
        entries = new Entry[](len);
        for (uint256 i = 0; i < len; i++) {
            Key memory key = _keys[i];
            bytes32 packedKey = _packKey(key);
            Value memory value = _values[packedKey];

            entries[i] = Entry({
                listName: LibString.fromSmallString(_mergeListName(key.listNamePrefix, value.listNameSuffix)),
                account: key.account
            });
        }
        return entries;
    }

    function _toBytes32(string memory listName) internal view returns (bytes32) {
        if (!LibString.is7BitASCII(listName, ONLY_ALPHA_NUMERICS)) revert LibString.StringNot7BitASCII();
        return LibString.toSmallString(listName);
    }

    function _getKey(bytes32 listNameWord, address account) internal pure returns (Key memory key, bytes32 packed) {
        bytes4 listNameSelector = bytes4(keccak256(abi.encode(listNameWord)));
        bytes8 listNamePrefix = bytes8(listNameWord);
        key = Key(listNameSelector, listNamePrefix, account);
        return (key, _packKey(key));
    }

    function _packKey(Key memory key) internal pure returns (bytes32) {
        return bytes32(abi.encodePacked(key.listNameSelector, key.listNamePrefix, key.account));
    }

    function _mergeListName(bytes8 prefix, bytes24 suffix) internal pure returns (bytes32) {
        return bytes32(abi.encodePacked(prefix, suffix));
    }

    function _authorizeAllowlistUpdate(string memory listName, address account, bool allowed) internal view virtual;
}
