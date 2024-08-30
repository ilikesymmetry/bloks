// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

interface IAllowlist {
    event AllowlistUpdated(string listName, address account, bool allowed);

    error NotAllowed(string listName, address account);

    function updateAllowlist(string calldata listName, address account, bool allowed) external;

    function isAllowed(string memory listName, address account) external view returns (bool);

    function requireAllowed(string memory listName, address account) external view;
}
