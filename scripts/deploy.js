const main = async () => {
  const [deployer] = await hre.ethers.getSigners();
  const accountBalance = await deployer.getBalance();

  console.log("Deploying contracts with account:", deployer.address);
  console.log("Account balance:", accountBalance.toString());

  const signatureUseCasesFactory = await hre.ethers.getContractFactory(
    "SignatureUseCases"
  );
  const signatureUseCasesContract = await signatureUseCasesFactory.deploy();
  await signatureUseCasesContract.deployed();
  console.log("SignatureUseCases address:", signatureUseCasesContract.address);
};

const runMain = async () => {
  try {
    await main();
    process.exit(0);
  } catch (error) {
    console.error(error);
    process.exit(1);
  }
};

runMain();
