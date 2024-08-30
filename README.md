## Based

An opinionated library of base contracts for common onchain management.

All contracts are designed with namespaced storage layouts for easy integration in upgradeable contracts.

### Base contracts

- [ ] `Ownable2Step`: Single owner with required 2-step change process, renouncing blocked.
- [ ] `Signable2Step`: Single signer with required 2-step rotation process.
- [ ] `Pausable`: Simple pausing.
- [ ] `Withdrawable`: Withdraw native and ERC20 tokens to prevent asset lockout.
- [ ] `Allowlist`: General address allowlists with customizable list names.

### Install

```bash
forge install ilikesymmetry/solbase
```

It is recommended to NOT use a remapping so that you can also intuitively import mocks within the `test/` directory.
