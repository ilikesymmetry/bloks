// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

interface IAllowlist {
    /// @notice Allowlist was updated.
    ///
    /// @dev Params not indexed for better human-readability on block explorers.
    ///
    /// @param list Name of the list.
    /// @param account Address of the account on the allowlist.
    /// @param allowed True if `account` is now allowed on `list`.
    event AllowlistUpdated(string list, address account, bool allowed);

    /// @notice Allowlist condition failed.
    ///
    /// @param list Name of the list.
    /// @param account Address of the account on the allowlist.
    error NotAllowed(string list, address account);

    /// @notice Update allowlist entry.
    ///
    /// @param list Name of the list.
    /// @param account Address of the account on the allowlist.
    /// @param allowed True if `account` is now allowed on `list`.
    function updateAllowlist(string calldata list, address account, bool allowed) external;

    /// @notice Check allowlist membership.
    ///
    /// @param list Name of the list.
    /// @param account Address of the account on the allowlist.
    ///
    /// @return allowed True if `account` is on `list`.
    function isAllowed(string memory list, address account) external view returns (bool);

    /// @notice Enforce allowlist membership.
    ///
    /// @dev Reverts if not allowed.
    ///
    /// @param list Name of the list.
    /// @param account Address of the account on the allowlist.
    function requireAllowed(string memory list, address account) external view;
}
