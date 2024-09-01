# Bloks

Build secure onchain systems quickly. Optimized for developer experience.

## Key features

1. Simple and composable.
1. Upgrade-friendly storage.
1. 100% test coverage.

## Contracts

- `[####-] 80%` [`Allowlist`](./src/mixins/Allowlist.sol): General address allowlists with customizable list names.
- `[####-] 80%` [`AllowlistEnumerable`](./src/mixins/AllowlistEnumerable.sol): Allowlist with full enumerability without indexers.
- `[-----] 00%` [`Owner2Step`](./src/mixins/Owner2Step.sol): Owner with required 2-step rotation.
- `[##---] 40%` [`Signer2Step`](./src/mixins/Signer2Step.sol): Signer with required 2-step rotation.

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

import {Owner2Step} from "bloks/mixins/Owner2Step.sol";
import {Allowlist} from "bloks/mixins/Allowlist.sol";

contract Contract is Owner2Step, Allowlist {
    // your logic

    function _authorizeAllowlistUpdate(string memory, address, bool) internal override onlyOwner {}
}
```
