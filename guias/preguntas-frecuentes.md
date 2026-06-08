# ❓ Preguntas frecuentes

## General

**¿Necesito saber Solidity para hacer las prácticas?**
No para empezar. Las guías te llevan paso a paso. El contrato ya está escrito y comentado;
lo importante es entender el flujo DevOps/DevSecOps.

**¿Esto cuesta dinero?**
En local, no. En AWS, todo está pensado para el **free tier** y haces `terraform destroy`
al terminar. Sepolia usa ETH de *faucet* (gratis).

---

## Entorno local

**Hardhat me advierte que mi versión de Node no es compatible.**
Usa Node **LTS 20 o 22** (con `nvm install 20`). Con versiones más nuevas suele funcionar,
pero la advertencia es normal.

**`npm install` muestra vulnerabilidades.**
Son avisos de dependencias de desarrollo. Para el curso no bloquean nada. El job de
DevSecOps audita lo relevante con `npm audit --audit-level=high`.

**MetaMask dice "Nonce too high".**
Reinicia el nodo local y en MetaMask: Configuración → Avanzado → **Restablecer cuenta**.

**"No se encontró deployment.json".**
Ejecuta `npm run deploy:local` con el nodo (`npm run node`) abierto en otra terminal.

---

## DevOps / CI

**El workflow no aparece en GitHub Actions.**
Confirma que subiste la carpeta `.github/workflows/` y que haces push a `main` o `develop`.

**Pasa en local pero falla en CI (o al revés).**
Usa `npm ci` (no `npm install`) para reproducir el entorno exacto de la CI.

---

## AWS

**La etapa "Origen" del pipeline falla.**
No autorizaste la conexión de GitHub. Ve a Developer Tools → Connections y ponla en
**Available** (Guía 05, Paso 5).

**`terraform apply` da `AccessDenied`.**
Tu usuario IAM no tiene permisos suficientes. Usa un usuario con permisos de administrador
para el curso (no la cuenta raíz).

**¿Cómo evito que me cobren?**
`terraform destroy` al terminar cada práctica. Borra también los parámetros de SSM si los
creaste.

**Amplify no construye el frontend.**
Suele ser el token de GitHub: que tenga el scope `repo` y no esté caducado. Regéneralo y
vuelve a `terraform apply`.

---

¿Tu duda no está aquí? Revisa la guía correspondiente o pregunta en clase.
