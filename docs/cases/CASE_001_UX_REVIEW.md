# Caso 001 — Orientación y reducción de fricción

2026-10-29. Revisión correctiva posterior a PROMPT 11, autorizada por el usuario con «Adelante, hazlo» después del diagnóstico de flujo/interfaz. No inicia 12, 13 o 09B.

## Problema y resultado

La primera integración comprobaba sistemas funcionales, pero presentaba demasiadas acciones con igual peso. El jugador debía aprender rutas entre pantallas, recordar qué había seleccionado y encontrar cómo continuar después de un hallazgo. Esta revisión concentra el esfuerzo en interpretar el caso y tomar sus decisiones.

| Antes | Ahora |
| --- | --- |
| Nueve opciones al entrar en investigación | Dos principales en el recorrido cordial inicial; otras consultas desplegables y todas las herramientas disponibles desde sus pestañas |
| Orientación general «contraste las fuentes» | Objetivo contextual y acceso directo a la herramienta correspondiente, sin mostrar combinaciones o destino correcto |
| Responder y volver a elegir atender | La introducción de Elena muestra las opciones; Atender confirma la conexión y la opción existente en una sola interacción |
| Abrir herramienta y perder su explicación | Instrucciones locales en cada herramienta y Retomar llamada fijo |
| Regresar a Llamadas y elegir volver | Un botón de retorno realiza la consulta de regreso existente cuando corresponde |
| Ubicación → incidente → R1 → revisar → confirmar | Elegir acceso → confirmar; incidente/R1 preseleccionados únicamente porque hay una sola opción para ese destino |
| Parte disponible solo tras una ruta concreta de pestañas | El gesto explícito de recibir parte prepara su contexto narrativo mediante opciones sin efectos, de forma atómica |
| Cuatro hipótesis grandes, tarjetas y confirmación separadas | Selector de pregunta; hipótesis/selección y Comprobar relación siempre visibles al pie mientras se examinan las tarjetas |
| Desplazamiento perdido al cambiar sección | Posición independiente por pestaña; acciones explícitas enfocan nuevo texto, transcripción, confirmación o explicación |
| Transporte deshabilitado y dos acciones de registro en audio pendiente | Una consulta Leer fragmento que revela la transcripción y registra su observación por el servicio existente |

Los recuentos de pulsaciones excluyen pestañas, desplazamientos y lectura. Son comparación del procedimiento/control requerido, no medición de una partida humana. Abrir opciones adicionales es voluntario. Al habilitarse una respuesta crítica o necesitar calma se muestra entre las principales; no se elimina ninguna opción del motor.

## Archivos y responsabilidades

- scripts/ui/case_guidance.gd: perfil puro de presentación para c001. Objetivo por etapa/información conocida, agrupación de opciones y rótulos claros. No concede pruebas, interpreta deducciones, decide finales o inicia acciones por consultar el objetivo.
- scripts/ui/dispatch_console.gd y scenes/screens/dispatch_console.tscn: cabecera compacta, objetivo, avisos de evidencia/respuesta nueva, desplazamiento por sección y barra de acciones común. Herramientas deshabilitadas en A/B hasta completar la apertura del expediente; demos mantienen su comportamiento.
- CallsPanel/escena: conexión sin botón duplicado, texto vigente, consultas adicionales y retorno explícito.
- EvidencePanel/escena: selector de hipótesis con filas amplias, limpieza de selección al confirmar y foco de explicación. La lógica sigue en DeductionManager.
- MapPanel: R1/incidente preseleccionados cuando son únicos, confirmación y cancelación visibles, partes antes del plano, plano compacto y aviso cuando hay un plan preparado.
- AudioPanel: modo textual sin controles inactivos, revelación explícita de transcripción, foco de lectura; no se añade audio, TTS o síntesis.
- NarrativeEngine y DispatchManager: preparación transaccional de contexto de partes, optativa para la presentación oficial. La API estricta anterior conserva sus restricciones.
- tests/cases/case_001/test_case_guidance.gd y test_case_integrations.gd: límites del contexto y recorrido de la UI revisada. Se actualizan los documentos de seguimiento/contratos afectados.

## Conservación de decisiones y partidas

Los JSON narrativos, voice_inventory, guion de 02, STORY_BIBLE, Theme, project.godot y WAV de las demos permanecen idénticos a la entrega anterior. Se conserva el fingerprint y no se requiere migración o reemplazo de la partida por esta revisión. No se cambia el algoritmo de SaveManager ni sus formatos 1–4.

No se cambian confianza/estrés, pruebas requeridas, condiciones A/C/B, elecciones de destino, instrucción o advertencia del pasillo. Las únicas opciones agrupadas son de presentación; el motor conserva las 57. Las herramientas no se abren por un efecto automático del objetivo. Cambiar pestaña o leer una orientación no altera el snapshot.

## Contexto seguro de partes

DispatchManager.contextual_reports es optativo; la UI oficial lo activa. preview_contextual_dispatch consulta disponibilidad sin escribir o entrar en nodos. Si el parte requiere from_node, se busca una ruta de hasta dieciséis nodos visitados con opciones elegibles, sin efectos de opción o entrada, y solo destinos de diálogo. No se cruza una transición automática, evidencia, elección emocional o cambio de plan.

process_contextual_dispatch revalida revisión y disponibilidad, reproduce las opciones autorizadas y el parte sobre una instancia candidata sin observadores de juego. Usa select_choice y process_dispatch existentes. Al alcanzar un estado estable publica una sola actualización con las evidencias/eventos reales. Un fallo descarta también visitas y entradas de diario de la preparación; no deja navegación parcial.

El diario incluye las opciones normales de consulta y el comando de parte; la reconstrucción existente lo valida sin un formato nuevo. Repetir un parte no vuelve a entrar en consultas. Un plan preparado exige que el jugador lo corrija explícitamente: la nueva navegación no puede cancelarlo o transmitirlo. Las reglas de unidad/incidente, compatibilidad, disponibilidad y consecuencias permanecen en los servicios.

## Verificación

Resultados finales en [PROGRESS.md](../PROGRESS.md). Se ejecutan el recorrido de UI en cuatro tamaños, las diez rutas originales y las suites anteriores. La suite nueva prueba disponibilidad desde investigación/audio/expediente, consultas puras, revisión obsoleta, incidente incorrecto, rechazo con rollback completo, publicación única, idempotencia, guardado/restauración e imposibilidad de cruzar una instrucción preparada.

La GUI comprueba introducción sin responder dos veces, objetivo accionable, consultas desplegables, apertura del selector, confirmación fija al seleccionar dos/tres evidencias, limpieza posterior, avisos de nueva respuesta, retorno directo, desplazamiento conservado, despacho de dos pasos y transcripción completa visible. Las capturas de esta revisión se guardan separadas de la entrega original en docs/validation/case_001_ux; las anteriores no se sustituyen.

Resultados finales: **20 suites aprobadas**; 8176 aserciones de sistemas previos, 3285 del flujo original, 52 de validación, 108 nuevas de contexto y 1898 de GUI headless base: **13519 de referencia**. No se suman repeticiones por tamaño/captura como escenarios distintos. GUI headless 1898/1894 según proporción y gráfica 1968/1964; los setenta adicionales gráficos comprueban catorce capturas por ejecución. Bootstrap/navegación correctos en cuatro tamaños, con 222 nodos estables en navegación sin sesión. Importación salida 0, sin errores/advertencias de script.

**56 capturas reales** revisadas: [objetivo y opciones principales](../validation/case_001_ux/720x1280/contradiction.png), [pregunta, selección y confirmación fija](../validation/case_001_ux/720x1280/deduction_selection.png), [parte disponible tras recuperar](../validation/case_001_ux/720x1280/restored.png) y [lectura del fragmento](../validation/case_001_ux/720x1280/transcript.png). Son de escritorio, sin acreditación de Android físico. La prueba abre el selector y ejecuta su evento de selección; no se presenta como un toque físico en dispositivo.

Respecto a la entrega local anterior: 24 archivos existentes modificados y 61 nuevos (56 imágenes, dos scripts/UID y este documento), sin borrados. Las fuentes narrativas/configuración/datos conservan sus hashes. Se detectó y corrigió un foco diferido que intentaba continuar tras destruir la pantalla: los nuevos trabajos se ligan al Node con señales de un solo fotograma y las solicitudes repetidas se agrupan. Las ejecuciones finales cierran sin ese error.

Comandos reproducibles:

```powershell
$uxGodot = 'D:\Descargas\Exe\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe'
& $uxGodot --headless --path 'D:\Ultima Señal' --script res://tests/cases/case_001/test_case_guidance.gd
& $uxGodot --headless --path 'D:\Ultima Señal' --script res://tests/cases/case_001/test_case_flow.gd
& $uxGodot --headless --path 'D:\Ultima Señal' --script res://tests/cases/case_001/test_case_integrations.gd -- 720x1280
& $uxGodot --path 'D:\Ultima Señal' --script res://tests/cases/case_001/test_case_integrations.gd -- 720x1280 'D:/Ultima Señal/docs/validation/case_001_ux/720x1280'
```

Repetir GUI en 1080x1920, 1080x2400 y 720x1600. Las pruebas escriben partidas solo en user://save_tests. Los avisos y selecciones son temporales; restaurar no inventa descubrimientos nuevos.

## Límites

Revisión visual y recorridos automatizados de escritorio no demuestran que toda persona comprenda el caso o que dure 8–15 minutos. La mejora debe contrastarse con una partida del usuario. Pendientes Android físico, tacto/lector de pantalla y rendimiento móvil. Las grabaciones oficiales siguen pendientes de producción; no se ha implementado 09B. No hay puntuación definitiva, otros casos, instalaciones, commits o pushes. La revisión se detiene aquí.
