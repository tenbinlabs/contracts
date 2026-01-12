# LayerZeroMintBurnOFTAdapter
[Git Source](https://github.com/tenbinlabs/monorepo/blob/d1844942443e1461d2e1c94831153ddbe76d014b/src/adapters/LayerZeroMintBurnOFTAdapter.sol)

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

