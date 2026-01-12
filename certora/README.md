# Certora for Tenbin Contracts

## Install
Install certora: https://docs.certora.com/en/latest/docs/user-guide/install.html

## Run

Ensure CERTORAKEY is set in .env.

Example verification:

```certoraRun src/StakedAsset.sol --verify StakedAsset:certora/specs/StakedAsset.spec```

### Scripts

Verify StakedAsset.sol: ```./certora/scripts/verifyStakedAsset.sh```