# Glosario

## DevOps / Nube

- **CI (Integración Continua):** integrar y probar el código automáticamente en cada cambio.
- **CD (Entrega/Despliegue Continuo):** dejar el software siempre listo para desplegar, o
  desplegarlo automáticamente.
- **Pipeline:** secuencia automatizada de etapas (build, test, deploy).
- **IaC (Infraestructura como Código):** definir infraestructura en archivos versionados
  (Terraform).
- **Artefacto:** resultado de un build (p. ej. el frontend listo para publicar).
- **Free tier:** nivel gratuito de uso de un servicio en la nube.
- **IAM:** servicio de AWS para gestionar identidades y permisos.
- **Mínimo privilegio:** dar solo los permisos estrictamente necesarios.

## DevSecOps

- **Shift-left:** adelantar la seguridad a las primeras etapas del ciclo.
- **SAST:** análisis estático de seguridad del código (sin ejecutarlo).
- **SCA:** análisis de dependencias en busca de vulnerabilidades conocidas (CVE).
- **CVE:** identificador público de una vulnerabilidad conocida.
- **Secreto:** dato sensible (clave privada, API key) que nunca debe ir al repositorio.

## Blockchain / Ethereum

- **Contrato inteligente (smart contract):** programa que vive en la blockchain y se
  ejecuta de forma determinista.
- **Solidity:** lenguaje de los contratos en Ethereum.
- **Gas:** costo de ejecutar operaciones que cambian el estado de la blockchain.
- **Wei / Ether:** unidades de la moneda de Ethereum.
- **ABI:** descripción de las funciones de un contrato; el frontend la usa para llamarlo.
- **Hash (keccak256):** huella digital única; aquí, el identificador de cada certificado.
- **Evento:** registro que emite un contrato; forma el rastro de auditoría.
- **MetaMask:** billetera en el navegador para firmar transacciones.
- **Testnet:** red de pruebas (p. ej. **Sepolia**) con ETH sin valor real.
- **Faucet:** servicio que regala ETH de testnet.
- **Nodo RPC:** punto de acceso a la blockchain (Alchemy, Infura, nodo local de Hardhat).
- **chainId:** identificador numérico de una red (31337 = Hardhat local, 11155111 = Sepolia).
- **Inmutabilidad:** una vez registrado, un dato no se puede alterar ni borrar.

## Herramientas

- **Hardhat:** entorno de desarrollo para Ethereum (compilar, probar, desplegar).
- **ethers.js:** librería JavaScript para interactuar con Ethereum.
- **Slither:** analizador estático de seguridad para Solidity.
- **Solhint:** linter de Solidity.
- **Terraform:** herramienta de IaC multi-nube.
- **AWS Amplify:** hosting gestionado para apps web con CI/CD.
- **CodePipeline / CodeBuild:** servicios de CI/CD nativos de AWS.
