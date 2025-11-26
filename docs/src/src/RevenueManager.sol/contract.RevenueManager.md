# RevenueManager
[Git Source](https://github.com/tenbinlabs/monorepo/blob/da910f0c2c716e97403280ebf4847131ed4404b1/src/RevenueManager.sol)

**Inherits:**
[IRevenueManager](/Users/tenbin/code/monorepo/packages/contracts/docs/src/src/interface/IRevenueManager.sol/interface.IRevenueManager.md), AccessControl

The revenue manager is authorized to distribute revenue
collected from the collateral manager.


## State Variables
### KEEPER_ROLE
Keeper role can pull revenue from collateral manager and withdraw funds to manager and staking


```solidity
bytes32 public constant KEEPER_ROLE = keccak256("KEEPER_ROLE")
```


### manager
Address of collateral manager contract


```solidity
address public manager
```


### multisig
Address of multisig account


```solidity
address public multisig
```


### staking
Address of staking collateral pool


```solidity
address public staking
```


## Functions
### nonZeroAddress

Revert if zero address


```solidity
modifier nonZeroAddress(address addr) ;
```

### constructor

Constructor


```solidity
constructor(address manager_, address multisig_, address staking_, address owner_) ;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`manager_`|`address`|Manager account|
|`multisig_`|`address`|Multisig account|
|`staking_`|`address`|Staking contract address|
|`owner_`|`address`|Default admin for this contract|


### pull

Withdraw total pending revenue from collateral manager


```solidity
function pull(address token) external override onlyRole(KEEPER_ROLE) nonZeroAddress(token);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`token`|`address`|Token address to be checked for pending revenue|


### withdrawToMultisig

Transfer tokens to an multisig account (multisig)


```solidity
function withdrawToMultisig(address token, uint256 amount) external override nonZeroAddress(token);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`token`|`address`|Token address to be withdrawn|
|`amount`|`uint256`|Amount of tokens to withdraw|


### withdrawToManager

Transfer tokens to collateral manager


```solidity
function withdrawToManager(address token, uint256 amount)
    external
    override
    onlyRole(KEEPER_ROLE)
    nonZeroAddress(token);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`token`|`address`|Token address to be withdrawn|
|`amount`|`uint256`|Amount of tokens to withdraw|


### reward

Transfer tokens to staking contract


```solidity
function reward(address token, uint256 amount) external override onlyRole(KEEPER_ROLE) nonZeroAddress(token);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`token`|`address`|Token address to be sent|
|`amount`|`uint256`|Amount of tokens to reward|


### setManager

Change the manager account


```solidity
function setManager(address newManager) external onlyRole(DEFAULT_ADMIN_ROLE) nonZeroAddress(newManager);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`newManager`|`address`|New manager account|


### setMultisig

Change the multisig account


```solidity
function setMultisig(address newMultisig) external onlyRole(DEFAULT_ADMIN_ROLE) nonZeroAddress(newMultisig);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`newMultisig`|`address`|New multisig account|


### setStaking

Change the staking contract address


```solidity
function setStaking(address newStakingContract)
    external
    onlyRole(DEFAULT_ADMIN_ROLE)
    nonZeroAddress(newStakingContract);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`newStakingContract`|`address`|New staking contract address|


### _sendFunds

Helper function to handle token transfers


```solidity
function _sendFunds(address to, address token, uint256 amount) private;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`to`|`address`|Receiver of tokens|
|`token`|`address`|Token address to be sent|
|`amount`|`uint256`|Amount to be sent|


