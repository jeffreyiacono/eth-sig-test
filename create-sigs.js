require("dotenv").config();
const EthCrypto = require("eth-crypto");

const contractAddress = "0x1a51053bD31cbbDbf0a5EAB4517E74435e9C397B";
const payeeAddress = "0x39Cd295191EdF125b46a5e73593666f1b238B7e8";

hashAndSign = (content, private_key) => {
  const message = EthCrypto.hash.keccak256(content);
  const signature = EthCrypto.sign(private_key, message);
  return [message, signature];
};

console.log("⚙️  Generating signatures for contract @", contractAddress);
// TODO: add the header + message len + message ...
//const message = EthCrypto.hash.keccak256("\x19Ethereum Signed Message:\n32"...

console.log("\n");
console.log("🏦 Checking account (ie. claim payment) example ...");
const [claimPaymentMessage, claimPaymentSignature] = hashAndSign(
  [
    { type: "address", value: payeeAddress },
    { type: "uint256", value: "1" },
    { type: "uint256", value: "1" },
    { type: "address", value: contractAddress },
  ],
  process.env.PRIVATE_KEY
);
console.log(
  ` - 📝 Hashed claimPaymentMessage that can be used with sig to verify signer: ${claimPaymentMessage}`
);
console.log(
  ` - ✍️  Signature to use for claimPayment: ${claimPaymentSignature}`
);

console.log("\n");
console.log("🕵️‍♀️  Claim code example ...");
const [claimCodeMessage, claimCodeSignature] = hashAndSign(
  [
    { type: "string", value: "dan tong #1" },
    { type: "address", value: contractAddress },
  ],
  process.env.PRIVATE_KEY
);
console.log(
  ` - 📝 Hashed claimCodeMessage that can be used with sig to verify signer: ${claimCodeMessage}`
);
console.log(
  ` - ✍️  Signature to use for claimCodeSignature: ${claimCodeSignature}`
);
