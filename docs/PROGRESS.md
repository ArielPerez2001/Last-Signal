# ÚLTIMA SEÑAL — Registro de progreso

## Estado actual

Actualizado: 2026-10-27, fecha local del usuario. **Etapa 05 completada: motor narrativo independiente verificado en Godot 4.7.2 estable, en escritorio Windows.** El usuario aprobó 00–04 al enviar PROMPT 05. El motor solo ejecuta contenido técnico aislado; la interfaz anterior permanece igual y el Caso 001 no es jugable. Trabajo detenido; PROMPT 06 no autorizado.

## Etapas completadas

- **00 — Contexto maestro:** recibido y comprendido; objetivos, sistemas y límites establecidos.
- **01 — Documentación:** raíz inspeccionada, seis documentos creados y comprobaciones documentales realizadas.
- **02 — Diseño completo del Caso 001:** entregables documentales y trazas realizados en 02; aprobación editorial expresa al iniciar PROMPT 03, registrada en D-017.
- **03 — Proyecto Godot:** configuración, escena principal, Theme, importación, inicio directo y validación de tres resoluciones en headless y con renderizado real.
- **04 — Navegación e interfaz base:** menú, consola, cuatro paneles reutilizables, pantallas informativas y regreso; configuración conservada, cuatro resoluciones verificadas y 28 capturas inspeccionadas.
- **05 — Motor narrativo:** carga/validación JSON, estado temporal, condiciones, efectos, transacciones, eventos, transiciones, finales y reinicio. Caso técnico de seis nodos y dos desenlaces, sin conexión a la consola.

Las etapas 06–23 y las subfases 19.1–19.4 permanecen pendientes. El estado detallado y la aceptación de cada etapa están en [ROADMAP.md](ROADMAP.md). Los estados de revisión pendiente en las entregas originales de 02 describen su situación al entregarse, anterior a la aprobación de PROMPT 03.

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

## Problemas conocidos y pendientes

- La carpeta ya tiene repositorio Git local y origin configurado por autorización posterior del usuario. La futura publicación de otros cambios sigue requiriendo autorización explícita.
- No hay errores críticos de la base técnica pendientes detectados. La versión usada es Godot 4.7.2 estable y la revisión editorial de fase 02 quedó aprobada al recibir PROMPT 03.
- No están definidos dispositivos objetivo, versión mínima de Android ni presupuestos técnicos medibles.
- Público objetivo y mejoras de accesibilidad adicionales figuran como propuestas, pendientes de aprobación.
- No hay contradicciones detectadas entre MVP y campaña. PROMPT 02 confirma incendio y clausura en 1981; sus fechas exactas siguen propuestas. Su relación causal con el incidente general sigue abierta.
- El objetivo de 8–15 minutos del Caso 001 sigue siendo una estimación sin pruebas de personas reales. La carga, errores e idempotencia del núcleo genérico ya se probaron en 05; su integración con el contenido oficial y el guardado definitivo siguen pendientes.
- Android sigue pendiente: no hay APK, exportación, SDK validado, plantillas de exportación verificadas ni prueba en dispositivo real. Las capturas son de escritorio y no demuestran zonas seguras o rendimiento móvil.
- Menú y navegación siguen funcionando y sus módulos permanecen vacíos. Existe un motor independiente con datos técnicos de prueba, pero no llamadas jugables, reproducción de audio, mapa funcional, expedientes, deducciones, datos oficiales del Caso 001 ni guardado.
- Los márgenes seguros Android tienen adaptación por API, pendiente de probar en dispositivo. Retroceso gestual/físico, densidad táctil real, lector de pantalla y rendimiento móvil permanecen pendientes. No hay APK ni pruebas en teléfono.
- Créditos carece todavía de autoría confirmada y Configuración no permite ajustar preferencias; ambas limitaciones son visibles en la interfaz.
- El validador no demuestra todas las combinaciones de condiciones. Una carga estructuralmente válida puede tener un inicio bloqueado: start_case informa el error sin sesión parcial. Las elecciones fallidas conservan su estado anterior. Los contratos de variantes de texto y resolución específica del caso siguen pendientes de integración autorizada.
- La fase 06 deberá definir guardado/restauración y versiones de archivo, conservando cursores, registros de ejecución y eventos sin repetir efectos. No se implementó esa fase.

## Próxima etapa autorizable

**06 — Estado y guardado**, únicamente después de recibir el siguiente prompt con autorización explícita. El motor ofrece snapshots serializables, versión de contenido y registros temporales, pero todavía no escribe ni restaura archivos. Esta fase 05 termina aquí. Al reanudar, consultar primero [AGENTS.md](../AGENTS.md), [NARRATIVE_ENGINE.md](technical/NARRATIVE_ENGINE.md) y los documentos pertinentes.
