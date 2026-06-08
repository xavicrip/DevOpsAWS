# 🎓 Guía 01 — Preparación del entorno

> **Objetivo:** dejar tu computadora lista para ejecutar el proyecto.
> **Tiempo:** 20–30 min.

Solo necesitas tres cosas: **Node.js**, **Git** y **MetaMask**. El resto
(Hardhat, ethers, Solhint...) se instala solo con `npm install`.

---

## 1. Node.js (LTS 20 o 22)

Hardhat necesita Node. Usa una versión **LTS 20 o 22** (con versiones más nuevas funciona,
pero Hardhat muestra una advertencia).

### Opción recomendada: nvm (gestor de versiones)

**macOS / Linux:**
```bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
# Reinicia la terminal, luego:
nvm install 20
nvm use 20
```

**Windows:** instala [nvm-windows](https://github.com/coreybutler/nvm-windows/releases),
luego en PowerShell:
```powershell
nvm install 20
nvm use 20
```

### Opción simple: instalador oficial

Descarga el instalador LTS de [nodejs.org](https://nodejs.org) y sigue el asistente.

Verifica:
```bash
node -v   # v20.x o v22.x
npm -v
```

---

## 2. Git

- **macOS:** ya viene; si no, `xcode-select --install`.
- **Windows:** [git-scm.com](https://git-scm.com) (instalador).
- **Linux:** `sudo apt install git` (Debian/Ubuntu) o el equivalente de tu distro.

```bash
git --version
```

---

## 3. MetaMask (billetera del navegador)

1. Instala la extensión desde [metamask.io](https://metamask.io) (Chrome, Firefox, Edge o Brave).
2. Crea una billetera nueva y **guarda tu frase secreta** en un lugar seguro.

> ⚠️ Para este curso usarás **solo cuentas de prueba**. Nunca pongas fondos reales ni uses
> tu billetera personal con el nodo local.

---

## 4. (Opcional) Herramientas del laboratorio DevSecOps

Solo si vas a hacer la [Guía 04](04-laboratorio-devsecops.md) en local:

```bash
# Python 3.8+ y Slither (análisis estático de seguridad)
pip install slither-analyzer
```

---

## ✅ Verificación final

```bash
node -v && npm -v && git --version
```

Si los tres responden, pasa a la [Guía 02 — Ejecutar el proyecto](02-ejecutar-el-proyecto.md).
