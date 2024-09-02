// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

/// @title Owner2Step
///
/// @notice Owner with required 2-step rotation and lockout mitigation.
///
/// @author Conner Swenberg (@ilikesymmetry).
abstract contract Owner2Step {
    /// @notice EOA or smart contract that owns the contract.
    address public owner;

    /// @notice Pending owner that must accept ownership.
    ///
    /// @dev Pending owner MUST be set prior to being able to replace primary `owner`.
    address public pendingOwner;

    /// @notice New pending owner set.
    ///
    /// @param newOwner Address of the new owner.
    event PendingOwnerSet(address indexed newOwner);

    /// @notice Pending owner replaced old owner.
    ///
    /// @dev Event signature copied from OpenZeppelin Ownable.
    ///
    /// @param oldOwner Address of old owner.
    /// @param newOwner Address of new owner.
    event OwnershipTransferred(address indexed oldOwner, address indexed newOwner);

    /// @notice Attempted to set a pending owner to `address(0)`.
    error OwnerIsZeroAddress();

    /// @notice Account is not the current `owner`.
    error InvalidOwner(address account);

    /// @notice Account is not the current `pendingOwner`.
    error InvalidPendingOwner(address account);

    /// @notice Constructor.
    ///
    /// @param initialOwner Address of first owner.
    constructor(address initialOwner) {
        _requireNonZeroOwner(initialOwner);
        _setOwner(initialOwner);
    }

    modifier onlyOwner() {
        _requireValidOwner(msg.sender);
        _;
    }

    /// @notice Set pending owner to initiate ownership transfer.
    ///
    /// @param newOwner Address of the new owner.
    function setPendingOwner(address newOwner) external virtual onlyOwner {
        _requireNonZeroOwner(newOwner);
        _setPendingOwner(newOwner);
    }

    /// @notice Reset pending owner to zero.
    function resetPendingOwner() external virtual onlyOwner {
        _setPendingOwner(address(0));
    }

    /// @notice Replace `owner` with `pendingOwner`.
    function acceptOwnership() external virtual {
        address newOwner = pendingOwner;
        if (msg.sender != newOwner) revert InvalidPendingOwner(msg.sender);
        _setOwner(newOwner);
        delete pendingOwner;
    }

    /// @notice Require address is a valid owner.
    ///
    /// @param account Address to check.
    function _requireValidOwner(address account) internal view {
        if (account != owner) revert InvalidOwner(account);
    }

    /// @notice Set pending owner in storage and emit event.
    ///
    /// @param newOwner Address of the new owner.
    function _setPendingOwner(address newOwner) internal {
        pendingOwner = newOwner;
        emit PendingOwnerSet(newOwner);
    }

    /// @notice Set owner with pending owner.
    ///
    /// @param newOwner Address of the new owner.
    function _setOwner(address newOwner) internal {
        address oldOwner = owner;
        owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }

    /// @notice Revert if account is `address(0)`.
    ///
    /// @param account Address to check.
    function _requireNonZeroOwner(address account) internal pure {
        if (account == address(0)) revert OwnerIsZeroAddress();
    }
}
