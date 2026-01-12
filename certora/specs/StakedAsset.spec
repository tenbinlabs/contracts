// StakedAsset.spec

methods {
    function initialize(string, string, address, address) external envfree;
}

// cannot initialize again
rule cannotReinitialize() {
    string name; string symbol; address asset; address owner;

    env e;

    initialize(e, name, symbol, asset, owner);

    initialize@withrevert(e, name, symbol, asset, owner);

    assert lastReverted;
}