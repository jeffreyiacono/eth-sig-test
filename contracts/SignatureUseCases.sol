// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract SignatureUseCases {
    address public owner = msg.sender;
    uint public balanceInWei;

    mapping(uint256 => bool) usedNonces;
    mapping(string => bool) usedCodes;

    constructor() {
        balanceInWei = 0;
    }

    function deposit() public payable restrictedToOwner {
        balanceInWei += msg.value;
    }

    // Like a checking account -- payeeAddress is where the amount will go,
    // nonce prevents re-usage, and sig verifies owner has authorized this
    // transfer
    //
    // If a malicious actor got their hands on all of this information, all
    // they would be doing is paying the fees to have this transfer performed.
    function claimPayment(address payeeAddress, uint256 amountInEther, uint256 nonce, bytes memory sig) public {
        require(!usedNonces[nonce]);
        usedNonces[nonce] = true;

        uint256 amountInWei = amountInEther * 1e18;
        balanceInWei -= amountInWei;
        require(balanceInWei >= 0, "Insufficient funds, owner needs to deposit more");
        require(isValidDataToClaimPayment(payeeAddress, amountInEther, nonce, sig), "Invalid signature");

        payable(payeeAddress).transfer(amountInWei);
    }

    // Received a code for accomplishing something first (coding challenge, physically
    // going somewhere that had the code, etc.) -- amount hardcoded
    function claimCode(string memory code, bytes memory sig) public {
        require(!usedCodes[code]);
        usedCodes[code] = true;

        uint amountInWei = 1e18; // 1 ether, or could make dyanmic w/ code changes

        balanceInWei -= amountInWei;
        require(balanceInWei >= 0, "Insufficient funds, owner needs to deposit more");
        require(isValidDataToClaimCode(code, sig), "Invalid signature");

        payable(msg.sender).transfer(amountInWei);
    }

    // Destroy contract and return leftover funds to owner
    function destory() public restrictedToOwner {
        selfdestruct(payable(owner));
    }

    function isValidDataToClaimPayment(address _payeeAddress, uint256 _transferAmount, uint256 _nonce, bytes memory sig) public view returns (bool){
        bytes32 message = prefixed(keccak256(abi.encodePacked(_payeeAddress, _transferAmount, _nonce, address(this))));
        return signerIsContractOwner(message, sig);
    }

    function isValidDataToClaimCode(string memory _code, bytes memory sig) public view returns (bool){
        bytes32 message = prefixed(keccak256(abi.encodePacked(_code, address(this))));
        return signerIsContractOwner(message, sig);
    }

    // Signature methods
    function signerIsContractOwner(bytes32 message, bytes memory sig) public view returns (bool) {
      return (recoverSigner(message, sig) == owner);
    }

    function recoverSigner(bytes32 message, bytes memory sig) public pure returns (address) {
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
