# StakedAsset
[Git Source](https://github.com/tenbinlabs/monorepo/blob/4fdd65603a4c48b6527407c6f86f93c378ffa140/src/StakedAsset.sol)

**Inherits:**
[IStakedAsset](/Users/tenbin/code/monorepo/packages/contracts/docs/src/src/interface/IStakedAsset.sol/interface.IStakedAsset.md), [IRestrictedRegistry](/Users/tenbin/code/monorepo/packages/contracts/docs/src/src/interface/IRestrictedRegistry.sol/interface.IRestrictedRegistry.md), ERC20Permit, ERC4626, AccessControl

Allows staking an asset token for a staking token
Rewards can be sent to this contract to reward stakers proportionally to their stake
Includes a vesting period over which pending rewards are linearly vested
Whenever a reward is paid to the contract, the vesting period resets
Includes a cooldown period over which a user must wait between cooldown and withdrawing
When cooldownLength > 0, the normal withdraw() and redeem() functions will revert
Users call cooldownShares() and cooldownAssets() to initiate cooldown
If a cooldown already exists for a user, initiating cooldown again with additional assets will reset the cooldown time
Users do not earn rewards for assets during the cooldown period
Assets in cooldown are stored in a Silo contract until cooldown is complete
After the cooldown is completed, users can call withdraw() to claim their asset tokens
In order to avoid a first depositor donation attack a minimum stake should be made in the same transaction as the contract deployment


## State Variables
### REWARDER_ROLE
Rewarder role transfers asset tokens into the contract


```solidity
bytes32 constant REWARDER_ROLE = keccak256("REWARDER_ROLE")
```


### ADMIN_ROLE
Admin role can change vesting and cooldown period


```solidity
bytes32 constant ADMIN_ROLE = keccak256("ADMIN_ROLE")
```


### RESTRICTER_ROLE
Restricter role can change restricted status of accounts


```solidity
bytes32 constant RESTRICTER_ROLE = keccak256("RESTRICTER_ROLE")
```


### MAX_COOLDOWN_LENGTH
Max cooldown period


```solidity
uint256 public constant MAX_COOLDOWN_LENGTH = 90 days
```


### MAX_VESTING_LENGTH
Max vesting period


```solidity
uint256 public constant MAX_VESTING_LENGTH = 90 days
```


### MIN_VESTING_LENGTH
Min vesting period to prevent rounding errors when calculating rewards within 0.1%


```solidity
uint256 public constant MIN_VESTING_LENGTH = 1200 seconds
```


### MIN_SHARES
Minimum amount of shares allowed


```solidity
uint256 public constant MIN_SHARES = 1e18
```


### silo
AssetSilo holds assets during cooldown


```solidity
AssetSilo public immutable silo
```


### cooldowns
Amount of shares in cooldown for an account


```solidity
mapping(address => Cooldown) public cooldowns
```


### cooldownLength
Cooldown period for unstaking in seconds


```solidity
uint256 public cooldownLength
```


### vesting
Vesting data


```solidity
Vesting public vesting
```


### isRestricted
Keep track of restricted addresses


```solidity
mapping(address => bool) public isRestricted
```


## Functions
### nonZeroAddress

Revert if zero address


```solidity
modifier nonZeroAddress(address addr) ;
```

### nonRestricted

Reverts if account is restricted


```solidity
modifier nonRestricted(address account) ;
```

### constructor


```solidity
constructor(string memory name_, string memory symbol_, IERC20 asset_, address owner_)
    ERC20(name_, symbol_)
    ERC20Permit(name_)
    ERC4626(asset_)
    nonZeroAddress(owner_);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`name_`|`string`|Name of this token|
|`symbol_`|`string`|Symbol for this token|
|`asset_`|`IERC20`|Asset to stake and reward|
|`owner_`|`address`||


### pendingRewards

Get pending rewards for this contract


```solidity
function pendingRewards() external view returns (uint256 amount);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`amount`|`uint256`|Pending unvested rewards|


### reward

Reward this contract with asset tokens
Rewarding the contract resets the vesting period


```solidity
function reward(uint256 assets) external onlyRole(REWARDER_ROLE);
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
function cooldownShares(uint256 shares) external nonRestricted(msg.sender) returns (uint256 assets);
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
function cooldownAssets(uint256 assets) external nonRestricted(msg.sender) returns (uint256 shares);
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

Unstake shares that are in cooldown


```solidity
function unstake(address to) external nonRestricted(msg.sender) nonZeroAddress(to);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`to`|`address`|Account to transfer assets to|


### setVestingLength

Set a new vesting period

Note: setting low vesting lengths causes rounding issues


```solidity
function setVestingLength(uint128 newVestingLength) external onlyRole(ADMIN_ROLE);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`newVestingLength`|`uint128`|New vesting period|


### setCooldownLength

Set a new cooldown period


```solidity
function setCooldownLength(uint256 newCooldownLength) external onlyRole(ADMIN_ROLE);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`newCooldownLength`|`uint256`|New cooldown period|


### setIsRestricted

Sets or unsets an address as restricted


```solidity
function setIsRestricted(address account, bool newStatus) external onlyRole(RESTRICTER_ROLE);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`account`|`address`|The address to update|
|`newStatus`|`bool`|The new restriction status|


### transferRestrictedAssets

Withdraw assets from a restricted account.
Without the ability to redeem frozen shares, a portion of rewards will be stuck in the contract
Always redeems the full balance of the restricted account


```solidity
function transferRestrictedAssets(address from, address to)
    external
    nonZeroAddress(to)
    onlyRole(DEFAULT_ADMIN_ROLE);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`from`|`address`|Restricted account to redeem shares from|
|`to`|`address`|Account to transfer assets to|


### deposit

Overrides the deposit function to include restricted address check


```solidity
function deposit(uint256 assets, address receiver)
    public
    override
    nonRestricted(msg.sender)
    nonRestricted(receiver)
    returns (uint256 shares);
```

### decimals

Get number of decimals for this token


```solidity
function decimals() public pure override(ERC4626, ERC20) returns (uint8);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint8`|Decimals for this token|


### withdraw

Withdraw function which reverts when cooldown is active


```solidity
function withdraw(uint256 assets, address receiver, address owner) public override returns (uint256);
```

### redeem

Redeem function which requires cooldown


```solidity
function redeem(uint256 shares, address receiver, address owner) public override returns (uint256);
```

### totalAssets

Calculate total assets minus pending reward


```solidity
function totalAssets() public view override returns (uint256);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|Total assets not including pending reward|


### rescueToken

Rescue tokens sent to this contract

the receiver should be a trusted address to avoid external calls attack vectors


```solidity
function rescueToken(address token, address to) external onlyRole(ADMIN_ROLE) nonZeroAddress(to);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`token`|`address`|The address of the ERC20 token to be rescued|
|`to`|`address`|Recipient of rescued tokens|


### transfer

Override transfer function to prevent restricted accounts from transferring


```solidity
function transfer(address to, uint256 value)
    public
    override(IERC20, ERC20)
    nonRestricted(msg.sender)
    nonRestricted(to)
    returns (bool);
```

### transferFrom


```solidity
function transferFrom(address from, address to, uint256 value)
    public
    override(IERC20, ERC20)
    nonRestricted(from)
    nonRestricted(to)
    returns (bool);
```

### _withdraw

Override of _withdraw to enforce minimum shares remain


```solidity
function _withdraw(address caller, address receiver, address _owner, uint256 assets, uint256 shares)
    internal
    override;
```

### _pendingRewards

Calculate pending reward based on vesting time and length


```solidity
function _pendingRewards() internal view returns (uint256 pending);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`pending`|`uint256`|Pending unvested rewards|


### _checkMinShares

Ensures a small non-zero amount of shares always remains


```solidity
function _checkMinShares() internal view;
```

