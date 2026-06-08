# 🎓 Guía 04 — Laboratorio DevSecOps

> **Objetivo:** integrar seguridad en el pipeline ("shift-left security").
> **Tiempo:** 30–45 min.

---

## 1. La idea: seguridad desde el primer commit

**DevSecOps** = DevOps + seguridad automatizada desde el inicio, no como un parche al
final. En este repo, el pipeline [`.github/workflows/devsecops.yml`](../.github/workflows/devsecops.yml)
ejecuta tres controles en cada push:

| Control | Herramienta | Qué detecta |
|---------|-------------|-------------|
| Análisis estático del contrato | **Slither** | Reentrancy, overflow, malas prácticas en Solidity |
| Auditoría de dependencias | **npm audit** | CVEs conocidos en las librerías |
| Lint de seguridad | **Solhint** | Patrones inseguros y de estilo |

Además corre **una vez por semana** (cron) para detectar CVEs nuevos aunque no toques el código.

---

## 2. Slither en local

Requiere Python y Slither (ver [Guía 01](01-preparacion-del-entorno.md)):

```bash
pip install slither-analyzer
npm run security:slither
```

Slither clasifica los hallazgos por severidad (High / Medium / Low / Informational). Lee
cada uno: te enseña *por qué* algo es peligroso.

---

## 3. Solhint en local

```bash
npm run lint:sol
```

La configuración está en [`.solhint.json`](../.solhint.json). Nota la regla
`gas-custom-errors`: obliga a usar **errores personalizados** (`revert MiError()`) en lugar
de `require("texto")`, más baratos en gas y más claros. El contrato ya cumple esto.

---

## 4. Experimento: introduce una vulnerabilidad

1. Añade una función insegura al contrato, por ejemplo una que envíe ETH sin control:

   ```solidity
   function retirar() external {
       (bool ok, ) = msg.sender.call{value: address(this).balance}("");
       require(ok);
   }
   ```
2. Corre `npm run security:slither`. Slither señalará el riesgo (llamada externa de bajo
   nivel / posible reentrancy).
3. Súbelo: el job **slither** del pipeline DevSecOps fallará en GitHub Actions.
4. Elimina la función. El pipeline vuelve a verde.

---

## 5. Los patrones de seguridad del contrato

Revisa en `contracts/RegistroCertificados.sol` cómo ya se aplican buenas prácticas:

- **Control de acceso por roles:** modificadores `soloPropietario` y `soloEmisor`.
- **Errores personalizados:** `NoEsEmisorAutorizado()`, etc. (baratos y explícitos).
- **Eventos de auditoría:** cada cambio de estado emite un evento → rastro inmutable.
- **Inmutabilidad:** los certificados se **revocan**, nunca se borran.

---

## 6. Seguridad de secretos (clave para AWS)

El pipeline **nunca** debe contener claves privadas ni API keys. En este proyecto:

- `.env` y `terraform.tfvars` están en `.gitignore`.
- En AWS, los secretos viven en **SSM Parameter Store** cifrado (ver [Guía 05, Paso 6](05-despliegue-aws.md#paso-6--opcional-guarda-los-secretos-para-desplegar-el-contrato)).

Para profundizar, lee [`docs/04-devsecops/`](../docs/04-devsecops/).
