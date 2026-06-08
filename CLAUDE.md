# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Current state

The repo is fully scaffolded and the 12 tests pass. It contains: the contract (`contracts/RegistroCertificados.sol`), tests (`test/`), deploy script (`scripts/deploy.js`), the DApp (`frontend/`), CI/CD (`.github/workflows/ci.yml`, `devsecops.yml`), AWS IaC (`infra/terraform/` — Amplify + CodePipeline/CodeBuild), `buildspec.yml`, full docs (`docs/01-investigacion` … `05-nube`) and student guides (`guias/`).

The audience is students. Code and docs are written in **Spanish** — keep that language for identifiers, comments, contract function names, and documentation.

## Cloud / AWS layer

Hosting and CI/CD run on **AWS**, provisioned entirely with **Terraform** in `infra/terraform/`:
- **Amplify** (`amplify.tf`) hosts the static frontend, auto-building on each push to the configured GitHub branch.
- **CodePipeline + CodeBuild** (`codepipeline.tf`) run the on-chain CI/CD: `buildspec.yml` does install → lint → compile → test, and optionally `npm run deploy:sepolia`.
- The GitHub source uses a **CodeStar Connection** that starts `PENDING` and must be authorized manually in the AWS console — this is the #1 student gotcha (documented in `guias/05-despliegue-aws.md`).
- Secrets (RPC URL, private key) live in **SSM Parameter Store**, never in code. `.gitignore` excludes `.env`, `terraform.tfvars`, `*.key`, `*.pem`, and `frontend/deployment.json`.
- Always remind students to run `terraform destroy` after the lab to stay in the free tier.

The full step-by-step AWS guide is `guias/05-despliegue-aws.md`; the cloud architecture rationale is `docs/05-nube/README.md`.

## Project goal

A didactic, fully-functional lab for learning DevOps and DevSecOps applied to blockchain, built around one case study: a DApp for **registering academic certificates** (`RegistroCertificados`) on Ethereum.

## Commands

These are the npm scripts the README commits to (define them in `package.json` when scaffolding):

| Command | Purpose |
|---------|---------|
| `npm install` | Install all deps (Hardhat, ethers, Solhint, Prettier); solc 0.8.24 is fetched by Hardhat on first compile |
| `npm test` | Run the 12 automated tests (Mocha + Chai) — they must all pass |
| `npm run compile` | Compile the contract with solc 0.8.24 |
| `npm run coverage` | Test coverage report |
| `npm run lint:sol` | Solidity linter (Solhint) |
| `npm run format` | Format code (Prettier) |
| `npm run node` | Start a local Ethereum node (Hardhat, chainId `31337`, RPC `http://127.0.0.1:8545`) |
| `npm run deploy:local` | Deploy the contract to the local node |
| `npm run security:slither` | Static security analysis (requires `pip install slither-analyzer`) |

Run a single test with Mocha's grep, e.g. `npx hardhat test --grep "emitirCertificado"`.

Serve the frontend: `npx serve frontend` or `python3 -m http.server 8000 --directory frontend`.

Target Node.js LTS **20 or 22**.

## Architecture

Three layers (see the README's mermaid diagram and the planned `docs/02-arquitectura/`):

- **Off-chain:** the DApp frontend (`frontend/`, plain HTML + ethers.js v6) talks to the user's MetaMask wallet.
- **On-chain:** `contracts/RegistroCertificados.sol` (Solidity 0.8.24) holds state and emits audit events on Ethereum. The frontend reads/writes through an RPC node (Alchemy/Infura, or the local Hardhat node).
- **DevOps/Cloud platform:** GitHub Actions runs two pipelines — `.github/workflows/ci.yml` (CI: compile, test, lint) and `.github/workflows/devsecops.yml` (security: Slither, Solhint, npm audit). Hosting via Vercel/IPFS.

**Deployment flow:** `scripts/deploy.js` deploys the contract and writes `frontend/deployment.json` (contract address + ABI), which the frontend reads to connect. This file is the contract→frontend handoff — regenerate it after every redeploy.

### The `RegistroCertificados` contract

Role-based access control. An institution (the **owner**) authorizes **emisores** (issuers) who can register certificates. Anyone can verify a certificate publicly and for free. Certificates are never deleted — they are **revoked** (immutability and auditability).

| Function | Caller | Type |
|----------|--------|------|
| `emitirCertificado(nombre, curso)` | authorized issuer | write (gas) |
| `revocarCertificado(hash)` | authorized issuer | write (gas) |
| `verificarCertificado(hash)` | anyone | read (free) |
| `autorizarEmisor` / `revocarEmisor` | owner | write (gas) |

Apply the security patterns the docs emphasize: role-based access control, custom errors (not revert strings), and events for every state change (audit trail).
