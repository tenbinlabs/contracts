# IStakedAsset
[Git Source](https://github.com/tenbinlabs/monorepo/blob/4fdd65603a4c48b6527407c6f86f93c378ffa140/src/interface/IStakedAsset.sol)

Staked asset interface


## Functions
### pendingRewards

Get pending rewards for this contract


```solidity
function pendingRewards() external view returns (uint256 pending);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`pending`|`uint256`|Pending unvested token reward|


### reward

Reward this contract with asset tokens
Rewarding the contract resets the vesting period


```solidity
function reward(uint256 assets) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`assets`|`uint256`|Amount of asset tokens to transfer to this contract|


### cooldownShares

Enter cooldown for amount of `shares`
Assets in cooldown are transferred to the silo contract and withdrawable at the end of cooldown
If a cooldown already exists, the cooldown asset amount is increased and cooldown resets


```solidity
function cooldownShares(uint256 shares) external returns (uint256 assets);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`shares`|`uint256`|Amount of shares to enter cooldown|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`assets`|`uint256`|Amount of assets withdrawn for cooldown|


### cooldownAssets

Enter cooldown for amount of `amount`
Assets in cooldown are transferred the silo contract and withdrawable at the end of cooldown
If a cooldown already exists, the cooldown asset amount is increased and cooldown resets


```solidity
function cooldownAssets(uint256 assets) external returns (uint256 shares);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`assets`|`uint256`|Amount of asset tokens to enter cooldown|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`shares`|`uint256`|Amount of shares redeemed for cooldown|


### unstake

Unstake all assets that are in cooldown


```solidity
function unstake(address to) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`to`|`address`|Account to receive assets|


## Events
### RewardsReceived
Emitted when new rewards are received by this contract


```solidity
event RewardsReceived(uint256 assets);
```

**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`assets`|`uint256`|Amount of asset tokens rewarded|

### VestingStarted
Emitted when a linear vesting period starts for this contract


```solidity
event VestingStarted(uint256 total, uint256 end);
```

**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`total`|`uint256`|Total assets to vest|
|`end`|`uint256`|Timestamp at which vesting is completed|

### CooldownStarted
Emitted when an account enters cooldown for `amount`


```solidity
event CooldownStarted(address indexed account, uint256 assets);
```

**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`account`|`address`|Account which entered cooldown|
|`assets`|`uint256`|Amount of asset tokens to cooldown|

### Unstake
Emitted when `from` unstakes and transfers `amount` to `to`


```solidity
event Unstake(address indexed from, address to, uint256 assets);
```

**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`from`|`address`|Account which is unstaking|
|`to`|`address`|Account to receive assets|
|`assets`|`uint256`|Amount of assets transferred|

### VestingLengthUpdated
Emitted when the vesting length gets updated


```solidity
event VestingLengthUpdated(uint128 newVestingLength);
```

**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`newVestingLength`|`uint128`|New vesting length|

### CooldownLengthUpdated
Emitted when the cooldown length gets updated


```solidity
event CooldownLengthUpdated(uint256 newCooldownLength);
```

**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`newCooldownLength`|`uint256`|New cooldown length|

## Errors
### BelowMinimumShare
Existing shares fall below minimum shares threshold


```solidity
error BelowMinimumShare();
```

### CooldownExceededMaxRedeem
Cannot withdraw more than max redeem


```solidity
error CooldownExceededMaxRedeem();
```

### CooldownExceededMaxWithdraw
Cannot withdraw more than max withdraw


```solidity
error CooldownExceededMaxWithdraw();
```

### CooldownInProgress
Cooldown has not completed


```solidity
error CooldownInProgress();
```

### ExceedsMaxCooldownLength
Max cooldown length exceeded


```solidity
error ExceedsMaxCooldownLength();
```

### ExceedsMaxVestingLength
Max vesting length exceeded


```solidity
error ExceedsMaxVestingLength();
```

### InvalidRescueToken
Cannot rescue asset token from staking contract


```solidity
error InvalidRescueToken();
```

### NonRestrictedAccount
Only restricted account


```solidity
error NonRestrictedAccount();
```

### NonZeroAddress
Only zero address


```solidity
error NonZeroAddress();
```

### RequiresCooldown
Redeem and withdrawal require cooldown


```solidity
error RequiresCooldown();
```

### SubceedsMinVestingLength
Min cooldown length subceeded


```solidity
error SubceedsMinVestingLength();
```

### VestingNotCompleted
Must not be vesting


```solidity
error VestingNotCompleted();
```

## Structs
### Vesting
Vesting data


```solidity
struct Vesting {
    uint128 length;
    uint128 end;
    uint256 assets;
}
```

**Properties**

|Name|Type|Description|
|----|----|-----------|
|`length`|`uint128`|Vesting length in seconds|
|`end`|`uint128`|Timestamp at which vesting ends|
|`assets`|`uint256`|Amount of assets vesting|

### Cooldown
Cooldown data in a packed struct


```solidity
struct Cooldown {
    uint160 assets;
    uint96 end;
}
```

**Properties**

|Name|Type|Description|
|----|----|-----------|
|`assets`|`uint160`|Amount of assets in cooldown|
|`end`|`uint96`|Timestamp at which cooldown is completed|

