# ÚLTIMA SEÑAL — Registro de progreso

## Estado actual

Actualizado: 2026-10-28, fecha local del usuario. **Etapa 08 completada: Expedientes muestra evidencias, detalles y deducciones reales de una demo de investigación compartida con Llamadas y guardado aislado, verificada en Godot 4.7.2 estable sobre Windows.** El usuario aprobó 00–07 al enviar PROMPT 08. Menú/navegación conservados, Continuar deshabilitado y Caso 001 sin integrar. Trabajo detenido; PROMPT 09 requiere autorización explícita. Sin commits ni pushes en 08.

Autorización posterior al cierre de 08 — 2026-10-28: el usuario solicita «Directo a github», autorizando commit de esta entrega y push directo a main de ArielPerez2001/Last-Signal. Esta autorización de publicación sustituye la restricción anterior solo para esta entrega; no inicia PROMPT 09 ni amplía funcionalidades.

## Etapas completadas

- **00 — Contexto maestro:** recibido y comprendido; objetivos, sistemas y límites establecidos.
- **01 — Documentación:** raíz inspeccionada, seis documentos creados y comprobaciones documentales realizadas.
- **02 — Diseño completo del Caso 001:** entregables documentales y trazas realizados en 02; aprobación editorial expresa al iniciar PROMPT 03, registrada en D-017.
- **03 — Proyecto Godot:** configuración, escena principal, Theme, importación, inicio directo y validación de tres resoluciones en headless y con renderizado real.
- **04 — Navegación e interfaz base:** menú, consola, cuatro paneles reutilizables, pantallas informativas y regreso; configuración conservada, cuatro resoluciones verificadas y 28 capturas inspeccionadas.
- **05 — Motor narrativo:** carga/validación JSON, estado temporal, condiciones, efectos, transacciones, eventos, transiciones, finales y reinicio. Caso técnico de seis nodos y dos desenlaces, sin conexión a la consola.
- **06 — Estado y guardado:** JSON versionado en user://, validación completa, respaldo, recuperación transaccional, importación sin duplicar consecuencias, autoguardado y adaptador opcional de ciclo de vida. Pruebas aisladas con procesos separados, sin activar funciones del menú.
- **07 — Llamadas:** controlador de cinco estados, conversación y opciones reales desde JSON/motor, transcripción derivada, demo de desarrollo con dos desenlaces, recuperación y autoguardado aislados. Interacción GUI y 40 capturas reales en cuatro tamaños.
- **08 — Evidencias, expedientes y deducciones:** catálogo esquema 2, cinco categorías, fichas descubiertas, filtro/detalle/procedencia, selección de dos y conclusiones por reglas declarativas. Confirmación atómica e idempotente, diálogo actualizado sin reentrada y guardado 2 con lectores legacy 1 conservados. Demo separada de cinco pistas/dos conclusiones; 24 grupos verificados y 56 capturas reales en cuatro tamaños.

Las etapas 09–23 y las subfases 19.1–19.4 permanecen pendientes. El estado detallado y la aceptación de cada etapa están en [ROADMAP.md](ROADMAP.md). Los estados de revisión pendiente en las entregas originales de 02 describen su situación al entregarse, anterior a la aprobación de PROMPT 03. Los registros de 01–07 conservan su alcance histórico al entregarse; los cambios posteriores se detallan por fase.

## Cambios de fase 01 — 2026-10-27

- Identificada la carpeta de trabajo `D:\Ultima Señal`, proporcionada como espacio de trabajo activo. Estaba vacía, incluidos los archivos ocultos; no había documentos ni convenciones que conservar.
- No existía `AGENTS.md` en la raíz de trabajo ni en `D:\`. No se detectó repositorio Git en la carpeta ni en sus directorios ascendentes.
- Creado `AGENTS.md` con instrucciones persistentes y cinco documentos en `docs/` para diseño, narrativa, roadmap, progreso y decisiones.
- Separados requisitos aprobados, inferencias provisionales y propuestas pendientes. Conservado el MVP de un solo caso y la campaña como visión posterior.
- Registrada la selección pendiente de versión estable de Godot y las incógnitas narrativas sin completar el diseño del Caso 001.

## Validaciones de fase 01

Esta fase solo requiere validación documental; no hay ejecutable al que aplicar pruebas de juego.

| Comprobación | Procedimiento | Resultado |
| --- | --- | --- |
| Ubicación y contenido inicial | Inspección de la carpeta activa con `Get-Item` y `Get-ChildItem -Force` | Carpeta identificada y vacía |
| Instrucciones existentes | Comprobación de `AGENTS.md` en la raíz y su directorio ascendente | No había archivos aplicables en esas ubicaciones |
| Git | `git rev-parse --show-toplevel` y `git status --short` desde la carpeta | Ambos indican que no es un repositorio Git; no hay diff ni estado de cambios de Git disponibles |
| Organización final | Inventario recursivo de archivos y comparación con los seis entregables | Solo `AGENTS.md` y los cinco Markdown de `docs/` |
| Referencias locales | Comprobación de destinos Markdown y rutas documentales | Referencias a documentos existentes |
| Roadmap | Comprobación de etapas 00–23, subfases 19.1–19.4 y sus cinco campos | Etapas completas en su estructura; solo 00 y 01 marcadas como completadas |
| Consistencia editorial | Revisión cruzada de alcance, narrativa, estados y decisiones con PROMPT 00 y 01 | Un caso y tres resultados en el MVP; cinco capítulos y quince casos como visión; incógnitas identificadas |
| Restricciones de fase | Inventario de archivos y revisión de acciones realizadas | Sin scripts, escenas, `project.godot`, instalaciones, inicialización de Git, commits ni cambios externos |

No se ejecutaron pruebas de Godot, exportación Android, APK ni dispositivo real; no forman parte de esta fase.

## Cambios de fase 02 — 2026-10-27

- Leídos AGENTS y los cinco documentos de referencia; sin instrucciones anidadas en `docs/` al comenzar ni archivos existentes en `docs/cases/` que sobrescribir.
- Creados [CASE_001_DESIGN.md](cases/CASE_001_DESIGN.md), [CASE_001_TECHNICAL_SPEC.md](cases/CASE_001_TECHNICAL_SPEC.md) y [CASE_001_TEST_PLAN.md](cases/CASE_001_TEST_PLAN.md).
- Diseñados seis momentos A–F, 38 nodos, 57 elecciones de diálogo, diez evidencias, cuatro deducciones, dos grabaciones predefinidas y un recurso R1 con dos destinos. Las acciones de herramientas se cuentan aparte de las elecciones.
- Definidos tres resultados deterministas, recuperación de evidencias, alternativas textuales, condiciones de cooperación y persistencia propuesta. La deducción de amenaza precisa la instrucción de salida, en lugar de funcionar solo como una marca oculta.
- Registrados D-011–D-016: requisitos del nuevo prompt, nombres y fechas propuestos, peligro y resultados, pista N-4/ECO, contratos técnicos y distinción entre entrega documental y revisión editorial.
- Actualizados AGENTS, GDD, STORY_BIBLE y ROADMAP para sustituir referencias de estado que todavía describían la fase 02 como no autorizada o sin diseño. No se alteró el MVP ni se aprobó una explicación global del fenómeno.

## Validaciones de fase 02

| Comprobación | Método reproducible | Resultado documental |
| --- | --- | --- |
| Catálogo de guion | Leer cabeceras `### Nxx`, filas de opción `Oxx` y columna de destino mediante expresiones regulares sobre el Markdown | 38 nodos únicos, 57 elecciones, destinos existentes o END y ninguna opción sin destino |
| Acceso estructural | Recorrido del grafo de destinos, añadiendo los dos enlaces explícitos N16 → N19/N20 por partes | Todos los nodos y END alcanzables en el grafo; condiciones revisadas por separado en trazas TR01–TR08 |
| Catálogos | Comparar los ID de filas E01–E10 y Q01–Q04, referencias y fuentes | Diez evidencias y cuatro deducciones con métodos definidos |
| Rutas y recuperación | Trazas manuales TR01–TR08 del plan de pruebas, aplicando cambios de confianza/estrés y condiciones | A/B/C alcanzables; error de deducción sin castigo; frente corregible a patio; audio evitable con texto o testimonio |
| Resolutor | Revisión algebraica del contrato y condiciones de entrada | 108 combinaciones formales, 18 inválidas por servicio sin patio, 90 válidas: 4 A, 4 C y 82 B; no se ejecutó un motor |
| Cronología y continuidad | Revisión cruzada de fuentes y fechas con GDD/STORY_BIBLE | Diecisiete años exactos propuestos; anexo anterior al fuego; incendio no identificado con incidente global; destino histórico sin certificar |
| Restricción y organización | Inventario recursivo de archivos con `Get-ChildItem -Recurse -Force -File` y comprobación de enlaces Markdown | Nueve archivos, todos Markdown; 21 enlaces locales válidos; tres nuevos en `docs/cases/`, seis documentos de referencia actualizados |
| Separación de pruebas | Revisión de estados del plan de pruebas y roadmap | Persistencia real, reproducción, interfaz, mediciones y Android siguen pendientes; fase 03 sin iniciar |

Las comprobaciones automatizadas son de lectura y estructura documental, ejecutadas en PowerShell sin crear scripts de juego, simuladores ni datos funcionales. El grafo por sí solo no demuestra condiciones; las trazas manuales son la evidencia complementaria. No se instalaron dependencias ni se generaron imágenes, sonidos, escenas o proyecto del motor.

## Cambios de fase 03 — 2026-10-27

- Consultados los nueve documentos obligatorios e identificada la misma raíz de Última Señal. Sin instrucciones anidadas adicionales en las ubicaciones de trabajo.
- Detectada instalación existente de Godot 4.7.2 estable fuera de PATH mediante su proceso en ejecución; verificada salida exacta `4.7.2.stable.official.ed1daf0bf` y ejecutable de consola operativo. Sin instalación ni actualización.
- La revisión pendiente de 02 y prohibición temporal de iniciar 03 se resuelven por la aprobación y autorización expresas del nuevo prompt. Se actualizan estados y referencias, sin reescribir el diseño de casos ni el reporte Word ya entregado.
- Creado `project.godot` con base 720 × 1280, ventana inicial 360 × 640, Portrait, `canvas_items`, `expand`, Compatibility para escritorio/móvil y respaldo de idioma español.
- Creada `scenes/core/main.tscn`: pantalla Control con contenedores, identidad del juego, Puerto Umbral 1998, estado de prototipo técnico y confirmación de inicialización. Sin script de escena ni botones.
- Creado `assets/ui/base_theme.tres` para centralizar colores, estilos de panel, texto y separaciones. No se descargaron fuentes ni otros recursos.
- Creados `.gitignore`, `docs/.gdignore`, el auxiliar de arranque `tests/bootstrap_smoke.gd` y su UID generado por Godot. No se creó un repositorio Git ni se hicieron commits o cambios externos.
- Añadido [TECHNICAL_SETUP.md](TECHNICAL_SETUP.md), con configuración, estructura efectiva, comandos exactos y resultados. Capturas reales conservadas en `docs/validation/prompt_03/`.
- Actualizados AGENTS, GDD, STORY_BIBLE, ROADMAP, DECISIONS y este registro. D-017–D-020 documentan aprobación, entorno, estructura y pruebas. El cambio de STORY_BIBLE se limita al estado de aprobación.

## Validaciones de fase 03

Los comandos completos reproducibles están en [TECHNICAL_SETUP.md](TECHNICAL_SETUP.md). Se utilizó el ejecutable de consola existente de Godot, sin alias supuesto ni descarga.

| Validación | Procedimiento y resultado real |
| --- | --- |
| Versión y propiedades | `--version` confirmó 4.7.2 estable; consulta a ProjectSettings confirmó los valores exactos de escalado, orientación y renderer |
| A — Integridad | 21 archivos fuente/documentación no vacíos fuera de caché, 32 enlaces documentales válidos y referencias de recursos existentes; escena y Theme cargados por el motor; sin autoloads ni sistemas jugables |
| B — Importación | `--headless --path 'D:\Ultima Señal' --import`: salida 0, editor headless carga el proyecto sin errores de recursos/scripts reportados |
| C — Inicio directo | Inicio normal por `project.godot` con `--quit-after 10` headless y `--quit-after 30` gráfico: ambas salidas 0, sin errores críticos reportados |
| D — Geometría headless | Auxiliar con tamaños explícitos 720 × 1280, 1080 × 1920 y 1080 × 2400: las tres salidas 0 y `PASS bootstrap_smoke` |
| D — Renderizado e inspección | Mismas tres pruebas sin headless: todas salida 0 y PASS; OpenGL 3.3.0 / Intel UHD Graphics / Compatibility. Capturas con tamaño exacto e inspección sin texto recortado o solapado |
| E — Consola | Sin referencias rotas, errores de scripts, recursos faltantes ni advertencias relevantes reportadas en los comandos finales de esta fase |
| Diseño conservado | Comparación SHA-256 de los tres documentos de `docs/cases/` y del reporte Word de 02 contra su estado previo; contenidos conservados |

El lienzo lógico observado fue 720 × 1280 en las dos proporciones 16:9, y 720 × 1600 en la prueba 1080 × 2400: el aspecto expand amplía altura sin cortar contenido. Evidencias: [720 × 1280](validation/prompt_03/720x1280.png), [1080 × 1920](validation/prompt_03/1080x1920.png) y [1080 × 2400](validation/prompt_03/1080x2400.png).

Incidencia resuelta en el auxiliar: la primera prueba con `--resolution` arrancó headless con Window de 64 × 64, aunque devolvió éxito. Se añadió asignación y comprobación explícita del tamaño solicitado y del lienzo expandido. Se repitieron las tres resoluciones; solo estas pruebas corregidas y sus equivalentes gráficos se consideran evidencia de adaptabilidad. No se ocultó esa diferencia ni se confundió headless con inspección visual.

Godot generó `.godot/` como caché local, excluida por `.gitignore`. Los datos de importación no se consideran archivos fuente. La carpeta sigue sin repositorio Git; no hay `git diff` disponible.

## Cambios de fase 04 — 2026-10-27

- Revisadas las instrucciones, GDD, roadmap, progreso, decisiones, diseño/especificación del caso y fuentes existentes. El estado real coincide con la base de 03; el nuevo prompt sustituye expresamente la restricción de esperar autorización para 04.
- Conservados `project.godot`, `.gitignore`, la raíz Main y su ruta de entrada. Se amplía la raíz para hospedar vistas persistentes de menú, consola e información, sin autoloads ni cambios de escena duplicados.
- Creadas diez escenas: menú, consola, cuatro secciones vacías, cabecera, barra inferior, información y composición de módulo pendiente. Reutilizan el Theme de 03, ampliado según la paleta aprobada en 04.
- Creados siete scripts en `scripts/ui/`, solo para señales, selección de vistas, foco, textos de presentación y márgenes seguros. Agregados cuatro iconos SVG propios, sin recursos de terceros ni descargas.
- Implementados Ingresar, Configuración y Créditos; Continuar deshabilitado y excluido del foco. La consola muestra 02:17 AM/1998 estáticos y cuatro pestañas con icono, etiqueta y marca ACTIVA. Cada entrada abre Llamadas.
- Regreso por botón visible, Escape o notificación de retroceso; información cierra antes de recuperar el menú y su foco. En el menú el retroceso no cierra la aplicación.
- Adaptado bootstrap a la nueva pantalla autorizada, conservando sus comprobaciones de motor/configuración. Añadido navigation_smoke con eventos GUI y verificaciones de foco, scroll y número de instancias.
- Añadido [UI_NAVIGATION.md](UI_NAVIGATION.md) con archivos, flujo, comandos y límites. Se actualizan AGENTS, seguimiento y decisiones D-021–D-024; GDD solo cambia dos menciones de estado técnico y TECHNICAL_SETUP conserva su contexto histórico con referencia al estado actual.
- No se modifican STORY_BIBLE, los tres documentos del Caso 001 ni el reporte Word de 02. No hay commits, pushes, instalaciones, datos narrativos, persistencia ni funcionalidades de 05.

## Validaciones de fase 04

Motor real: `4.7.2.stable.official.ed1daf0bf`. Plataforma: Windows con Compatibility/OpenGL 3.3.0 en Intel UHD Graphics. Los procedimientos reproducibles se encuentran en [UI_NAVIGATION.md](UI_NAVIGATION.md).

| Grupo | Resultado real |
| --- | --- |
| Importación e inicio | Importación headless y arranque directo sin errores críticos reportados; misma escena de entrada y configuración |
| Bootstrap | PASS en 720 × 1280, 1080 × 1920, 1080 × 2400 y 720 × 1600; conserva resolución, orientación, escalado, renderer, idioma y Theme |
| Pruebas 01–05 | Menú inicial, entrada en Llamadas y selección de Audio, Mapa y Expedientes correctos |
| Prueba 06 | Ocho vueltas completas, 32 cambios adicionales; 106 nodos descendientes antes y después del flujo completo, sin duplicación de instancias |
| Pruebas 07–09 | Regreso visible/Escape/notificación, reentrada a Llamadas, abrir/cerrar Configuración y Créditos y restauración de foco correctos |
| Prueba 10 | Continuar deshabilitado; clic no navega y Tab lo omite |
| Pruebas 11–12 | Cuatro resoluciones correctas en ejecución gráfica y pruebas headless; barra visible y sin scroll horizontal; recursos/scripts cargan correctamente |
| Entrada y scroll adicionales | Clics GUI, Tab, flechas, Enter, Escape, toque simulado y contenido informativo largo con regreso accesible correctos |
| Revisión visual | 28 PNG con dimensiones físicas exactas, siete vistas por tamaño, inspeccionados sin recortes o superposición visibles |
| Integridad documental y de recursos | 84 archivos no vacíos fuera de caché, 51 enlaces locales válidos y recursos referenciados existentes; 11 escenas totales y siete scripts UI |
| Alcance conservado | SHA-256 idéntico para project.godot, .gitignore, STORY_BIBLE, los tres documentos del caso y el reporte Word; sin datos funcionales del caso, guardado, audio o despacho |

Las pruebas de navegación envían eventos de entrada al motor, no emiten directamente la señal pressed para sustituir la interacción. Las secuencias definitivas pasan tanto headless como con renderizado real en los cuatro tamaños. El toque simulado y la notificación del sistema verifican el código en escritorio; no son pruebas físicas de Android.

Capturas base: [Menú](validation/prompt_04/720x1280/menu.png), [Llamadas](validation/prompt_04/720x1280/calls.png), [Audio](validation/prompt_04/720x1280/audio.png), [Mapa](validation/prompt_04/720x1280/map.png), [Expedientes](validation/prompt_04/720x1280/evidence.png), [Configuración](validation/prompt_04/720x1280/settings.png) y [Créditos](validation/prompt_04/720x1280/credits.png). También se conservan esas siete vistas bajo las carpetas `1080x1920`, `1080x2400` y `720x1600`.

Incidencias resueltas: constante de retroceso referenciada desde Node en el auxiliar; ciclo de foco explícito que excluye Continuar; secuencia de inyección que actualiza puntero y agrupa pulsación/liberación tras detectar selecciones no aplicadas en una ejecución gráfica de 720 × 1600. Se repitieron las cuatro resoluciones gráficas después del ajuste, sin retirar aserciones de selección. También se mejoró contraste de foco de la acción principal y nitidez de los iconos. No hay errores críticos de esta etapa pendientes detectados.

## Cambios de fase 05 — 2026-10-27

- Revisados los documentos obligatorios, la especificación del Caso 001 y la interfaz existente. Confirmados Godot 4.7.2 estable y funcionamiento previo de navegación. Se conservaron hashes de 46 archivos de configuración, interfaz, pruebas anteriores y fuentes narrativas para comprobar su integridad al cerrar.
- Creado `scripts/narrative/` con seis componentes RefCounted: loader, validator, engine, session_state, condition_evaluator y effect_processor. No se requieren nodos gráficos ni autoloads.
- Adoptado esquema 1 con declaraciones de variables/catálogos, estado inicial y nodos dialogue/transition/ending. Se documentan equivalencias de nombres con preproducción, operadores y límites; no se modifica la historia ni los tres documentos originales del caso.
- Implementadas carga válida, inicio, vistas de solo lectura, selección por ID/revisión, condiciones, efectos acotados, evidencia por ID, transiciones automáticas, eventos pendientes/consumo, finales, reinicio y diagnósticos contextuales.
- Las operaciones usan copia temporal y commit al alcanzar un estado estable. No se publican evidencias/eventos de una operación rechazada; las señales no permiten mutaciones reentrantes. No existe guardado, migración o API de restauración.
- Creado `data/cases/test_narrative.json`, técnico y no canónico: tres diálogos, ocho opciones, una transición y dos finales. No contiene personajes o acontecimientos oficiales.
- Creadas dos suites en `tests/narrative/` y seis fixtures que incluyen errores deliberados. Los UID de los ocho scripts nuevos se generan con Godot y se conservan.
- Añadido [NARRATIVE_ENGINE.md](technical/NARRATIVE_ENGINE.md), con esquema, API, idempotencia, señales, correspondencia con el contrato del caso, comandos, resultados y preparación conceptual para 06. Actualizados AGENTS, ROADMAP, DECISIONS y este registro; D-025–D-029 contienen las decisiones relevantes.
- No se modificaron escenas, Theme, iconos, scripts UI, pruebas anteriores, configuración, GDD, STORY_BIBLE, documentos del caso o reporte Word. No se creó escena de depuración ni botón nuevo; F5 conserva el menú de 04.

## Validaciones de fase 05

Motor real utilizado: `4.7.2.stable.official.ed1daf0bf`. Todas las ejecuciones finales de núcleo/importación/regresión terminaron con salida 0 y sin errores críticos reportados.

| Prueba o grupo | Resultado real |
| --- | --- |
| 01–04 Carga/inicio/elección | Caso técnico válido cargado y ejecutado; errores de archivo, parser y estructura controlados; cursor y destino correctos |
| 05–07 Condiciones/efectos/evidencias | Opciones ocultas/bloqueadas rechazadas incluso por API directa; tipos y límites respetados; evidencia sin duplicados ni señales repetidas |
| 08–10 Transiciones/errores | Transición y fallback correctos; ciclo automático cerrado detectado estáticamente y ciclo condicionado detenido por límite; petición inválida sin modificar sesión |
| 11–13 Final/reinicio/rutas | Dos desenlaces alcanzados, final notificado una vez, decisiones posteriores bloqueadas y todos los registros restaurados al reiniciar |
| 15–17 Determinismo/consulta/carga fallida | Estados iguales para la misma secuencia; consultas repetidas y modificación de copias no alteran el interior; archivos inválidos no destruyen una sesión activa con progreso y eventos pendientes |
| Casos adicionales | Rollback de diálogo bloqueado y transición falsa, consumo de eventos, enum de texto, revisiones obsoletas, profundidad y callbacks reentrantes correctos |
| Suite del motor | `test_narrative_engine.gd`: PASS, 151 comprobaciones |
| Suite de validación | `test_narrative_validation.gd`: PASS, 334 comprobaciones; incluye variaciones de tipos y diagnósticos estructurados |
| Total de núcleo | 485 comprobaciones, sin plugins de pruebas externos |
| 14 Regresión anterior | Bootstrap y navegación PASS headless en 720 × 1280, 1080 × 1920, 1080 × 2400 y 720 × 1600; 106 nodos descendientes estables |
| Inicio directo | Arranque normal por project.godot, tanto headless como gráfico, salida 0 |
| Regresión visual nueva | Navegación gráfica PASS en 720 × 1280; siete capturas con tamaño exacto inspeccionadas sin alteraciones visibles |
| Integridad final | 115 archivos no vacíos fuera de caché, 70 enlaces locales y 57 referencias a recursos comprobados; sin referencias ausentes, salvo el archivo inexistente deliberado de la prueba negativa |
| Conservación del alcance | Los 46 archivos protegidos conservan su SHA-256 previo; configuración, interfaz, pruebas anteriores y fuentes narrativas sin cambios |

Comandos completos en [NARRATIVE_ENGINE.md](technical/NARRATIVE_ENGINE.md). Núcleo ejecutado mediante `--headless --path 'D:\Ultima Señal' --script res://tests/narrative/test_narrative_engine.gd` y el comando equivalente para `test_narrative_validation.gd`. También se ejecutaron `--import`, los auxiliares anteriores y el arranque normal.

Capturas nuevas: [Menú](validation/prompt_05/720x1280/menu.png), [Llamadas](validation/prompt_05/720x1280/calls.png), [Audio](validation/prompt_05/720x1280/audio.png), [Mapa](validation/prompt_05/720x1280/map.png), [Expedientes](validation/prompt_05/720x1280/evidence.png), [Configuración](validation/prompt_05/720x1280/settings.png) y [Créditos](validation/prompt_05/720x1280/credits.png). Las otras tres resoluciones se comprobaron headless en 05; no se presenta esa comprobación como una nueva inspección gráfica.

Incidencias resueltas: comparar un Array inválido con un Dictionary podía generar un error de script dentro del validador; se reemplazó por comprobaciones de tipo antes de comparar. Se ampliaron las variaciones de tipo y referencias de colecciones. Se aclaró que una condición always admite motivo de bloqueo vacío para conservar el ejemplo aprobado, y se corrigieron claves StringName introducidas únicamente al construir una fixture en GDScript para que representara los String reales de JSON. Las suites definitivas pasan completas. No se ocultan errores esperados: son resultados/diagnósticos del motor, no cierres ni fallos de la aplicación.

## Vinculación del repositorio — 2026-10-27

- El usuario autorizó expresamente subir el proyecto a [ArielPerez2001/Last-Signal](https://github.com/ArielPerez2001/Last-Signal). Esta operación no inicia PROMPT 06 ni amplía el juego.
- El remoto no tenía referencias ni historial. Se inicializó Git en esta carpeta con rama main y origin apuntando al repositorio indicado, sin reemplazar historial existente.
- Creado el primer commit local con 115 archivos: estado entregado hasta 05, documentación, pruebas y capturas. Se conserva .gitignore: caché .godot, builds, exports, export_credentials.cfg, temporales y logs quedan excluidos. git diff --cached --check pasó y se verificaron las exclusiones antes del commit.
- El push normal fue rechazado con HTTP 403: Permission to ArielPerez2001/Last-Signal.git denied to arpe22. La cuenta de Git disponible es arpe22; necesita permiso de escritura o debe autenticarse una cuenta autorizada. La conexión de GitHub de la app también requiere reautenticación. El contenido está comprometido localmente, pero no se ha subido ni se ha podido comprobar coincidencia local/remoto.
- No cambió el código del juego; los resultados funcionales siguen siendo los registrados en la fase 05. La subida queda pendiente de resolver el acceso, sin iniciar otra fase.

## Cambios de fase 06 — 2026-10-28

- Leídos PROMPT 06, instrucciones y documentos obligatorios; inspeccionados motor, snapshot, señales, caso técnico, pruebas, escena principal y navegación. No hay instrucciones anidadas aplicables ni cambios locales anteriores al comenzar esta fase. La nueva autorización sustituye la prohibición temporal de persistencia, sin autorizar 07.
- Creado `scripts/systems/save_manager.gd`: una ranura, resultados estructurados, consultas puras, JSON versionado, temporales verificados, respaldo y recuperación conservadora. `save_lifecycle.gd` prepara notificaciones de pausa/foco/cierre como adaptador opcional; no se añade a Main ni actúa sobre UI.
- Añadido `scripts/narrative/narrative_state_validator.gd` y ampliado únicamente `narrative_engine.gd` con metadatos/fingerprint, consulta busy, validación e importación transaccional. NarrativeSessionState y su esquema de 17 campos se conservan sin cambios.
- La restauración verifica estructura/tipos y reconstruye historial en un motor aislado sin observadores; después compara el estado completo. La sesión viva solo se sustituye al pasar todo; no reentra en el nodo ni vuelve a publicar evidencias, eventos o final. Se emite session_restored y vistas actualizadas.
- Adoptados save_version 1, game_id ultima_senal, narrative_schema_version 1 independiente, content_version/fingerprint exactos y fecha UTC. Límites y extensión futura documentados; no hay migraciones automáticas, objetos Godot, rutas del dispositivo o campos ficticios de investigación.
- El autoguardado difiere y agrupa solicitudes de cambios confirmados. Incluye transiciones/final en una escritura, persiste consumos, detecta reinicios y conserva dirty tras errores. Carga no reescribe originales; borrado explícito conserva respaldo por defecto y desactiva autoguardado. No hay cierre que garantice ejecución en Android.
- Creados cinco scripts de pruebas en `tests/save/`: dos suites, soporte, gestor con fallos inyectados y worker de procesos separados. Ocho scripts nuevos con sus UID generados por Godot. Archivos de prueba únicamente en carpetas únicas user://save_tests; producción user://saves no se usa en estos ensayos.
- Añadido [SAVE_SYSTEM.md](technical/SAVE_SYSTEM.md), actualizados NARRATIVE_ENGINE, AGENTS, ROADMAP, DECISIONS y este progreso. Decisiones D-031–D-036. Siete capturas nuevas de regresión en docs/validation/prompt_06/720x1280.
- No se cambiaron project.godot, escenas, scripts UI, Theme/iconos, caso técnico, pruebas anteriores, GDD, STORY_BIBLE ni documentación/reportes del Caso 001. No se realizaron commits, pushes, autenticaciones, instalaciones o exportaciones en 06.

## Validaciones de fase 06

Motor real: `4.7.2.stable.official.ed1daf0bf`; escritorio Windows, Compatibility/OpenGL 3.3.0, Intel UHD Graphics. Ejecuciones finales con salida 0 y sin errores de script o E/S inesperados reportados. Comandos reproducibles en [SAVE_SYSTEM.md](technical/SAVE_SYSTEM.md).

| Prueba o grupo de PROMPT 06 | Resultado ejecutado |
| --- | --- |
| 01 Crear guardado | Principal válido creado; metadatos y estado verificables, sin respaldo anterior ficticio |
| 02–04 Progreso/evidencias/efectos | Snapshot completo igual tras cargar; tipos int/bool, evidencias y eventos consumidos conservados; sin señales nuevas de efectos o adquisiciones |
| 05 Reinicio de proceso | Dos procesos reales separados: uno guarda una decisión/consumo y termina; el otro carga contenido sin iniciar el nodo, recupera el checkpoint y continúa al mismo desenlace |
| 06–10 Ausencia/corrupción/respaldo/incompatibilidad/nodo | Errores controlados; recuperación informa respaldo sin modificar originales; versión/caso/fingerprint y cursor desconocido rechazados |
| 11 Escritura fallida | Fallos inyectados en temporal, temporal de respaldo y ambos renombrados; temporal corrupto detectado; carpeta real obstruida devuelve error. Checkpoint recuperable y sesión conservados; reintento sin repetir efectos |
| 12 Guardados consecutivos | Principal más reciente y respaldo del checkpoint previo validados; un principal corrupto no se copia al respaldo |
| 13 Borrado controlado | Principal eliminado explícitamente, respaldo conservado por defecto; true elimina ambos y sus temporales; archivo ajeno y memoria conservados; pausa/cola pendientes no recrean la ranura |
| 14 Sesión terminada | Final y registros restaurados; elecciones posteriores bloqueadas; consumo posterior al final también persiste |
| 15–16 Tipos/referencias/consultas | Variaciones de tipo, fracciones, bool por int, ID, eventos, historial, registros, enums, objetos/ciclos y límites rechazados; consultas repetidas sin cambiar bytes/sesión/último resultado |
| 17 Regresión del motor | Suites anteriores PASS: 151 + 334 = 485 comprobaciones, sin modificar sus archivos |
| 18 Integridad visual | Bootstrap y navegación PASS headless en 720 × 1280, 1080 × 1920, 1080 × 2400 y 720 × 1600; 106 nodos estables. Navegación gráfica PASS a 720 × 1280; siete capturas inspeccionadas |
| 19 Autoguardado | Una escritura por estado confirmado agrupado; transiciones/final y consumos completos; sin escritura dentro del callback, por frame o durante carga. Fallo mantiene dirty; reintento posterior correcto |
| 20 Restauración fallida | Estado activo completo conservado tras todos los archivos/estados inválidos; sin restauración parcial ni notificación de sesión restaurada |
| Importación e inicio directo | Importación headless y arranque normal headless/gráfico con salida 0; Continuar deshabilitado, menú y cuatro secciones anteriores funcionales |
| Suites nuevas | test_save_manager: PASS, 114 comprobaciones. test_save_validation: PASS, 905 comprobaciones |
| Total de aserciones de las cuatro suites principales | 1019 nuevas + 485 de regresión = 1504 comprobaciones; los contadores internos de los workers no se suman de nuevo |
| Integridad de archivos | 139 archivos no vacíos fuera de .git/.godot; 97 enlaces locales y 70 referencias reales a recursos válidos. Se excluyen de referencias ausentes los dos literales deliberados de pruebas negativas |
| Alcance conservado | 109 de los 115 archivos iniciales mantienen SHA-256 idéntico. Los seis modificados son AGENTS, PROGRESS, ROADMAP, DECISIONS, NARRATIVE_ENGINE y el script narrative_engine; se añaden 24 archivos de esta fase |

Capturas de esta fase: [Menú](validation/prompt_06/720x1280/menu.png), [Llamadas](validation/prompt_06/720x1280/calls.png), [Audio](validation/prompt_06/720x1280/audio.png), [Mapa](validation/prompt_06/720x1280/map.png), [Expedientes](validation/prompt_06/720x1280/evidence.png), [Configuración](validation/prompt_06/720x1280/settings.png) y [Créditos](validation/prompt_06/720x1280/credits.png). No se declara una nueva inspección gráfica de las otras tres resoluciones; sus ejecuciones de 06 fueron headless.

Incidencias resueltas: metadatos mal tipados podían comparar Array con String y lanzar un error de script; se añadieron guardas de tipo antes de comparar. Una aserción inicial comparaba JSON sin normalizar con enteros del estado: ahora comprueba el respaldo mediante el mismo contrato de validación/normalización, manteniendo igualdad de todos los campos. La API de crear directorios imprimía un error nativo para una carpeta obstruida: el gestor detecta primero el archivo que la bloquea y devuelve diagnóstico estructurado. Se fortalecieron los bloqueos para alias de mayúsculas en Windows y la detección de cambios sin suscripción automática; borrado desactiva también el adaptador de ciclo de vida. Las suites finales pasan sin retirar las aserciones de integridad.

Limitaciones de evidencia: no se probaron Android, APK, permisos físicos, corte de energía, disco lleno real, terminación abrupta durante un rename ni rendimiento móvil. Los fallos de E/S son inyectados y una obstrucción real aislada; no se dañó almacenamiento del usuario. Las notificaciones Android se simularon por sus constantes en escritorio. Las pruebas PS01–PS13 del Caso 001 siguen futuras: no se integró su contenido ni sus recursos.

## Cambios de fase 07 — 2026-10-28

- Revisados PROMPT 07, instrucciones, documentos obligatorios y código real de Main, menú, consola, Llamadas, navegación, motor, persistencia, datos y pruebas. Git estaba limpio y sincronizado al iniciar; no hay instrucciones anidadas aplicables. La nueva autorización permite conversaciones con demo técnica, no Caso 001 ni 08.
- Creado CallController RefCounted con IDLE/INCOMING/CONNECTED/ENDED/ERROR, comandos/resultados, coordinación de señales y disposición explícita. La consola conserva instancias, así que no se reescribe navegación raíz ni se añaden autoloads.
- Reutilizada la ruta/instancia calls_panel.tscn: sustituido su placeholder por encabezado CENTRAL 07, identificación, estado, transcripción, respuestas, contexto y acciones de desarrollo. Creados calls_panel.gd, dialogue_choice.gd y dos escenas reutilizables de intervención/respuesta. Theme, paleta y tipografía existentes conservados.
- Ampliado únicamente el contrato del motor con get_conversation_history, reutilizando su reconstrucción de validación para proyectar nodos estables y respuestas confirmadas. No cambia NarrativeSessionState, esquema narrativo o save_version 1; no se añaden campos de historial duplicados ni se ejecutan efectos en la sesión viva al consultar.
- Creado ui_call_demo.json, no canónico: interlocutor desconocido, operador técnico, tres diálogos, diez opciones, una transición, una evidencia, un evento técnico y dos finales. El caso técnico de 05 y toda la narrativa oficial permanecen intactos.
- Demostración accesible desde Llamadas solo en desarrollo: Iniciar prueba, Responder, Recuperar prueba y Reiniciar prueba. user://call_demo está separado de user://saves; las pruebas solo usan directorios únicos user://save_tests. Continuar no se activa.
- SaveManager y SaveLifecycle se reutilizan sin cambios de código. Fallos mantienen sesión/transcripción y permiten reintentar. El adaptador de ciclo de vida queda conectado al gestor de Llamadas; ocultar una pestaña no destruye sesión. Reinicio explícito borra solo archivos de la ranura técnica.
- Ajustados únicamente expansión vertical de Panels y texto de estado de cabecera en dispatch_console para reflejar la comunicación. Audio/Mapa/Expedientes siguen vacíos y no se modifican sus escenas/scripts. Main, menú, navegación raíz y configuración conservan sus archivos.
- Creadas dos suites en tests/calls y los UID de los cinco scripts nuevos. Añadido [CALL_SYSTEM.md](technical/CALL_SYSTEM.md) y 40 PNG en docs/validation/prompt_07. Actualizados AGENTS, GDD (solo estado técnico), UI_NAVIGATION, NARRATIVE_ENGINE, SAVE_SYSTEM, ROADMAP, DECISIONS y este progreso. Decisiones D-037–D-042.
- No hay modificaciones a STORY_BIBLE, documentos del Caso 001, reporte Word, Theme/iconos, project.godot, algoritmos de guardado ni pruebas anteriores. Sin commits, pushes, credenciales, instalaciones, servicios externos, audio nuevo o exportaciones.

## Validaciones de fase 07

Motor real: `4.7.2.stable.official.ed1daf0bf`; Windows, Compatibility/OpenGL 3.3.0, Intel UHD Graphics. Todas las ejecuciones finales indicadas terminaron con salida 0; sin errores de script, fugas o errores críticos pendientes en los recorridos aprobados. Los diagnósticos CALL_DIAGNOSTIC de las pruebas negativas son resultados esperados del controlador, no fallos del proceso.

| Prueba de PROMPT 07 | Resultado ejecutado |
| --- | --- |
| 01–03 Inicialización/entrante/responder | IDLE sin sesión; preparar no aplica entradas ni guarda; Responder inicia una sola sesión y muestra CONNECTED |
| 04–07 Elecciones/rechazo/doble pulsación/condiciones | ID/revisión al motor; opciones ocultas/bloqueadas rechazadas; estado e historial intactos ante rechazo; doble activación del mismo turno y gestos clasificados de mouse/toque no avanzan dos veces |
| 08 Historial | Orden, autor y texto de elecciones reales; IDs por visita/revisión; consultas y consumos no crean mensajes, ramas no visitadas y transición no aparecen; copias independientes |
| 09 Cambio de sección | Audio/Mapa/Expedientes/Llamadas y menú/consola conservan snapshot, historial y controles de transcripción, sin nueva llamada o efecto |
| 10–11 Finalización/reinicio | Dos rutas reales a demo_complete/demo_partial; final bloquea decisiones y se notifica una vez; reinicio explícito limpia historial/checkpoints técnicos y vuelve a INCOMING |
| 12–14 Guardado/restauración/final | Autoguardado confirmado, recuperación en controlador nuevo con estado/historial exactos; sesión respondida vuelve CONNECTED, finalizada vuelve ENDED. No se repiten evidencias, efectos o eventos; se revela intervención actual al recuperar |
| 15 Aislamiento | Constructor rechaza user://saves; demo en user://call_demo; suites en directorios únicos user://save_tests; política de desarrollo desactivada impide lanzar desde panel |
| 16 Regresión narrativa | Suites intactas PASS: test_narrative_engine 151 y test_narrative_validation 334 comprobaciones |
| 17 Regresión de guardado | Suites intactas PASS: test_save_manager 114 y test_save_validation 905 comprobaciones, incluidos procesos separados |
| 18 Navegación anterior | Bootstrap y navigation_smoke PASS headless en cuatro resoluciones. Instancias estables: 129 nodos antes/después del flujo de navegación sin iniciar demo |
| Controlador nuevo | test_call_controller PASS, 68 comprobaciones; incluye recuperación fallida conservando sesión/política y fallo de escritura con reintento |
| GUI headless | test_call_integration PASS: 402 comprobaciones en 720×1280/1080×1920 y 400 en 1080×2400/720×1600 |
| GUI gráfica | PASS: 452 comprobaciones en 720×1280/1080×1920 y 450 en 1080×2400/720×1600; 50 de cada ejecución corresponden a diez capturas verificadas |
| Total principal de referencia | 1974 aserciones = 1504 de las cuatro suites anteriores + 68 de controlador + 402 de integración base. No se presentan repeticiones de resolución/captura como escenarios nuevos |
| Textos/entrada/scroll | Mouse y toque simulados, respuestas largas sin elipsis, motivo de bloqueo visible, historial largo desplazable y lectura antigua sin salto al agregar intervención. Respuestas y reintento accesibles sobre barra fija |
| Errores visibles | Archivo inexistente muestra ERROR y permite preparar de nuevo; fallo de disco muestra reintento conservando CONNECTED; recuperación fallida no borra memoria ni desactiva definitivamente el autoguardado anterior |
| Importación/arranque | Importación headless y arranque normal headless/gráfico correctos; F5 abre menú, no inicia demo ni crea partida oficial |
| Revisión visual | 40 PNG reales de tamaño físico exacto: diez estados por resolución, inspeccionados; controles y separación legibles, sin desbordamiento horizontal o superposición, contenido largo consultable por scroll |
| Integridad final | 193 archivos no vacíos fuera de .git/.godot, 164 enlaces locales y 82 referencias resolubles a recursos, sin ausencias inesperadas; literales de archivos inexistentes excluidos solo en sus pruebas negativas |
| Alcance conservado | 127 de los 139 archivos iniciales conservan SHA-256 idéntico; doce modificados dentro del alcance y 54 nuevos, incluidos cinco scripts con UID, dos escenas, JSON, documentación y 40 capturas |

Las diferencias de dos aserciones entre proporciones corresponden a controles internos de scroll visibles solo cuando hacen falta; no se retiran requisitos. La prueba de acceso de desarrollo comprueba la política desactivada en escritorio; no equivale a exportar una compilación release.

Procedimientos completos y matriz de las 40 capturas en [CALL_SYSTEM.md](technical/CALL_SYSTEM.md). Muestras 720×1280: [Entrante](validation/prompt_07/720x1280/incoming.png), [Conectada](validation/prompt_07/720x1280/connected.png), [Opciones condicionadas](validation/prompt_07/720x1280/conditional.png), [Recuperada](validation/prompt_07/720x1280/restored.png), [Final](validation/prompt_07/720x1280/ended.png) y [Fallo de guardado](validation/prompt_07/720x1280/save_error.png).

Incidencias resueltas: las referencias cruzadas de señales mantenían controlador/gestor vivos al salir; dispose y la desconexión de pruebas/escena eliminaron las fugas. Una prueba usaba is_enabled inexistente en Button: se corrigió a la propiedad disabled. Se preserva la política de autoguardado después de una restauración fallida y se bloquean reentradas desde presentation_changed. La cabecera común todavía indicaba línea en espera durante una conversación: ahora deriva el estado visual real. Se compactaron contexto/separaciones y se sustituyen herramientas de desarrollo por reintento cuando falla disco, manteniendo controles accesibles. Al reconstruir historial nuevo, el rango antiguo de un scroll oculto podía impedir mostrar la intervención reciente: se reconoce historial vacío como seguimiento nuevo y se espera el layout antes de posicionar. Las pruebas finales verifican esos comportamientos sin retirar aserciones.

Pruebas pendientes/no ejecutadas: Android físico, APK/exportación, compilación release real, gestos/interrupciones de dispositivo, lector de pantalla y rendimiento móvil. Las notificaciones y toques son simulaciones de escritorio. Las escenas de resultados oficiales, audios, expedientes/deducciones, mapa y todos los recorridos del Caso 001 siguen sin implementación.

## Cambios de fase 08 — 2026-10-28

- Revisados AGENTS, progreso/roadmap/decisiones, diseño y especificación oficial, contratos de motor/guardado/llamadas y código pertinente. Repositorio inicialmente limpio en main/origin/main, HEAD 4c7afd3d7a22efd65a2843ee4d0f28c3b07d83ee; conservados hashes SHA-256 de sus 193 archivos de fuente/documentación/evidencia. La autorización del nuevo prompt sustituye la prohibición temporal de 08; no autoriza 09 ni cambios remotos.
- Creados EvidenceManager y DeductionManager como fachadas del motor existente. Categorías centrales, catálogo completo validado, proyecciones de fichas descubiertas sin importance/total oculto, procedencia, orden estable, recursos opcionales restringidos y fallback textual. Alta real vía add_to_set y acciones declaradas; descubrimiento repetido no duplica conjunto o señal.
- Introducido esquema narrativo 2 con investigation.evidence/actions/deductions; esquema 1 y sus JSON anteriores conservados. Reglas exactas sin orden de dos/tres fichas, condiciones actuales, resultados VALID/ALREADY_DISCOVERED/INSUFFICIENT/LOCKED/INVALID y operativos STALE/BUSY. Dos reglas para el mismo conjunto o IDs de acción/opción/deducción en colisión se rechazan.
- Añadida confirmación externa atómica al motor con EffectProcessor existente. Registra ID/revisión en executed_actions/transaction_log, aplica efectos al candidato y verifica opciones elegibles. Rechazo revierte todo; éxito publica estado/avisos/deducción/opciones sin cambiar cursor/visitas, repetir entry_effects o inventar líneas de conversación. ConditionEvaluator, EffectProcessor y NarrativeSessionState permanecen intactos.
- Versionado save_version 2 para casos esquema 2 y conservado formato 1 para esquema 1. Envoltura de ocho campos y snapshot de 17 campos sin duplicaciones; conclusiones derivadas de executed_actions. Reconstrucción aislada del diario reconoce opciones/consultas/deducciones e intercala consumos. Sin migraciones: referencias/versiones/contenido incompatibles se rechazan preservando sesión/originales y política de respaldo.
- Reutilizada evidence_panel.tscn con tarjetas, filtros descubiertos, descripción completa/procedencia/imagen opcional, selección de dos, retroalimentación y conclusiones consultables. Expediente finalizado es solo consulta. Selección/filtro/detalle no persisten, no conceden efectos y se conservan entre pestañas/detalle hasta cambiar/restaurar/reiniciar sesión. Navegación inferior fija y Theme/iconos propios conservados.
- DispatchConsole enlaza el expediente al motor y SaveManager reales de CallController, sin crear otra sesión. CallsPanel añade controller_replaced y botón de desarrollo Prueba de investigación, recuerda caso/ruta para recuperar y conserva flujo anterior. Fallo de E/S visible en ambos paneles, con reintento del mismo estado; dispose/desconexiones conservan ciclo de vida sin fugas.
- Creado investigation_demo.json no canónico: cinco fichas/cinco categorías, tres adquisiciones por diálogo y dos por consultas condicionadas, dos deducciones (una desbloquea diálogo, otra opcional con requisito adicional), cinco nodos, ocho opciones y dos finales. user://investigation_demo separado de user://call_demo y user://saves. Las pruebas usan únicamente subrutas únicas user://save_tests.
- Creadas tres suites de investigación, fixture de rollback y seis UID de scripts. Documentación técnica de 18 apartados en [INVESTIGATION_SYSTEM.md](technical/INVESTIGATION_SYSTEM.md), ampliados contratos de motor/guardado/llamadas y estados en AGENTS/GDD/UI_NAVIGATION/ROADMAP/este progreso. Decisiones D-043–D-048. Guardadas 56 capturas reales de Godot en docs/validation/prompt_08.
- No se modifican historia aprobada, STORY_BIBLE, fuentes del Caso 001, reporte Word, project.godot, Theme/iconos o pruebas anteriores. Sin commits/pushes, credenciales, instalaciones, dependencias, APK, cambios remotos o mecánicas posteriores.

### Archivos de la entrega 08

| Tipo | Archivos |
| --- | --- |
| Nuevos servicios/UI | scripts/systems/evidence_manager.gd, scripts/systems/deduction_manager.gd, scripts/ui/evidence_panel.gd y sus tres UID |
| Nueva escena | scenes/components/evidence/evidence_card.tscn |
| Nuevos datos | data/cases/investigation_demo.json y tests/investigation/fixtures/blocked_effect.json |
| Nuevas pruebas | tests/investigation/test_evidence_manager.gd, test_deduction_manager.gd, test_integration.gd y sus tres UID |
| Nuevos documentos/evidencia | docs/technical/INVESTIGATION_SYSTEM.md y 56 PNG en docs/validation/prompt_08 (14 por tamaño) |
| Código modificado | scripts/narrative/narrative_engine.gd, narrative_validator.gd, narrative_state_validator.gd; scripts/systems/save_manager.gd y call_controller.gd; scripts/ui/calls_panel.gd y dispatch_console.gd |
| Escenas modificadas | scenes/screens/sections/evidence_panel.tscn y calls_panel.tscn |
| Documentos modificados | AGENTS.md; docs/GDD.md, UI_NAVIGATION.md, PROGRESS.md, ROADMAP.md, DECISIONS.md; docs/technical/NARRATIVE_ENGINE.md, SAVE_SYSTEM.md y CALL_SYSTEM.md |

## Validaciones de fase 08

Entorno real: Godot 4.7.2.stable.official.ed1daf0bf, Windows, Compatibility/OpenGL 3.3.0, Intel UHD Graphics. Todos los resultados finales PASS indicados terminaron con salida 0. CALL_DIAGNOSTIC write_error en integración es el fallo de disco inyectado deliberadamente para probar aviso y reintento, no un error de script o fallo del proceso. No hay errores críticos pendientes detectados en el alcance ejecutado.

| Grupo de aceptación del PROMPT 08 | Comprobación realmente ejecutada y resultado |
| --- | --- |
| 01 Catálogo | Cinco fichas válidas, categorías/importancia/procedencia/orden y recurso opcional, esquema 2 cargado correctamente |
| 02 Datos inválidos | Campos ausentes/mal tipados, ID duplicados/no declarados, categorías, importancia, condiciones/efectos, combinación ambigua y rutas inseguras rechazados; imagen ausente advertida con texto disponible |
| 03 Descubrimiento | Tres elecciones conceden e01–e03 y dos consultas autorizadas e04/e05; Expedientes usa el mismo estado del motor |
| 04 Duplicados | Repetir adquisición conserva tamaño y no repite señal de descubrimiento |
| 05 Ocultas | ID oculto/desconocido devuelve UNAVAILABLE vacío; títulos/categorías futuras e importance no aparecen en proyección; acciones condicionadas no filtran títulos |
| 06 Detalle | Título, descripción completa, categoría y procedencia correctos; imagen validada renderizada; consulta conserva snapshot |
| 07 Selección | Mouse + toque al viewport seleccionan dos fichas distintas, exactamente una activación táctil; filtro/detalle conservan selección |
| 08 Selección inválida | Repetidas/desconocidas/no descubiertas devuelven INVALID, conservando estado |
| 09 Deducción válida | e01 + e02 confirma inv_d01, registra conclusión y aplica una vez variable/contador/evento |
| 10 Orden | Orden inverso e02 + e01 obtiene la misma relación válida; evaluación exacta de conjunto |
| 11 Insuficiencia | Una ficha o e01 + e03 devuelve INSUFFICIENT neutral, sin cambios o penalización |
| 12 Repetida | ALREADY_DISCOVERED sin revisión/efectos/eventos/señal nuevos ni nueva escritura automática |
| 13 Condición adicional | e04 + e05 devuelve LOCKED sin título de solución hasta inv_review; después confirma inv_d02 |
| 14 Consecuencias | Aparece inv_unlocked en opciones del nodo vigente; cursor/visitas/historial permanecen idénticos al deducir |
| 15 Navegación | Llamadas/Audio/Mapa/Expedientes conserva snapshot, selección y número de instancias; retorno muestra opciones actualizadas |
| 16 Guardado | Documento real save_version 2/narrative_schema_version 2, session de 17 campos con fichas, acciones y efectos |
| 17 Restauración | Motor/gestor nuevos recuperan disco con cinco fichas, dos conclusiones y snapshot/transcripción exactos |
| 18 Incompatible | ID de evidencia/deducción inventados y formato 1 para esquema 2 rechazados; sesión viva conservada |
| 19 Nueva sesión | Reinicio limpia evidencia, conclusiones y selección anterior; vuelve a llamada preparada |
| 20 Regresión | Suites intactas de motor (151/334), guardado (114/905), controlador (68) e integración de llamadas (402 base) PASS |
| 21 Integridad visual | Bootstrap y navegación PASS en cuatro resoluciones; menú y cuatro pestañas operativos, Continuar deshabilitado; 56 PNG inspeccionados |
| 22 Determinismo | Misma secuencia en sesiones nuevas produce snapshot completo idéntico |
| 23 Persistencia de efectos | Restauración no publica evidence_registered/deduction_confirmed/event_requested; contador/eventos/once_key y transcripción exactos |
| 24 Rechazo seguro | Pares inválidos/bloqueados y fixture que elimina todas las opciones revierten variables, eventos y diarios; estado anterior intacto |

Comprobaciones adicionales ejecutadas: rechazo STALE sin mutación, BUSY durante notificación, inv_complete alcanzable sin la deducción opcional e inv_partial alcanzable con una sola pista, conservando su consulta sin inventar conclusiones.

### Cifras finales y procedimientos

| Suite/comprobación | Resultado final |
| --- | --- |
| test_evidence_manager | PASS, 69 aserciones |
| test_deduction_manager | PASS, 88 aserciones |
| Investigación GUI headless, 720×1280 / 1080×1920 | PASS, 2349 aserciones por ejecución |
| Investigación GUI headless, 1080×2400 / 720×1600 | PASS, 2347 aserciones por ejecución |
| Investigación GUI gráfica, 720×1280 / 1080×1920 | PASS, 2419 aserciones por ejecución |
| Investigación GUI gráfica, 1080×2400 / 720×1600 | PASS, 2417 aserciones por ejecución |
| Regresión de seis suites anteriores | PASS, 1974 aserciones de referencia; fuentes sin cambios |
| Total principal de referencia | 4480 = 1974 anteriores + 69 + 88 + 2349; no cuenta repeticiones de tamaño/capturas como escenarios nuevos |
| Bootstrap/navigation | PASS headless en cuatro tamaños; 144 nodos estables antes/después de navegación sin iniciar demo |
| Importación/arranque | Importación headless, arranque normal headless y gráfico salida 0, sin errores de script/fugas reportados |
| QA visual | 56 PNG de dimensiones exactas, catorce estados por resolución; inspección de las cuatro hojas de contacto y detalles originales; texto largo accesible por scroll, sin desbordamiento horizontal/superposición y barra inferior accesible |
| Integridad documental/recursos | 265 archivos no vacíos fuera de .git/.godot, 224 enlaces Markdown locales válidos y 104 referencias resolubles de recursos; seis referencias ausentes/inseguras solo en contextos de pruebas negativas identificados |
| Integridad de alcance | 175 de los 193 archivos iniciales conservan SHA-256 idéntico; 18 modificados y 72 nuevos (56 capturas y 16 fuentes/datos/documentación/UID). Historia oficial, configuración, Theme, iconos y pruebas anteriores intactos; HEAD/origin/main sin cambios |

Las 70 aserciones adicionales de cada ejecución gráfica verifican catorce capturas. La diferencia de dos entre proporciones depende de controles internos de scroll visibles; no se omiten requisitos. Los contadores son aserciones y no ese número de casos de prueba independientes. Comandos reproducibles, recorrido manual, contratos de autoría y enlaces a capturas en [INVESTIGATION_SYSTEM.md](technical/INVESTIGATION_SYSTEM.md). Ejemplo base: [deducción confirmada](validation/prompt_08/720x1280/valid.png), [detalle](validation/prompt_08/720x1280/evidence_detail.png), [restauración](validation/prompt_08/720x1280/restored.png), [fallo de escritura](validation/prompt_08/720x1280/save_error.png).

Incidencias corregidas: el chequeo de versiones contra un array de enteros rechazaba números JSON integrales representados como float; se normaliza solo después de validar tipo/integralidad, manteniendo rechazos de bool/string/fracciones. Se añadieron controles de candidato estable para impedir una deducción que dejase el diálogo sin opciones. Se preserva el historial hablado al reproducir entradas externas y se desconectan fachadas al sustituir controlador. La proyección de acciones ocultaba su habilitación pero aún mostraba títulos futuros: ahora solo devuelve las disponibles. Se eliminó espacio reservado por etiquetas de aviso vacías y se aseguró aviso visible al intentar una tercera selección. Un toque por la ruta global falló en 1080×1920: el auxiliar ahora envía al viewport con coordenadas locales y exige una sola activación; las cuatro resoluciones gráficas finales pasan. El límite de 30 segundos del auxiliar se agotó capturando closed en 720×1600: se amplió a 60 segundos solo en pruebas y esa resolución completó las 2417 comprobaciones. Las ejecuciones fallidas previas no se cuentan como PASS.

Pruebas no ejecutadas: Android físico, APK/exportación release, gestos físicos/interrupciones reales, accesibilidad con lector de pantalla, rendimiento móvil, corte eléctrico y llenado físico de disco. Fallos de E/S, notificaciones y toque son simulados en escritorio. La compatibilidad release se comprueba únicamente por política de desarrollo, sin exportar. No se ejecutaron pruebas oficiales del Caso 001, que sigue documental. Los resultados de 07 y anteriores conservan sus evidencias históricas; no se atribuyen a los escenarios nuevos.

## Problemas conocidos y pendientes

- La carpeta ya tiene repositorio Git local y origin configurado por autorización posterior del usuario. La futura publicación de otros cambios sigue requiriendo autorización explícita.
- No hay errores críticos de la base técnica pendientes detectados. La versión usada es Godot 4.7.2 estable y la revisión editorial de fase 02 quedó aprobada al recibir PROMPT 03.
- No están definidos dispositivos objetivo, versión mínima de Android ni presupuestos técnicos medibles.
- Público objetivo y mejoras de accesibilidad adicionales figuran como propuestas, pendientes de aprobación.
- No hay contradicciones detectadas entre MVP y campaña. PROMPT 02 confirma incendio y clausura en 1981; sus fechas exactas siguen propuestas. Su relación causal con el incidente general sigue abierta.
- El objetivo de 8–15 minutos del Caso 001 sigue siendo una estimación sin pruebas de personas reales. El núcleo genérico y su persistencia están probados en 05–06; su integración con el contenido oficial y sus invariantes específicas siguen pendientes.
- Android sigue pendiente: no hay APK, exportación, SDK validado, plantillas de exportación verificadas ni prueba en dispositivo real. Las capturas son de escritorio y no demuestran zonas seguras o rendimiento móvil.
- Menú y navegación siguen funcionando; Llamadas y Expedientes comparten investigación técnica solo en desarrollo. Audio/Mapa permanecen vacíos. No hay llamadas oficiales del Caso 001, reproducción/filtros de audio, mapa funcional, despacho, resultados definitivos o Continuar activado.
- Los márgenes seguros Android tienen adaptación por API, pendiente de probar en dispositivo. Retroceso gestual/físico, densidad táctil real, lector de pantalla y rendimiento móvil permanecen pendientes. No hay APK ni pruebas en teléfono.
- Créditos carece todavía de autoría confirmada y Configuración no permite ajustar preferencias; ambas limitaciones son visibles en la interfaz.
- El validador no demuestra todas las combinaciones de condiciones. Una carga estructuralmente válida puede tener un inicio bloqueado: start_case informa el error sin sesión parcial. Las elecciones fallidas conservan su estado anterior. Los contratos de variantes de texto y resolución específica del caso siguen pendientes de integración autorizada.
- El guardado 1 para esquema 1 y guardado 2 para esquema 2 exigen contenido/fingerprint exactos y no incluyen migraciones. Usan I/O síncrona, límites documentados y bloqueos de hilo principal dentro de un proceso; no hay garantía de atomicidad universal, durabilidad eléctrica o coordinación entre procesos externos. Las demos informan/reintentan; las decisiones de reemplazo y salida de la interfaz oficial siguen futuras.
- La transcripción deriva presentación lógica confirmada, no acredita lectura humana o dibujo completo antes de una interrupción. Su reconstrucción y los controles crecen con el historial; no se ha medido rendimiento móvil. La demostración está limitada y el guardado conserva sus cotas de 06.
- La UI de investigación permite dos fichas por relación; servicio/esquema admiten tres para contenido futuro. No hay reglas repetibles o ambiguas, IA de deducción, inventario convencional o migración de partidas. El coste de regenerar tarjetas y reconstruir registros no se ha perfilado en Android.

## Próxima etapa autorizable

**09 — Analizador de audio**, únicamente después de recibir un prompt con autorización explícita. Investigación genérica, llamadas y guardado están conectados en una demo fuera de campaña; el Caso 001 sigue sin integrar. **La fase 08 termina aquí y no se inicia 09.** Al reanudar, consultar primero [AGENTS.md](../AGENTS.md), [INVESTIGATION_SYSTEM.md](technical/INVESTIGATION_SYSTEM.md), [CALL_SYSTEM.md](technical/CALL_SYSTEM.md), [NARRATIVE_ENGINE.md](technical/NARRATIVE_ENGINE.md), [SAVE_SYSTEM.md](technical/SAVE_SYSTEM.md) y los documentos pertinentes.
