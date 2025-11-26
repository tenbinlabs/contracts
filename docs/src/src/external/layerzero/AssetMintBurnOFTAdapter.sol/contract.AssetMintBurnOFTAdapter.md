# AssetMintBurnOFTAdapter
[Git Source](https://github.com/tenbinlabs/monorepo/blob/1a709cfd76568d13d9c12fac0d62140a5265be53/src/external/layerzero/AssetMintBurnOFTAdapter.sol)

**Inherits:**
Ownable, MintBurnOFTAdapter

OFT Adapter which mints and burns tokens on spoke chains
This contract should be set as `minter` in AssetToken on spoke chains


## Functions
### constructor


```solidity
constructor(address _owner, address _token, address _minterBurner, address _lzEndpoint, address _delegate)
    Ownable(_owner)
    MintBurnOFTAdapter(_token, IMintableBurnable(_minterBurner), _lzEndpoint, _delegate);
```

