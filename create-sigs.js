require("dotenv").config();
const EthCrypto = require("eth-crypto");

// const signerIdentity = EthCrypto.createIdentity();
// console.log("signerIdentity:");
// console.log(signerIdentity);
//const message = EthCrypto.hash.keccak256("\x19Ethereum Signed Message:\n32", [
//  { type: "string", value: "Hello World!" },
//]);

const contractAddress = "0xf2899ad13B7F97Bc3e01DC4a5a8d273ea7752609";
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

// console.log(`Message: ${claimPaymentMessage}`);
console.log(
  ` - ✍️  Signature to use for claimPayment: ${claimPaymentSignature}`
);

const claimBountyMessage = EthCrypto.hash.keccak256([
  { type: "string", value: "dan tong #1" },
  { type: "address", value: contractAddress },
]);
const claimBountySignature = EthCrypto.sign(
  process.env.PRIVATE_KEY,
  claimBountyMessage
);

// console.log(`Message: ${claimBountyMessage}`);
console.log(
  ` - ✍️  Signature to use for claimPayment: ${claimBountySignature}`
);
