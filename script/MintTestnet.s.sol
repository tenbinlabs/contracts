// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

import {BaseScript} from "script/Base.s.sol";
import {console} from "forge-std/console.sol";
import {Controller} from "src/Controller.sol";
import {IController} from "src/interface/IController.sol";

/// @notice Script to mint tokens on testnet
/// 1) Ensure MINTER_ADDRESS, MINTER_KEY, and SIGNER_KEY are set in .env
/// 2) Ensure approval is granted from payer key
/// cast send 0x7cA0A09271a963EdE5773C219283B36359B12824 "approve(address,uint256)" 0x9660c651D5e1076dF48757839089819700A4c667 1000000000000000000000000000000 --rpc-url $SEPOLIA_RPC_URL --private-key $PAYER_KEY
/// 3) Run the mint script
/// forge script script/MintTestnet.s.sol --rpc-url $SEPOLIA_RPC_URL --private-key $MINTER_KEY --broadcast
/// THIS SCRIPT IS NOT SAFE TO RUN ON MAINNET!!
contract MintTestnetScript is BaseScript {
    /// @notice Sepolia controller
    address internal constant CONTROLLER_ADDRESS = 0x9660c651D5e1076dF48757839089819700A4c667;
    /// @notice Testnet signer
    address internal constant SIGNER_ADDRESS = 0xfB1EE3e318F7cd128b0c8684942e6d96853FaC77;
    /// @notice Payer account
    address internal constant PAYER_ADDRESS = 0x20289E3C968bC68C1fF53620AeEa14892a68BAB9;
    /// @notice Recipient account
    address internal constant RECIPIENT_ADDRESS = 0x20289E3C968bC68C1fF53620AeEa14892a68BAB9;
    /// @notice Collateral address
    address internal constant COLLATERAL_ADDRESS = 0x7cA0A09271a963EdE5773C219283B36359B12824;
    /// @notice Minter role
    bytes32 internal constant MINTER_ROLE = keccak256("MINTER_ROLE");

    constructor() {
        broadcaster = vm.envOr({name: "MINTER_ADDRESS", defaultValue: address(0)});
    }

    /// @notice Get order for this mint from
    function getOrder(uint256 nonce) public view returns (IController.Order memory order) {
        /// The order we want to create
        order = IController.Order({
            order_type: IController.OrderType.Mint,
            nonce: nonce,
            expiry: block.timestamp + 60 minutes,
            payer: PAYER_ADDRESS,
            recipient: RECIPIENT_ADDRESS,
            collateral_token: COLLATERAL_ADDRESS,
            collateral_amount: 100_000e6, // 100k usdc
            asset_amount: 238e17 // 23.8k gold
        });
    }

    /// @notice Execute a mint on sepolia. Must be called using minter key
    function run() public broadcast {
        // set up
        Controller controller = Controller(CONTROLLER_ADDRESS);
        uint256 nonce = block.number;
        IController.Order memory order = getOrder(nonce);
        uint256 payerKey = vm.envUint("SIGNER_KEY");
        address signer = vm.rememberKey(payerKey);
        require(controller.hasRole(MINTER_ROLE, broadcaster) == true, "Broadcaster must be minter");
        controller.verifyNonce(signer, nonce);

        // get order hash and sign
        bytes32 orderHash = controller.hashOrder(order);
        IController.Signature memory signature = signOrder(payerKey, orderHash);
        console.log("\nSignature bytes: \n");
        console.logBytes(signature.signature_bytes);

        // perform mint
        controller.mint(order, signature);
        console.log("mint success.");
        console.log("recipient: ", order.recipient);
    }

    /// @notice function to sign an order hash
    function signOrder(uint256 payerKey, bytes32 orderHash)
        internal
        pure
        returns (IController.Signature memory signature)
    {
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(payerKey, orderHash);
        signature = IController.Signature({
            signature_type: IController.SignatureType.EIP712, signature_bytes: abi.encodePacked(r, s, v)
        });
    }

    // mark this as a test contract
    function test() public {}
}
