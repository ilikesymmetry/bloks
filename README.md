## Bloks

An opinionated library of base contracts for common onchain management.

All contracts are designed with namespaced storage layouts for easy integration in upgradeable contracts.

### Base contracts

- `[##---] 40%` `Allowlist`: General address allowlists with customizable list names.
- `[##---] 40%` `Signable2Step`: Single signer with required 2-step rotation process.
- `[-----] 00%` `Ownable2Step`: Single owner with required 2-step change process, renouncing blocked.
- `[-----] 00%` `Pausable`: Simple pausing.
- `[-----] 00%` `Withdrawable`: Withdraw native and ERC20 tokens to prevent asset lockout.

### Install

```bash
forge install ilikesymmetry/bloks
```

It is recommended to NOT use a remapping so that you can also intuitively import mocks within the `test/` directory.
