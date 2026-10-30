# Presentación contextual del Caso 001 — 11R

2026-10-29. Reemplaza el recorrido oficial de cuatro pestañas, conservando demos y servicios.

## Componentes

- `data/cases/case_001/experience.json`: objetivos con condiciones existentes, rótulos, secuencias de consulta, resúmenes de presentación, ayudas y preguntas de razonamiento. No forma parte del JSON narrativo ni de su fingerprint y no contiene efectos nuevos.
- `scripts/ui/case_flow_director.gd`: proyección de estado, acciones, herramientas y lecciones. Sin comandos narrativos, inventario o archivos de guardado propios.
- `scenes/screens/case_experience.tscn` / `scripts/ui/case_experience.gd`: superficie oficial, lectura vigente, consultas, interpretación, inspección, registros, historial y ayuda. Envía intenciones explícitas a servicios existentes. Menú/back conservan el guardado; back desde consulta regresa antes de abandonar consola.
- `dispatch_console.gd`: conecta la nueva presentación con el mismo CallController y los managers de sus paneles; oculta navegación/cabecera antiguas para c001. Las demos conservan las cuatro secciones. No hay otro motor, SaveManager, autoload ni AudioStreamPlayer.

## Contratos

`NarrativeEngine.select_choice_sequence(ids, expected_revision)` admite entre una y cuatro opciones normales, revalida su elegibilidad en un candidato aislado y publica una vez. Un error o revisión obsoleta no deja visitas, efectos o diario parcial. El diario contiene los comandos normales, por lo que replay, idempotencia y snapshots previos siguen siendo válidos. `CallController.select_choices` coordina bloqueo y publicación. Las secuencias de experience.json están auditadas: solo agrupan consultas/preparación redundantes; no escogen tono, plan, calma o aceptación de riesgo.

`DeductionManager.get_reasoning(id)` proyecta fuentes descubiertas, pregunta y respuestas sin exponer el indicador de corrección. Si faltan fuentes/condiciones no ofrece respuestas utilizables. `reason(id, answer_id, revision)` valida revisión, fuentes y conclusión en el servicio; una respuesta incorrecta explica la carencia sin efectos. Una correcta llama a relate_hypothesis/confirm_deduction existentes con el fundamento declarado. El diario conserva Q01–Q04 originales. Confirmadas no se repiten. No se han añadido equivalencias de evidencia no definidas.

Audio contextual usa el AudioAnalysisManager del panel existente. Selección interna de G01.S02/Voces al pulsar Examinar; transcripción y comprobante consult por la API existente. Abrir la consulta no descubre. Otros segmentos siguen consultables; no se muestran filtros TEXT sin diferencia perceptible. No hay recursos sonoros oficiales nuevos, TTS o 09B.

DispatchManager conserva disponibilidad/revisión, confirmación y partes contextuales. El mapa es opcional. R1 única no requiere selección. Una reubicación requiere confirmación; abrir, cancelar o salir no despacha. Un plan preparado exige corregirlo por su opción real. Los partes disponibles no dependen del reloj ni de abrir pestañas.

## Progresión y ayuda

Atención y diálogo se introducen al conectar; ficha cuando Clara ya identifica hotel/habitación; archivo tras E02; primera interpretación al pasar a C; audio e inspección tras Q01, con tolerancia a contextos ya existentes en partidas anteriores. El analizador conserva su disponibilidad de datos, aunque su acceso principal se introduce después. La decisión crítica sigue la revelación aprobada. Q03/Q04 permanecen opcionales, con fuentes conocidas y condiciones normales.

Objetivo narrativo debajo del texto en la llamada. Cada consulta presenta solo su propósito y acción local, sin el objetivo de otra herramienta. Ayuda voluntaria: objetivo, orientación y acción concreta. Sin reloj de inactividad, penalización o elección de final. Tutoriales vistos por interacción pertinente, no por abrir pestañas. Se consultan y persisten mediante SaveManager.

## Guardado

Se conservan case_001.json, content_version, fingerprint, esquema 4 y los 17 campos del snapshot. SaveManager admite los ocho campos anteriores o esos campos más `presentation`, exclusivamente para c001:

```json
{"presentation":{"version":1,"tutorials_seen":["answer","record","deduction"]}}
```

Versión 1 de esta extensión; hasta ocho IDs conocidos, únicos, tipos/campos exactos. Ausente equivale a lista vacía. Se normaliza el entero al leer JSON. Dirty incluye presentación además del snapshot. Se escribe/verifica/respalda en la misma ranura y bajo el bloqueo existente; no hay sidecar de partida. Una avería conserva progreso en memoria y permite reintentar.

La compatibilidad es del nuevo lector con partidas anteriores; un ejecutable antiguo puede rechazar el noveno campo sin borrarlo. No hay migración narrativa ni reemplazo automático de partidas incompatibles. Las pruebas solo escriben en user://save_tests.

## Verificación

`test_case_redesign.gd`: secuencias atómicas/rollback, consultas puras, razonamiento, ausencia de premios tutoriales, guardado viejo/nuevo y rechazo conservador. `test_case_experience.gd`: ratón simulado, tres cierres, consulta directa, ayuda, inspección/cancelación, continuación fría, plan preparado, archivo e I/O fallida. El diálogo de sustitución nativo se reconoce mediante señal en el auxiliar. `test_case_integrations.gd` conserva el comando anterior como entrada a esta prueba nueva.

`test_case_flow.gd`, `test_case_validation.gd` y `test_case_guidance.gd` conservan sus pruebas de lógica anteriores. La proyección CaseGuidance antigua permanece para contratos/pruebas previos y paneles conservados; el recorrido oficial visible usa CaseFlowDirector. Resultados finales, capturas y límites en PROGRESS e informe 11R. No se acredita Android físico ni diversión por estas pruebas.
