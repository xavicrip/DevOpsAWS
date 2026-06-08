const fs = require("fs");
const path = require("path");
const hre = require("hardhat");

/**
 * Despliega RegistroCertificados y genera frontend/deployment.json con la
 * dirección del contrato + ABI + red. El frontend lee ese archivo para conectarse.
 */
async function main() {
  const red = hre.network.name;
  console.log(`\n🚀 Desplegando RegistroCertificados en la red: ${red}`);

  const [deployer] = await hre.ethers.getSigners();
  console.log(`   Cuenta: ${deployer.address}`);

  const Factory = await hre.ethers.getContractFactory("RegistroCertificados");
  const contrato = await Factory.deploy();
  await contrato.waitForDeployment();

  const direccion = await contrato.getAddress();
  console.log(`✅ Contrato desplegado en: ${direccion}`);

  // ABI desde el artefacto compilado.
  const artifact = await hre.artifacts.readArtifact("RegistroCertificados");

  const deployment = {
    network: red,
    chainId: Number((await hre.ethers.provider.getNetwork()).chainId),
    address: direccion,
    deployedAt: new Date().toISOString(),
    abi: artifact.abi,
  };

  const salida = path.join(__dirname, "..", "frontend", "deployment.json");
  fs.mkdirSync(path.dirname(salida), { recursive: true });
  fs.writeFileSync(salida, JSON.stringify(deployment, null, 2));
  console.log(`📝 Escrito: frontend/deployment.json`);
  console.log(`\n   Recuerda volver a desplegar y regenerar este archivo tras cada cambio del contrato.\n`);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
