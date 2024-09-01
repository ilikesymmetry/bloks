// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @title Signer2Step
///
/// @notice Signer with required 2-step rotation.
///
/// @author Conner Swenberg (@ilikesymmetry).
abstract contract Signer2Step {
    /// @notice EOA or smart contract that is able to sign messages.
    address public primarySigner;

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

    /// @notice Check if address is the primary signer or pending signer.
    ///
    /// @param signer Address to check.
    function isValidSigner(address signer) public view returns (bool) {
        return signer == primarySigner || signer == pendingSigner;
    }

    /// @notice Require address is a valid signer.
    ///
    /// @param signer Address to check.
    function requireValidSigner(address signer) internal view {
        if (!isValidSigner(signer)) revert InvalidSigner(signer);
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
        address oldSigner = primarySigner;
        primarySigner = newSigner;
        emit SignerRotated(oldSigner, newSigner);
    }

    /// @notice Revert if signer is `address(0)`.
    ///
    /// @param signer Address to check.
    function _requireNonZeroSigner(address signer) internal pure {
        if (signer == address(0)) revert SignerIsZeroAddress();
    }

    /// @notice Authorize setting a signer.
    ///
    /// @dev Require inheriting contract to implement appropriate checks.
    function _authorizeSetSigner(address newSigner) internal view virtual;
}
