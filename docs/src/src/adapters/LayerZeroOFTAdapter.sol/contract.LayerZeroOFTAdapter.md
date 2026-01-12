# LayerZeroOFTAdapter
[Git Source](https://github.com/tenbinlabs/monorepo/blob/d1844942443e1461d2e1c94831153ddbe76d014b/src/adapters/LayerZeroOFTAdapter.sol)

**Inherits:**
OFTAdapter

OFTAdapter uses a deployed ERC-20 token and SafeERC20 to interact with the OFTCore contract.


## Functions
### constructor


```solidity
constructor(address _token, address _lzEndpoint, address _owner)
    OFTAdapter(_token, _lzEndpoint, _owner)
    Ownable(_owner);
```

