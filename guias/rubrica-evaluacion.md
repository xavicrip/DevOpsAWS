# 📋 Rúbrica de evaluación

Reto integrador de la Unidad 1: tener la DApp **funcionando en local**, con **CI/CD**, con
**controles DevSecOps** y **desplegada en AWS** mediante Terraform.

**Total: 100 puntos.**

---

## 1. Entorno y ejecución local (20 pts)

| Criterio | Pts |
|----------|-----|
| `npm install` y `npm test` con las 12 pruebas en verde | 8 |
| DApp en local: emitir, verificar y revocar un certificado con MetaMask | 8 |
| Captura/evidencia del nodo local + despliegue (`deployment.json`) | 4 |

## 2. DevOps — CI/CD (25 pts)

| Criterio | Pts |
|----------|-----|
| Repo en GitHub con el workflow CI ejecutándose en verde | 10 |
| Evidencia del experimento "romper una prueba" y arreglarla | 8 |
| Explicación escrita del flujo del pipeline (con tus palabras) | 7 |

## 3. DevSecOps — Seguridad (20 pts)

| Criterio | Pts |
|----------|-----|
| Pipeline `devsecops.yml` ejecutándose (Slither + npm audit + Solhint) | 8 |
| Reporte de Slither analizado (hallazgos comentados) | 7 |
| Secretos correctamente fuera del código (`.env`/tfvars en `.gitignore`, SSM) | 5 |

## 4. Nube — AWS con Terraform (25 pts)

| Criterio | Pts |
|----------|-----|
| Infraestructura creada con `terraform apply` (no a mano) | 8 |
| DApp accesible por la URL pública de Amplify (HTTPS) | 7 |
| CodePipeline + CodeBuild en verde (12 pruebas en la nube) | 6 |
| Evidencia de `terraform destroy` al final (gestión de costos) | 4 |

## 5. Documentación y arquitectura (10 pts)

| Criterio | Pts |
|----------|-----|
| Diagrama propio de la arquitectura desplegada | 5 |
| Reflexión: qué aporta DevOps/DevSecOps a una solución blockchain | 5 |

---

## Niveles de logro

| Rango | Nivel |
|-------|-------|
| 90–100 | Excelente — solución completa, segura y bien documentada |
| 75–89 | Bueno — funciona end-to-end con detalles menores |
| 60–74 | Suficiente — local + CI/CD, nube parcial |
| < 60 | Insuficiente — repetir prácticas pendientes |

> 💡 **Entrega:** un documento (PDF/Markdown) con capturas y enlaces (repo, URL de Amplify),
> más el enlace al repositorio. La evidencia de `terraform destroy` es obligatoria.
