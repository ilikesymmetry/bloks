// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

/// @title Signer2Step
///
/// @notice Signer with required 2-step rotation.
///
/// @author Conner Swenberg (@ilikesymmetry).
abstract contract Signer2Step {
    /// @notice EOA or smart contract that is able to sign messages.
    address public signer;

    /// @notice Pending signer that is able to sign messages.
    ///
    /// @dev Pending signer MUST be set prior to being able to replace primary `signer`.
    address public pendingSigner;

    /// @notice New pending signer set.
    ///
    /// @param newSigner Address of signer that is able to sign messages.
    event PendingSignerSet(address indexed newSigner);

    /// @notice Pending signer replaced old signer.
    ///
    /// @param oldSigner Address of old signer previously able to sign messages.
    /// @param newSigner Address of signer that is able to sign messages.
    event SignerRotated(address indexed oldSigner, address indexed newSigner);

    /// @notice Attempted to set a pending signer to `address(0)`.
    error SignerIsZeroAddress();

    /// @notice Signer is not the current `signer` or `pendingSigner`.
    error InvalidSigner(address signer);

    /// @notice Constructor.
    ///
    /// @param initialSigner Address of first signer.
    constructor(address initialSigner) {
        _requireNonZeroSigner(initialSigner);
        _setSigner(initialSigner);
    }

    /// @notice Set pending signer to start signing messages.
    ///
    /// @param newSigner Address of signer that is able to sign messages.
    function setPendingSigner(address newSigner) external virtual {
        _authorizeSetSigner(newSigner);
        _requireNonZeroSigner(newSigner);
        _setPendingSigner(newSigner);
    }

    /// @notice Reset pending signer to zero.
    function resetPendingSigner() external virtual {
        _authorizeSetSigner(address(0));
        _setPendingSigner(address(0));
    }

    /// @notice Replace primary signer with pending signer.
    function rotateSigners() external virtual {
        address newSigner = pendingSigner;
        _requireNonZeroSigner(newSigner);
        _authorizeSetSigner(newSigner);
        _setSigner(newSigner);
        delete pendingSigner;
    }

    /// @notice Set pending signer in storage and emit event.
    ///
    /// @param newSigner Address of signer that is able to sign messages.
    function _setPendingSigner(address newSigner) internal {
        pendingSigner = newSigner;
        emit PendingSignerSet(newSigner);
    }

    /// @notice Set primary signer with pending signer.
    ///
    /// @param newSigner Address of signer that is able to sign messages.
    function _setSigner(address newSigner) internal {
        address oldSigner = signer;
        signer = newSigner;
        emit SignerRotated(oldSigner, newSigner);
    }

    /// @notice Check if address is the primary signer or pending signer.
    ///
    /// @param account Address to check.
    function _isValidSigner(address account) internal view returns (bool) {
        return account == signer || account == pendingSigner;
    }

    /// @notice Require address is a valid signer.
    ///
    /// @param account Address to check.
    function _requireValidSigner(address account) internal view {
        if (!_isValidSigner(account)) revert InvalidSigner(account);
    }

    /// @notice Revert if signer is `address(0)`.
    ///
    /// @param account Address to check.
    function _requireNonZeroSigner(address account) internal pure {
        if (account == address(0)) revert SignerIsZeroAddress();
    }

    /// @notice Authorize setting a signer.
    ///
    /// @dev Require inheriting contract to implement appropriate checks.
    function _authorizeSetSigner(address newSigner) internal view virtual;
}
