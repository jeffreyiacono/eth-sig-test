require("dotenv").config();
const EthCrypto = require("eth-crypto");

// const signerIdentity = EthCrypto.createIdentity();
// console.log("signerIdentity:");
// console.log(signerIdentity);
//const message = EthCrypto.hash.keccak256("\x19Ethereum Signed Message:\n32", [
//  { type: "string", value: "Hello World!" },
//]);

const contractAddress = "0x1a51053bD31cbbDbf0a5EAB4517E74435e9C397B";
const payeeAddress = "0x39Cd295191EdF125b46a5e73593666f1b238B7e8";

console.log("⚙️  Generating signatures for", contractAddress);
const claimPaymentMessage = EthCrypto.hash.keccak256([
  { type: "address", value: payeeAddress },
  { type: "uint256", value: "1" },
  { type: "uint256", value: "1" },
  { type: "address", value: contractAddress },
]);
const claimPaymentSignature = EthCrypto.sign(
  process.env.PRIVATE_KEY,
  claimPaymentMessage
);

console.log(
  ` - 📝  Hashed claimPaymentMessage that can be used with sig to verify signer: ${claimPaymentMessage}`
);
console.log(
  ` - ✍️  Signature to use for claimPayment: ${claimPaymentSignature}`
);

const claimCodeMessage = EthCrypto.hash.keccak256([
  { type: "string", value: "dan tong #1" },
  { type: "address", value: contractAddress },
]);
const claimCodeSignature = EthCrypto.sign(
  process.env.PRIVATE_KEY,
  claimCodeMessage
);

console.log(
  ` - 📝  Hashed claimCodeMessage that can be used with sig to verify signer: ${claimCodeMessage}`
);
console.log(
  ` - ✍️  Signature to use for claimCodeSignature: ${claimCodeSignature}`
);
