require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config();

// Variables de entorno opcionales (solo necesarias para desplegar en una testnet pública).
// NUNCA pongas tu clave privada real aquí: usa el archivo .env (ignorado por git).
const SEPOLIA_RPC_URL = process.env.SEPOLIA_RPC_URL || "";
const PRIVATE_KEY = process.env.PRIVATE_KEY || "";
const ETHERSCAN_API_KEY = process.env.ETHERSCAN_API_KEY || "";

/** @type {import('hardhat/config').HardhatUserConfig} */
module.exports = {
  solidity: {
    version: "0.8.24",
    settings: {
      optimizer: { enabled: true, runs: 200 },
    },
  },
  networks: {
    // Nodo local de Hardhat (chainId 31337). Se usa con `npm run node`.
    localhost: {
      url: "http://127.0.0.1:8545",
    },
    // Testnet pública Sepolia. Solo se activa si defines las variables en .env.
    sepolia: {
      url: SEPOLIA_RPC_URL,
      accounts: PRIVATE_KEY ? [PRIVATE_KEY] : [],
      chainId: 11155111,
    },
  },
  etherscan: {
    apiKey: ETHERSCAN_API_KEY,
  },
};
