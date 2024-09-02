# Bloks

Build secure onchain systems quickly. Optimized for developer experience.

## Key features

1. Simple and composable.
1. Upgrade-friendly storage.
1. 100% test coverage.

## Contracts

- `[###--] 60%` [`Owner2Step`](./src/mixins/Owner2Step.sol): Owner with required 2-step rotation and lockout mitigation.
- `[###--] 60%` [`Signer2Step`](./src/mixins/Signer2Step.sol): Signer with required 2-step rotation.
- `[###--] 60%` [`Allowlist`](./src/mixins/Allowlist.sol): General address allowlists with customizable list names.
- `[###--] 60%` [`AllowlistEnumerable`](./src/mixins/AllowlistEnumerable.sol): Allowlist with full enumerability without indexers.

If you would like to see more bloks, [DM to connect](x.com/ilikesymmetry).

## Quickstart

### Install

```bash
forge install ilikesymmetry/bloks
```

### Import and inherit

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Allowlist} from "bloks/mixins/Allowlist.sol";
import {Owner2Step} from "bloks/mixins/Owner2Step.sol";

contract Contract is Owner2Step, Allowlist {
    constructor(address initialOwner) Owner2Step(initialOwner) Allowlist() {}

    function _authorizeAllowlistUpdate(string memory, address, bool) internal override onlyOwner {}
}
```
