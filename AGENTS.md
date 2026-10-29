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
- `scripts/systems/`: SaveManager y adaptador opcional de ciclo de vida; `tests/save/`: pruebas aisladas de persistencia, sin tocar partidas reales.
- `scripts/systems/call_controller.gd`, `scripts/ui/calls_panel.gd` y `scenes/components/calls/`: comunicaciones y presentación; `tests/calls/`: pruebas del controlador y GUI. La demo de desarrollo usa data/cases/ui_call_demo.json y user://call_demo, nunca user://saves.
- `scripts/systems/evidence_manager.gd`, `deduction_manager.gd`, `scripts/ui/evidence_panel.gd` y `scenes/components/evidence/`: investigación genérica de 08. Demo data/cases/investigation_demo.json, guardado user://investigation_demo; tests/investigation usa rutas únicas user://save_tests.
- `scripts/systems/audio_catalog_validator.gd`, `audio_analysis_manager.gd`, `audio_playback_controller.gd`, `scripts/ui/audio_panel.gd` y `audio_waveform.gd`: analizador de grabaciones de 09A. Caso técnico data/audio/audio_analysis_demo.json, WAV propios assets/audio/demo y guardado user://audio_analysis_demo. tests/audio usa rutas únicas user://save_tests; su generador Python es auxiliar opcional, no dependencia del juego.
- `scripts/systems/map_manager.gd`, `dispatch_manager.gd`, `dispatch_rules.gd`, `dispatch_catalog_validator.gd`, `scripts/ui/map_panel.gd` y `map_canvas.gd`: mapa/despacho técnico de 10. data/maps/dispatch_demo.json y user://dispatch_demo; tests/dispatch usa user://save_tests. Estado operativo en variables enum centrales, no colecciones duplicadas; solo transacciones operativas modifican sus bindings.
- `docs/GDD.md`: diseño y alcance; `docs/STORY_BIBLE.md`: hechos narrativos y preguntas abiertas.
- `docs/ROADMAP.md`: fases, dependencias y aceptación; `docs/PROGRESS.md`: avance y validaciones; `docs/DECISIONS.md`: decisiones y propuestas.
- `docs/UI_NAVIGATION.md`: flujo de interfaz, archivos, comandos y límites actuales. TECHNICAL_SETUP conserva el registro de la base de 03.
- `docs/technical/NARRATIVE_ENGINE.md`: esquemas 1/2/3/4, API, transacciones, eventos y límites del motor. No cambiar su formato o semántica sin documentarlo y validar las pruebas pertinentes.
- `docs/technical/SAVE_SYSTEM.md`: formatos 1/2/3/4 para sus esquemas; 3 añade analysis y 4 dispatch a las entradas correspondientes del diario, sin duplicar colecciones. Sin migración automática. Restauración, rutas user://, respaldos, autoguardado y garantías reales. Las pruebas escriben únicamente bajo user://save_tests/.
- `docs/technical/CALL_SYSTEM.md`: acceso a la demo, ciclo visual, historial derivado, señales, integración y pruebas de llamadas.
- `docs/technical/INVESTIGATION_SYSTEM.md`: catálogo, proyecciones sin spoilers, reglas exactas, acciones externas atómicas, registro persistente, UI, pruebas y autoría futura. Las conclusiones derivan de executed_actions; no duplicar estado ni ejecutar efectos desde UI.
- `docs/technical/AUDIO_ANALYZER.md`: variantes preparadas, tolerancia temporal, segmentos/examen real, texto equivalente, API y persistencia mínima. El analizador usa un solo AudioStreamPlayer; pausar al ocultar/perder foco, sin reanudación automática. No conceder pistas por abrir, seleccionar filtro o buscar al final.
- `docs/technical/MAP_DISPATCH_SYSTEM.md`: catálogo, disponibilidad, transiciones, confirmación, partes autorizados, evidencia, estado/diario y pruebas. Llegada/resultado/liberación solo por eventos discretos; navegar, cargar o cerrar no libera unidades ni consume tiempo narrativo.

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
- PROMPT 10 aprueba 00–08 y 09A y autoriza exclusivamente mapa/despacho genéricos, incidentes/unidades/partes narrativos, demo técnica, persistencia y pruebas/documentación. 09B está pospuesto intencionalmente y no bloquea 11. Continuar deshabilitado, partidas oficiales aisladas y Caso 001 sin integrar. Al cerrar 10 detenerse; no iniciar 11 sin autorización explícita. No hacer commits ni pushes en esta fase.
- No crear voces de llamadas, gestor de locuciones, TTS, subtítulos sincronizados, proveedores/APIs de voz, contenido oficial del Caso 001, bomberos, GPS, tráfico/tiempo real complejo, IA de patrullas, vehículos controlables o resultados definitivos. No instalar herramientas, descargar recursos externos, crear APK o configurar publicación sin autorización.
