# LayerZeroOFTAdapter
[Git Source](https://github.com/tenbinlabs/monorepo/blob/4fdd65603a4c48b6527407c6f86f93c378ffa140/src/adapters/LayerZeroOFTAdapter.sol)

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

