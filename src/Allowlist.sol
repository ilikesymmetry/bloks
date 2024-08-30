// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import {LibString} from "solady/utils/LibString.sol";

abstract contract Allowlist {
    // binary code: 00000011111111111111111111111111000000111111111111111111111111110000000111111111100000000000000000000000000000000000000000000000
    uint128 private constant onlyAlphaNumerics = 0x03FFFFFF03FFFFFF01FF800000000000;

    mapping(bytes32 listName => mapping(address account => bool allowed)) private _allowlist;

    event AllowlistUpdated(bytes32 indexed listName, address indexed account, bool allowed);

    error NotAllowed(bytes32 listName, address account);

    error ListNameOverflow();

    function updateAllowlist(bytes32 listName, address account, bool allowed) public virtual {
        _authorizeAllowlistUpdate(listName, account, allowed);
        _allowlist[listName][account] = allowed;
        emit AllowlistUpdated(listName, account, allowed);
    }

    function isAllowed(bytes32 listName, address account) public view virtual returns (bool) {
        return _allowlist[listName][account];
    }

    function requireAllowed(bytes32 listName, address account) public view virtual {
        if (!isAllowed(listName, account)) revert NotAllowed(listName, account);
    }

    function isAllowed(string calldata listName, address account) public view returns (bool) {
        _validateListName(listName);
        return isAllowed(toBytes32(listName), account);
    }

    function requireAllowed(string calldata listName, address account) public view {
        _validateListName(listName);
        requireAllowed(toBytes32(listName), account);
    }

    function toBytes32(string calldata listName) public pure returns (bytes32) {
        return bytes32(bytes(listName));
    }

    function toString(bytes32 listName) public pure returns (string memory) {
        return string(abi.encode(listName));
    }

    function _validateListName(string calldata listName) private pure {
        if (!LibString.is7BitASCII(listName, onlyAlphaNumerics)) revert LibString.StringNot7BitASCII();
        if (bytes(listName).length > 32) revert ListNameOverflow();
    }

    function _authorizeAllowlistUpdate(bytes32 listName, address account, bool allowed) internal view virtual;
}
