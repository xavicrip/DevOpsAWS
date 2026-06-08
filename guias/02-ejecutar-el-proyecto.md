# 🎓 Guía 02 — Ejecutar el proyecto en local

> **Objetivo:** correr la DApp completa en tu máquina y emitir tu primer certificado.
> **Tiempo:** 30–40 min.

---

## Paso 1 — Instalar dependencias

Desde la raíz del proyecto:

```bash
npm install
```

La primera vez, Hardhat descargará el compilador `solc 0.8.24` automáticamente.

---

## Paso 2 — Compilar y probar

```bash
npm run compile   # compila el contrato
npm test          # deben pasar las 12 pruebas
```

Si ves `12 passing`, tu entorno funciona. 🎉

---

## Paso 3 — Levantar el nodo blockchain local

En una **terminal nueva** (déjala abierta):

```bash
npm run node
```

Hardhat arranca una blockchain local en `http://127.0.0.1:8545` (chainId **31337**) e
imprime **20 cuentas de prueba** con su clave privada y 10000 ETH ficticios cada una.
Copia la **clave privada** de la *Account #0*; la importarás en MetaMask.

---

## Paso 4 — Desplegar el contrato

En **otra terminal** (la del nodo sigue abierta):

```bash
npm run deploy:local
```

Esto despliega el contrato y genera `frontend/deployment.json` (dirección + ABI). El
frontend lee ese archivo para conectarse.

---

## Paso 5 — Servir el frontend

```bash
npx serve frontend
# o bien:
python3 -m http.server 8000 --directory frontend
```

Abre la URL que te indique (p. ej. `http://localhost:3000`).

---

## Paso 6 — Conectar MetaMask a la red local

1. Abre MetaMask → menú de redes → **Agregar red manualmente**:
   - **Nombre:** Hardhat Local
   - **URL RPC:** `http://127.0.0.1:8545`
   - **Chain ID:** `31337`
   - **Moneda:** ETH
2. Importa la cuenta de prueba: MetaMask → **Importar cuenta** → pega la clave privada de
   la *Account #0* del Paso 3.

---

## Paso 7 — Usar la DApp

1. En la web, pulsa **🦊 Conectar MetaMask**.
2. **Emitir:** escribe un nombre y un curso → **Emitir** → confirma en MetaMask. Copia el
   **hash** del certificado que aparece.
3. **Verificar:** pega el hash → **Verificar** → debe salir **VÁLIDO** con los datos.
4. **Revocar:** pega el hash → **Revocar** → al verificar de nuevo, saldrá **REVOCADO**
   (pero sigue existiendo: eso es la inmutabilidad).

---

## 🆘 Problemas frecuentes

| Síntoma | Solución |
|---------|----------|
| "No se encontró deployment.json" | Ejecuta `npm run deploy:local` (Paso 4). |
| MetaMask: "Nonce too high" | MetaMask → Configuración → Avanzado → **Restablecer cuenta**. |
| No conecta al nodo | ¿Sigue abierta la terminal de `npm run node`? ¿Chain ID 31337? |
| "No estás autorizado como emisor" | Importaste otra cuenta. Usa la *Account #0* (el propietario). |

Cuando todo funcione, sigue con la [Guía 03 — Laboratorio DevOps](03-laboratorio-devops.md).
