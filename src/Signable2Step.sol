// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

abstract contract Signable2Step {
    address public signer;

    address public pendingSigner;

    event PendingSignerSet(address indexed newSigner);

    event SignerRotated(address indexed oldSigner, address indexed newSigner);

    error PendingSignerIsZeroAddress();

    error InvalidSigner(address signer);

    constructor(address initialSigner) {
        _requireNonZeroSigner(initialSigner);
        _setSigner(initialSigner);
    }

    function setPendingSigner(address newSigner) external virtual {
        _authorizeSetSigner(newSigner);
        _requireNonZeroSigner(newSigner);
        _setPendingSigner(newSigner);
    }

    function resetPendingSigner() external virtual {
        _authorizeSetSigner(address(0));
        _setPendingSigner(address(0));
    }

    function rotateSigner() external virtual {
        address newSigner = pendingSigner;
        _authorizeSetSigner(newSigner);
        _requireNonZeroSigner(newSigner);
        _setSigner(newSigner);
        delete pendingSigner;
    }

    function _setPendingSigner(address newSigner) internal {
        pendingSigner = newSigner;
        emit PendingSignerSet(newSigner);
    }

    function _setSigner(address newSigner) internal {
        address oldSigner = signer;
        signer = newSigner;
        emit SignerRotated(oldSigner, signer);
    }

    function _isSigner(address checkSigner) internal view returns (bool) {
        return checkSigner == signer || checkSigner == pendingSigner;
    }

    function _requireSigner(address checkSigner) internal view {
        if (!_isSigner(checkSigner)) revert InvalidSigner(checkSigner);
    }

    function _requireNonZeroSigner(address newSigner) internal pure {
        if (newSigner == address(0)) revert PendingSignerIsZeroAddress();
    }

    function _authorizeSetSigner(address account) internal view virtual;
}
