// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract SignatureUseCases {
    address public owner = msg.sender;
    uint public balance;

    mapping(uint256 => bool) usedNonces;

    constructor() {
        balance = 0;
    }

    function deposit() public payable restrictedToOwner {
        balance += msg.value;
    }

    // like a checking account -- amount is check amount, nonce is physical check, sig is verification
    // that check if valid
    function claimPayment(uint256 amount, uint256 nonce, bytes memory sig) public {
        require(!usedNonces[nonce]);
        usedNonces[nonce] = true;

        require(isValidDataForAmountNonce(amount, nonce, sig), "Invalid signature");
        require(balance - amount >= 0, "Insufficient funds, owner needs to deposit more");

        (bool sent, ) = msg.sender.call{value: amount}("");
        require(sent, "Failed to send Ether");
    }

    // received a code for accomplishing something first (coding challenge, physically
    // going somewhere that had the code, etc.) -- amount hardcoded
    function claimBounty(string memory code, bytes memory sig) public {
        uint amount = 0.1 ether;
        require(isValidDataForCode(code, sig), "Invalid signature");
        require(balance - amount >= 0, "Insufficient funds, owner needs to deposit more");

        (bool sent, ) = msg.sender.call{value: amount}("");
        require(sent, "Failed to send Ether");
    }

    // Destroy contract and reclaim leftover funds.
    function destory() public restrictedToOwner {
        selfdestruct(payable(owner));
    }

    function isValidDataForAmountNonce(uint256 _transferAmount, uint256 _nonce, bytes memory sig) private view returns (bool){
        bytes32 message = prefixed(keccak256(abi.encodePacked(_transferAmount, _nonce, address(this))));
        return (recoverSigner(message, sig) == owner);
    }

    function isValidDataForCode(string memory _code, bytes memory sig) private view returns (bool){
        bytes32 message = prefixed(keccak256(abi.encodePacked(_code, address(this))));
        return (recoverSigner(message, sig) == owner);
    }

    // Signature methods
    function recoverSigner(bytes32 message, bytes memory sig) private pure returns (address) {
        uint8 v;
        bytes32 r;
        bytes32 s;
        (v, r, s) = splitSignature(sig);
        return ecrecover(message, v, r, s);
    }

    function splitSignature(bytes memory sig) private pure returns (uint8, bytes32, bytes32) {
        require(sig.length == 65);
        uint8 v;
        bytes32 r;
        bytes32 s;

        assembly {
            // first 32 bytes, after the length prefix
            r := mload(add(sig, 32))
            // second 32 bytes
            s := mload(add(sig, 64))
            // final byte (first byte of the next 32 bytes)
            v := byte(0, mload(add(sig, 96)))
        }

        return (v, r, s);
    }

    // Builds a prefixed hash to mimic the behavior of eth_sign.
    function prefixed(bytes32 hash) internal pure returns (bytes32) {
        return (hash);
        //return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }

    modifier restrictedToOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }
}
