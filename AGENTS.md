# ÚLTIMA SEÑAL — Instrucciones persistentes

## Objetivo y alcance

Videojuego de investigación y suspenso psicológico para Android. El primer objetivo jugable es exclusivamente el Caso 001, «La habitación 304». Consultar el alcance en `docs/GDD.md` y la continuidad en `docs/STORY_BIBLE.md`.

Trabajar mediante prompts numerados. Cada prompt autoriza únicamente su alcance explícito. Al terminar, detenerse; no iniciar fases posteriores por iniciativa propia. El roadmap es planificación, no autorización.

## Antes de modificar

- Leer este archivo, las instrucciones locales aplicables y la documentación pertinente.
- Consultar `docs/PROGRESS.md`, `docs/ROADMAP.md` y las decisiones relevantes en `docs/DECISIONS.md`.
- Revisar el contenido de archivos existentes antes de sobrescribirlos e inspeccionar solo lo relevante.
- Entender el código existente, delimitar la tarea y comunicar brevemente el enfoque antes de implementar.
- Informar contradicciones entre documentos y requisitos nuevos; no resolver cambios de producto unilateralmente. El usuario tiene la decisión final.

## Tecnologías y arquitectura

- Godot 4.7.2 estable y GDScript, con renderizador Compatibility. Entorno y pruebas de arranque en `docs/TECHNICAL_SETUP.md`.
- Juego 2D, vertical, en español, de un jugador y offline.
- Preferir escenas reutilizables, interfaces desacopladas de la lógica narrativa, casos en JSON, estado centralizado y guardado local versionado.
- Validar referencias y condiciones narrativas; diseñar sistemas reutilizables, simples y adecuados para Android.
- No incorporar dependencias externas sin justificar su necesidad y respetar la autorización de la tarea.

## Convenciones

- GDScript legible y con tipado cuando resulte útil; seguir las convenciones del motor y los patrones existentes.
- Usar nombres descriptivos: `snake_case` para archivos, funciones y variables de GDScript; `PascalCase` para clases y tipos; `UPPER_SNAKE_CASE` para constantes.
- Mantener identificadores internos consistentes y textos del jugador en español. Definir esquemas e identificadores de contenido al autorizar su implementación.
- Evitar complejidad anticipada y cambios ajenos a la tarea; documentar decisiones que afecten a fases posteriores.

## Organización

- Raíz: `AGENTS.md`, `project.godot` y `.gitignore`; `docs/`: diseño, narrativa, planificación, progreso, decisiones y entorno técnico.
- `scenes/core/main.tscn`: entrada y controlador de vistas; `scenes/screens/` y `scenes/components/`: interfaz; `scripts/ui/`: interacción y navegación; `assets/ui/`: Theme e iconos propios; `tests/`: auxiliares de validación. Crear otras carpetas cuando la fase autorizada necesite archivos reales.
- `scripts/narrative/`: motor independiente de la interfaz; `data/cases/test_narrative.json`: demostración técnica no canónica; `tests/narrative/`: pruebas y fixtures, algunas inválidas deliberadamente.
- `docs/GDD.md`: diseño y alcance; `docs/STORY_BIBLE.md`: hechos narrativos y preguntas abiertas.
- `docs/ROADMAP.md`: fases, dependencias y aceptación; `docs/PROGRESS.md`: avance y validaciones; `docs/DECISIONS.md`: decisiones y propuestas.
- `docs/UI_NAVIGATION.md`: flujo de interfaz, archivos, comandos y límites actuales. TECHNICAL_SETUP conserva el registro de la base de 03.
- `docs/technical/NARRATIVE_ENGINE.md`: esquema 1, API, transacciones, eventos y límites del motor. No cambiar su formato o semántica sin documentarlo y validar las pruebas pertinentes.

## Verificación y cierre

- Implementar solo lo solicitado y verificar por los medios disponibles, empezando por comprobaciones relevantes al cambio.
- En cambios documentales, comprobar consistencia, enlaces locales, alcance y organización. En código, comprobar funcionamiento y validación de datos según los sistemas afectados.
- Mantener pruebas reproducibles cuando sea posible; registrar comandos o procedimientos, resultados y limitaciones reales en `docs/PROGRESS.md`.
- No afirmar pruebas de Android o de dispositivo real sin evidencia. No marcar etapas como completadas sin sus entregables y comprobaciones.
- Actualizar progreso, decisiones y documentos afectados cuando corresponda dentro de la fase autorizada.
- Respuesta final obligatoria: (1) archivos creados o modificados, (2) resumen de cambios, (3) decisiones registradas, (4) supuestos y dudas, (5) validaciones y limitaciones, (6) alcance realizado y confirmación de que se detiene la fase.

## Restricciones

- No cambiar historia, dirección artística, mecánicas ni requisitos principales sin autorización explícita.
- El MVP excluye campaña completa, multijugador, backend, IA generativa en ejecución, publicidad, compras integradas, doblaje completo y 3D.
- El audio usa grabaciones y filtros simulados; no implementar procesamiento avanzado de señales ni reconocimiento de voz.
- No realizar commits, pushes, despliegues, publicaciones, cambios remotos, operaciones con credenciales ni otros cambios externos sin autorización explícita.
- PROMPT 03 aprueba las etapas 00–02 y autoriza exclusivamente la base técnica ya creada. Las menciones de revisión pendiente en las entregas originales del Caso 001 describen su estado al entregarse en 02; consultar su aprobación posterior en D-017 y PROGRESS.
- PROMPT 05 aprueba 00–04 y autoriza exclusivamente motor narrativo, sesión temporal, caso técnico y pruebas aisladas. La consola sigue sin conexión al motor y el Caso 001 no está integrado. Al cerrar 05, detenerse y esperar autorización para 06.
- No crear todavía guardado en disco, llamadas jugables, interfaz de conversaciones, reproducción de audio, mapas funcionales, despacho, expedientes jugables ni deducciones. No modificar la interfaz, instalar herramientas, crear APK o configurar publicación sin autorización.
