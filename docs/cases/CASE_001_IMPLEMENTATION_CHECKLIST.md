# Caso 001 — Auditoría e inventario de integración

PROMPT 11 · 2026-10-29. Fuentes: [diseño aprobado](CASE_001_DESIGN.md), [especificación](CASE_001_TECHNICAL_SPEC.md), [pruebas](CASE_001_TEST_PLAN.md), STORY_BIBLE y aprobación D-017.

## Auditoría inicial

El diseño contiene sinopsis, fechas 14/11/1981 y 14/11/1998 a las 02:17, cinco roles, etapas A–F, 38 nodos y 57 elecciones estables, diez evidencias, cuatro deducciones, dos grabaciones, dos accesos del mismo hotel, una unidad R1 y reglas exhaustivas A/C/B. No se detectó contradicción narrativa que requiera cambiar identidad, cronología, misterio o condiciones de cierre. Las etiquetas de revisión de 02 son históricas y están aprobadas por D-017.

| Elemento aprobado | Implementación realizada | Estado de cierre |
| --- | --- | --- |
| N01–N38 y 57 opciones | JSON oficial separado; variantes/filas declarativas | PASS; todos los diálogos/opciones ejecutados entre rutas |
| Emociones 0–2, etapas, plan, comunicación | Variables centrales; cooperación derivada | PASS; resultados distintos por historial |
| E01–E10 y recuperación alternativa | Entradas/transcripciones/partes; EvidenceManager | PASS; diez obtenidas y sin duplicados |
| Q01–Q04; conjuntos exactos de 2/3 fuentes | DeductionManager y selector sin revelar fuentes faltantes | PASS; errores corregibles y persistencia |
| G01/G02, segmentos y variantes | AudioAnalysisManager; texto equivalente real | Lógica textual PASS; dos grabaciones/validación auditiva pendientes |
| L01/L02, Frente Costero | MapManager; contorno esquemático del mismo edificio | PASS; sin otras ubicaciones |
| R1, M01–M05, U01/U02 | RESCUE, reubicación y partes atómicos | PASS; exclusión, duplicados y cierre |
| K01 y K02 | Condiciones/efectos/transiciones y claves únicas | PASS; sin reloj ni avance por consulta |
| Finales A/C/B; N27–N37 | Resolución declarativa, cierre básico y consulta | PASS; rutas y 108 entradas sintéticas |
| Nueva/Continuar/repetición confirmada | Menú y ranura oficial separada de demos | PASS; entrante/respondida/cerrada, cancelación y sustitución |
| Guardar/cargar sin duplicación | Reconstrucción aislada y checkpoints por paso | PASS; estado/historial exactos, sin señales nuevas |
| TR01–TR08 y cobertura | Diez rutas, incluidas pistas opcionales en A/B/C | PASS; matriz en el informe/PROGRESS |
| Interfaz vertical | Cuatro tamaños, 52 capturas reales de Godot | PASS escritorio; Android físico pendiente |

## Adaptaciones conservadoras necesarias

El contrato de 02 era propuesto antes de implementar los servicios. Se reutiliza esquema/formato 4 y sus 17 campos, sin crear el formato 1 propuesto entonces. Las deducciones derivan del diario. Los estados semánticos R1 se proyectan desde asignación/estado operativo; no se mantiene un segundo inventario. Se amplía el despacho con RESCUE y reubicación declarada, sin bomberos actuales ni simulación. Los partes pueden llevar a nodos aprobados en la misma transacción.

La adquisición inmediata por transcripción de 02 requiere una modalidad declarada de consulta en AudioAnalysisManager, distinta del examen temporal conservado para la demo 09A. Las variantes sin grabación usarán ruta vacía y disponibilidad falsa explícitas; no se producirán voces o sustitutos sintéticos de habla. No se podrá declarar validación auditiva completa. Android y duración con lectores humanos requieren comprobación posterior.

El alcance nuevo autoriza contenido oficial y menú; sustituye esas prohibiciones temporales de 10. No autoriza 09B, 12, otros casos, commits, pushes, instalaciones o APK.

## Cierre y límites

Implementación funcional completada, **no experiencia totalmente validada**. Tres suites nuevas y dieciséis anteriores aprobadas; ver [informe](CASE_001_IMPLEMENTATION_REPORT.md), [progreso](../PROGRESS.md) y [matriz ejecutada](../validation/prompt_11/narrative_coverage.json). Pendientes: producción/inteligibilidad de grabaciones, Android real, accesibilidad/rendimiento móvil y duración con lectores humanos. No hay decisiones narrativas esenciales sin aprobar; los recursos pendientes no se presentan como reproducibles. Detenido antes de 12; sin commits/pushes.
