# PROMPT 11R — Resultado de la reestructuración

2026-10-29 · Base ca0d75f · Godot 4.7.2 estable · Windows / Compatibility.

**Estado:** reestructuración implementada y comprobada funcionalmente en escritorio. Evaluación humana, duración real, Android físico y producción sonora oficial pendientes. No se afirma que la diversión o la comprensión espontánea estén demostradas.

## 1. Diagnóstico y respuesta al problema original

El problema no era únicamente ausencia de instrucciones. La experiencia exponía cuatro aplicaciones paralelas, pedía localizar fuentes y controles, mantenía decisiones administrativas y hacía expresar el razonamiento como un conjunto exacto de fichas. Añadir otra indicación no cambiaba esa actividad.

11R sustituye el recorrido oficial por una superficie de comunicación: **llamada → consulta pertinente → descubrimiento/conclusión → llamada**. Desaparecen las cuatro pestañas de campaña, la selección de fichas obligatoria para deducir y los filtros sin utilidad perceptible en audio textual. Registros queda como consulta voluntaria.

La investigación y las decisiones permanecen. Se elimina la necesidad de administrar sus componentes internos, no la interpretación del caso.

## 2. Qué ve y hace alguien que comienza

Nueva partida abre la línea dos entrante, la intervención de Elena y un único botón principal **Atender la línea dos**. No aparecen herramientas bloqueadas. Al atender, Clara pide ayuda y hay dos respuestas de tono diferente, con sus efectos originales.

Después de identificar hotel, habitación y situación, **Verificar establecimiento** lleva a la ficha municipal directamente. Los pasos intermedios de comprobar/consultar/abrir se ejecutan como una consulta agrupada; sus textos y comandos se conservan en el historial. La ficha se registra automáticamente al descubrirse, como ya establecía el motor.

El siguiente gesto es **Examinar contradicción**. Aparecen el testimonio y la clausura, seguidos por dos conclusiones. El jugador interpreta lo que esas fuentes permiten sostener. Una acusación sin fundamento recibe una explicación; no pierde pruebas ni avanza la emergencia. No necesita adivinar cuáles tarjetas seleccionar.

Tras esa conclusión aparecen acciones pertinentes: preparar inspección y consultar el registro de los golpes. La inspección se elige y confirma sin abrir un mapa obligatorio. El registro abre el fragmento pertinente; Examinar muestra la transcripción y registra la observación mediante el servicio existente. También es posible obtener esa información preguntando a Clara desde las consultas voluntarias.

El parte exterior aporta información nueva y vuelve a la conversación de Inés. Q01 y E06 habilitan la pregunta de fecha. El recibo y la consola mantienen su contradicción aprobada. Al preparar una instrucción se presenta la petición de Clara junto a las alternativas; no hace falta confirmar otro traspaso de pantalla.

La advertencia del pasillo, la confirmación de transmisión y la posibilidad de corregir siguen presentes. Las consecuencias se leen en los tres cierres básicos existentes.

## 3. Orientación, tutorial y exploración

| Momento reconocido en el estado | Presentación introducida |
| --- | --- |
| Línea entrante | Atender, sin herramientas competidoras |
| Comunicación conectada / N03 | Dos tonos de respuesta y explicación breve de su efecto interpersonal |
| Hotel identificado / N05 | Verificar establecimiento y propósito del registro |
| E02 obtenida | Registros: fuentes conocidas, sin colección de huecos |
| Paso a investigación / N17 | Primera pregunta de razonamiento con dos fuentes |
| Q01 confirmada | Inspección y registro de línea; cada consulta enseña su propia acción |
| Unidad asignada y E06 pendiente | Recibir parte de R1 como acción contextual, también al continuar |
| Revelación de fecha / etapa E | Preparar, revisar, corregir y transmitir instrucción |

Los desbloqueos se proyectan de evidencia, acciones, visitas y etapa ya guardadas. Las visitas se usan para respetar herramientas que una partida anterior ya había abierto; nunca se cuenta cuántas pestañas abrió el jugador para premiarlo o bloquearlo.

Las instrucciones son breves y locales. Se consideran vistas tras una interacción pertinente, se guardan por SaveManager y pueden releerse en Ayuda. No hay ventana obligatoria de «Entendido», interrupción por leer despacio, penalización de ayuda o bloqueo de finales.

La ayuda tiene tres niveles: objetivo, orientación y acción concreta. Se amplía voluntariamente. El objetivo narrativo queda debajo de la conversación; las consultas presentan su propia tarea, sin una instrucción de otra herramienta encima.

Registros ofrece primero fuentes pertinentes, después expediente completo, conclusiones e historial. Las fuentes desconocidas permanecen ocultas. Plano, huéspedes, telefonía, consultas emocionales y otras conclusiones son voluntarios cuando corresponden. La exploración no cancela una instrucción preparada; cambiar el plan exige su corrección explícita. Retroceso cierra ayuda, historial o consulta antes de abandonar la atención; Retomar llamada ofrece regreso directo.

## 4. Cambios visuales y de navegación

Cabecera compacta con identidad de central, línea y Menú; contenido con un solo desplazamiento; Registros/Ayuda como accesos secundarios. Se retiran de la campaña la cabecera antigua, panel de guía grande, barra de selección y navegación de cuatro secciones.

Se conservan Theme, paleta verde petróleo/ámbar, tipografía base, identidad de 1998 y botones de al menos 88 unidades lógicas. No se ha reducido todo el texto para introducir más controles. Las fuentes de la primera deducción muestran título y descripción; su procedencia completa está en Registros. En las capturas base caben las fuentes y ambas respuestas; consultas más extensas permiten desplazarse.

La prueba verifica que el área principal ocupe al menos el 65 % de la altura lógica en los cuatro tamaños. Esto es una comprobación geométrica, no acreditación de ergonomía en teléfono.

Las actividades siguen cambiando entre conversación, lectura, interpretación e inspección. No se presenta la ausencia de pestañas como si se hubieran eliminado todas esas actividades: se eliminan localización y selección administrativa innecesarias.

## 5. Conversaciones, evidencias y deducciones

La [auditoría](CASE_001_ACTION_AUDIT.md) clasifica individualmente los 38 diálogos y las 57 opciones. **No se borró ni renombró ningún identificador canónico.**

Fusiones de presentación concretas:

- N05→N06→N07→N08: una verificación, conservando el registro final y los comandos normales.
- N08→N10→N17: Examinar contradicción sustituye la confirmación de archivar y la búsqueda de la herramienta.
- N22→N23→N24: un acceso a preparar instrucción; la petición de Clara se muestra junto a las alternativas.
- N02 y N09 dejan de competir como ramales del recorrido principal; ayuda/contexto conservan sus principios y las partidas antiguas siguen siendo restaurables.
- El cuestionario N10 se presenta como acciones pertinentes; consultas secundarias pasan a Registros. No se ejecutan automáticamente calma, tono, plan o riesgo.

Las diez evidencias conservan sus condiciones y procedencias. No hay confirmación nueva para archivarlas. E03 mantiene alternativa entre testimonio y transcripción, E04 entre plano y parte posterior, y las fuentes opcionales siguen sin ser requisitos universales de cierre.

DeductionManager valida las nuevas preguntas. Q01 enseña a contrastar las fuentes. Q02 interpreta el peligro con tres fuentes presentadas; Q03/Q04 permiten contrastar afirmaciones documentales sin resolver el misterio. Una conclusión correcta usa la confirmación existente y se conserva en executed_actions. Una incorrecta explica su insuficiencia sin revelar inmediatamente la alternativa correcta. Repetir una confirmada no repite efectos. No se han inventado equivalencias de fichas ni otro motor de deducción.

## 6. Audio y despacho

Audio provisional: acción contextual → Examinar fragmento → transcripción/observación → Retomar llamada. No se exigen escoger grabación, segmento y filtro para consultar G01.S02. Otros fragmentos se consultan voluntariamente. El analizador, su único reproductor y la demo 09A se conservan. Las grabaciones oficiales siguen pendientes; no hay audio ficticio, voces, TTS o implementación de 09B.

Inspección: acción contextual → elegir acceso → confirmar → recibir parte cuando esté disponible. R1 se selecciona internamente porque no hay alternativa de unidad. El plano es opcional. Cancelar es puro; reubicar también requiere confirmación. Se mantienen validación de disponibilidad/revisión, partes atómicos y ausencia de duplicados. Un plan preparado no se corrige al abrir herramientas.

## 7. Qué se simplificó realmente

La [comparativa completa](CASE_001_BEFORE_AFTER.md) define puntos de partida y convención de conteo.

| Procedimiento | Antes | 11R |
| --- | --- | --- |
| N05 hasta ficha visible | 3 activaciones | 1 |
| Ficha hasta Q01 confirmada y regreso | 8 | 3 |
| Q02 con fuentes disponibles y regreso | 8 | 3 |
| Registro de golpes pertinente y regreso | 6 | 3 |
| Elegir acceso y confirmar, consulta abierta | 2 | 2 |
| N22 hasta preparar instrucción | 2 | 1 |

No se atribuye otra reducción al despacho de dos pasos que ya existía. Sí cambia su acceso, su presentación y la necesidad de abrir el mapa.

Los recorridos gráficos guardan trazas de ratón: A 50 activaciones, B 23 y C 24 en la ejecución de referencia. A incluye errores, pistas, cancelación, restauración y exploración deliberada de QA; B/C reconocen la sustitución de partida por señal de diálogo. Son trazas de prueba reproducibles, no mínimos, medidas de rapidez o primeras partidas humanas. El número de pantallas antiguas depende del orden elegido; la comparativa explicita una ruta A de seis transiciones de sección y distingue esas actividades de sus accesos administrativos.

## 8. Arquitectura definitiva y guardados

CaseFlowDirector proyecta `experience.json`. CaseExperience muestra la campaña y solicita acciones a CallController, DeductionManager, AudioAnalysisManager y DispatchManager existentes. DispatchConsole conserva los paneles para demos. No hay otro motor narrativo, inventario, reproductor, guardado, autoload o dependencia externa.

Las consultas agrupadas se procesan en un candidato aislado, revalidando cada opción; error o revisión obsoleta descarta todo el grupo. Una publicación estable entrega el resultado. El diario normal permite reconstruir exactamente las visitas y efectos.

Se conserva byte por byte case_001.json y voice_inventory.json, además de historia, Theme y project.godot. Las partidas anteriores de ca0d75f conservan su fingerprint y se restauran sin migración narrativa.

SaveManager admite su envoltura base de ocho campos y una extensión opcional `presentation` v1 para ocho tutoriales conocidos como máximo. Comparte dirty, escritura verificada, respaldo, bloqueo y ranura. Campos o versiones de presentación inválidos se rechazan conservando archivos. El nuevo lector acepta archivos viejos; un ejecutable viejo puede rechazar los nuevos campos sin borrarlos. No se promete lectura por binarios anteriores.

Pruebas bajo user://save_tests exclusivamente. Se preservó una copia de los datos canónicos y del gestor anterior en TEMP antes de implementar. Los informes locales preexistentes se conservaron.

## 9. Tres desenlaces preservados

| Resultado | Condición conservada | Límite narrativo |
| --- | --- | --- |
| A — Salida comunicada | Servicio, Q02, patio verificado, confianza ≥1 y estrés ≤1 | Clara comunica alivio/salida; R1 no confirma contacto físico |
| B — Refugio sin confirmación | Resto de transmisiones válidas | No se certifica evacuación |
| C — Contacto perdido en riesgo | Pasillo, confianza 0 y estrés 2 | No se confirma muerte |

Q01 y E06 habilitan el contraste temporal. Servicio sin patio preparado no permite resolver. Q03/Q04 no cambian el resultado. La guía no elige el plan ni garantiza A. Los tres siguen hacia N36/N37 con cierre básico, sin la puntuación o pantalla definitiva de 12.

Diez rutas de lógica anteriores y tres rutas reales de interfaz nuevas alcanzan los cierres. La ruta A de interfaz usa el fragmento textual como fuente; B/C demuestran que no se obliga a completar toda la investigación.

## 10. Validación realizada

**21 suites funcionales aprobadas**, 13 009 aserciones de referencia: 8172 de sistemas anteriores, 3285 de flujo del caso, 52 de validación, 108 de contexto anterior, 98 de rediseño y 1294 de interfaz nueva. No se suman repeticiones por resolución ni la entrada de compatibilidad como suites distintas.

| Ventana | GUI headless | GUI gráfica | Capturas finales |
| --- | --- | --- | --- |
| 720×1280 | 1294, PASS | 1404, PASS | 21 |
| 1080×1920 | 1294, PASS | 1404, PASS | 21 |
| 1080×2400 | 1290, PASS | 1400, PASS | 21 |
| 720×1600 | 1290, PASS | 1400, PASS | 21 |

Variación de recuentos por controles visibles y comprobaciones gráficas; no representa diferentes cantidades de historia. Bootstrap/navegación de demos también pasan en cuatro tamaños. Importación final: salida 0, sin errores o advertencias de script.

Se verifican inicio, desbloqueos, ficha directa, razonamiento correcto/incorrecto/incompleto y obsoleto, Q01–Q04, ayudas puras, partes, cancelación, confirmación, plan preparado/corrección, historial, archivo, continuación fría, tutoriales vistos, archivos anteriores y metadatos inválidos. Fallo de escritura intencional visible y reintento correcto. Los diagnósticos de archivos corruptos/E/S de fixtures son rechazos esperados.

La reproducción real de la demo 09A pasó sus 11 aserciones con WASAPI en ejecución aislada. Un primer intento simultáneo falló el umbral de avance inicial; se registra como incidencia observada, sin atribuir causalidad no medida ni relajar la prueba. No equivale a escucha humana o audio oficial del caso.

**84 PNG reales** con dimensiones comprobadas; revisados mediante cuatro hojas de contacto y muestras a tamaño completo. Incluyen llamada, ficha, razonamiento/error, ayuda, transcripción, confirmación, continuación, mapa opcional, archivo, historial, plan, advertencia, A/B/C y error de guardado. [Resumen portable](../validation/prompt_11r/validation_summary.json).

Muestras: [primera deducción](../validation/prompt_11r/720x1280/first_deduction.png), [continuación contextual](../validation/prompt_11r/720x1280/continued.png), [inspección](../validation/prompt_11r/720x1280/dispatch_confirmation.png), [decisión](../validation/prompt_11r/720x1280/critical.png).

## 11. Archivos y decisiones

| Grupo | Archivos |
| --- | --- |
| Nueva presentación | experience.json, case_flow_director.gd/UID, case_experience.gd/UID, case_experience.tscn |
| Integración modificada | dispatch_console.gd, navigation_controller.gd, call_controller.gd, narrative_engine.gd, deduction_manager.gd, save_manager.gd |
| Pruebas | test_case_redesign.gd/UID y test_case_experience.gd/UID nuevos; test_case_integrations.gd ahora entrada a la GUI vigente |
| Documentos nuevos | Este informe, plan, auditoría, comparativa, playtest y CASE_FLOW_EXPERIENCE.md |
| Seguimiento actualizado | AGENTS, GDD, ROADMAP, PROGRESS, DECISIONS, UI_NAVIGATION, contratos de narrativa/llamadas/investigación/audio/mapa/guardado y referencia de la corrección UX anterior |
| Evidencia de verificación | prompt_11r: 84 PNG, cuatro trazas de interfaz y validation_summary.json |

Decisiones D-072–D-076 registran autorización, presentación, razonamiento, extensión de guardado y separación entre prueba técnica y aceptación humana. La auditoría no detectó una ambigüedad narrativa esencial que exigiera inventar un acontecimiento nuevo. El supuesto es que 11R debe simplificar el caso oficial manteniendo sus consecuencias, no sustituir sus sistemas genéricos.

## 12. Pendientes y cierre

Se entrega [protocolo de playtest](CASE_001_PLAYTEST_PLAN.md), pendiente de ejecución con personas nuevas. Faltan duración real, comprensión espontánea, aburrimiento/satisfacción, Android físico, gestos, accesibilidad y rendimiento móvil. Audio oficial permanece pendiente. No se declara la experiencia «divertida» por sumar aserciones.

Persisten lectura y alternancia de actividades porque forman parte de investigar; su ritmo deberá contrastarse con personas. Archivo e historial pueden ser extensos por elección. El resultado favorable continúa exigiendo decisiones, no completar el tutorial.

**11R termina aquí con implementación funcional verificada y los límites anteriores declarados. Sin commits/pushes, APK, instalaciones, otros casos ni inicio de 09B, 12 o 13.**
