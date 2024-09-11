const hre = require("hardhat");
async function main() {
  const currentTimestampInSeconds = Math.round(Date.now() / 1000);
  const unlockTime = currentTimestampInSeconds + 60;
  const lockedAmount = hre.ethers.utils.parseEther("0.001");
  const OCTA_TOKEN = await hre.ethers.deployContract("OctaToken");
  await OCTA_TOKEN.deployed();
  console.log(
    `OCTA Token smart  contract with ${hre.ethers.utils.formatEther(
      lockedAmount
    )} ETH and  timestamp ${unlockTime} is deployed to ${OCTA_TOKEN.address}`
  );
  console.log("verification process...");

  await run("verify:verify", {
    address: OCTA_TOKEN.address,
    contract: "contracts/octaToken.sol:OCTA_TOKEN",
    constructorArguments: [],
  });
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
