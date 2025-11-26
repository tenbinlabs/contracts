# IRevenueManager
[Git Source](https://github.com/tenbinlabs/monorepo/blob/da910f0c2c716e97403280ebf4847131ed4404b1/src/interface/IRevenueManager.sol)

Revenue Manager interface


## Functions
### pull

Withdraw total pending revenue from collateral manager


```solidity
function pull(address token) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`token`|`address`|Token address to be checked for pending revenue|


### withdrawToMultisig

Transfer tokens to an multisig account (multisig)


```solidity
function withdrawToMultisig(address token, uint256 amount) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`token`|`address`|Token address to be withdrawn|
|`amount`|`uint256`|Amount of tokens to withdraw|


### withdrawToManager

Transfer tokens to collateral manager


```solidity
function withdrawToManager(address token, uint256 amount) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`token`|`address`|Token address to be withdrawn|
|`amount`|`uint256`|Amount of tokens to withdraw|


### reward

Transfer tokens to staking contract


```solidity
function reward(address token, uint256 amount) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`token`|`address`|Token address to be sent|
|`amount`|`uint256`|Amount of tokens to reward|


## Events
### RevenuePulled
Emitted when revenue is withdrawn from collateral manager to self


```solidity
event RevenuePulled(address indexed token, uint256 amount);
```

**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`token`|`address`|The requested token to be withdrawn|
|`amount`|`uint256`|The amount of revenue tokens|

### WithdrawToMultisig
Emitted when revenue is sent to the multisig


```solidity
event WithdrawToMultisig(address indexed token, uint256 amount);
```

**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`token`|`address`|The requested token to be withdrawn|
|`amount`|`uint256`|The amount of revenue tokens|

### WithdrawToManager
Emitted when revenue is sent to the manager


```solidity
event WithdrawToManager(address indexed token, uint256 amount);
```

**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`token`|`address`|The requested token to be withdrawn|
|`amount`|`uint256`|The amount of revenue tokens|

### RewardSent
Emitted when revenue is sent to the staking contract


```solidity
event RewardSent(address indexed token, uint256 amount);
```

**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`token`|`address`|The requested token to be withdrawn|
|`amount`|`uint256`|The amount of rewarded tokens|

### MultisigUpdated
Emitted when multisig is updated


```solidity
event MultisigUpdated(address indexed newMultisig);
```

**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`newMultisig`|`address`|New multisig address|

### ManagerUpdated
Emitted when collateral manager contract is updated


```solidity
event ManagerUpdated(address indexed newManager);
```

**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`newManager`|`address`|New collateral manager address|

### StakingUpdated
Emitted when staking contract is updated


```solidity
event StakingUpdated(address indexed newStaking);
```

**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`newStaking`|`address`|New staking contract address|

## Errors
### NonZeroAddress
Invalid zero address


```solidity
error NonZeroAddress();
```

### InsufficientBalance
Amount specified for transfer is bigger than available balance


```solidity
error InsufficientBalance();
```

### InsufficientRevenue
Token had no pending revenue to pull


```solidity
error InsufficientRevenue();
```

### InvalidAmount
Invalid transfer amount


```solidity
error InvalidAmount();
```

### OnlyMultisig
Sender is not multisig


```solidity
error OnlyMultisig();
```

