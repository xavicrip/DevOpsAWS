# 🏗️ Arquitectura y modelado

Esta sección modela la solución con varias vistas complementarias. Cada diagrama responde a
una pregunta distinta.

| Vista | Pregunta que responde | Archivo |
|-------|----------------------|---------|
| **C4** | ¿Qué piezas hay y cómo se relacionan? | [`c4.md`](c4.md) |
| **Modelo de datos** | ¿Cómo se guardan los certificados? | [`modelo-datos.md`](modelo-datos.md) |
| **Secuencia** | ¿Qué ocurre paso a paso al emitir/verificar? | [`secuencia.md`](secuencia.md) |
| **Despliegue** | ¿Dónde corre cada cosa en producción? | [`despliegue.md`](despliegue.md) |

El modelado **precede** al código: diseñar antes de construir reduce errores y guía las
decisiones (incluidas las de DevOps y seguridad).
