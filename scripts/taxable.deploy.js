const hre = require("hardhat");

async function main() {
  const currentTimestampInSeconds = Math.round(Date.now() / 1000);
  const unlockTime = currentTimestampInSeconds + 60;
  const initialSupply = hre.ethers.utils.parseUnits("1000", 18);
  const taxPercentage = 5;
  const taxWallet = "0xD6a922890a75771d6885ec106185F1BB5E7b2384";

  const TaxableTokenFactory = await hre.ethers.getContractFactory(
    "TaxableToken"
  );
  const TaxableToken = await TaxableTokenFactory.deploy(
    "Taxable Token",
    "TN",
    initialSupply,
    taxPercentage,
    taxWallet
  );

  await TaxableToken.deployed();

  console.log(`TaxableToken contract deployed to ${TaxableToken.address}`);

  console.log("Verification process...");
  await hre.run("verify:verify", {
    address: TaxableToken.address,
    contract: "contracts/TaxableToken.sol:TaxableToken",
    constructorArguments: [
      "TaxableTokenName",
      "TTN",
      initialSupply,
      taxPercentage,
      taxWallet,
    ],
  });
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
