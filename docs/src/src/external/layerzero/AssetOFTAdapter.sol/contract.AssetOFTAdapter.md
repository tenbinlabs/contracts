# AssetOFTAdapter
[Git Source](https://github.com/tenbinlabs/monorepo/blob/1a709cfd76568d13d9c12fac0d62140a5265be53/src/external/layerzero/AssetOFTAdapter.sol)

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

