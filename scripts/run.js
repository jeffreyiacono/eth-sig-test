const main = async () => {
  const [owner, randomPerson] = await hre.ethers.getSigners();
  const signatureUseCasesFactory = await hre.ethers.getContractFactory(
    "SignatureUseCases"
  );
  const signatureUseCasesContract = await signatureUseCasesFactory.deploy();
  await signatureUseCasesContract.deployed();
  console.log("✅ Contract deployed to:", signatureUseCasesContract.address);
  console.log("🥳 Contract deployed by:", owner.address);
};

const runMain = async () => {
  try {
    await main();
    process.exit(0);
  } catch (error) {
    console.log(error);
    process.exit(1);
  }
};

runMain();
