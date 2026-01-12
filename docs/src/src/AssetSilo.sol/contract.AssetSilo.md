# AssetSilo
[Git Source](https://github.com/tenbinlabs/monorepo/blob/d116a5615213d266827c42f1b2c31cdd3a1c6ae1/src/AssetSilo.sol)

**Title:**
AssetSilo

Stores assets in cooldown for Tenbin protocol staking


## State Variables
### staking
Staking contract


```solidity
address public immutable staking
```


### asset
Asset token


```solidity
IERC20 immutable asset
```


## Functions
### constructor

AssetSilo constructor


```solidity
constructor(address staking_, address asset_) ;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`staking_`|`address`|Address of staking contract|
|`asset_`|`address`|Address of asset contract|


### withdraw

Withdraw assets to an account


```solidity
function withdraw(address to, uint256 amount) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`to`|`address`|Account to withdraw tokens to|
|`amount`|`uint256`|Amount of tokens to withdraw|


## Errors
### OnlyStaking
Only staking contract


```solidity
error OnlyStaking();
```

