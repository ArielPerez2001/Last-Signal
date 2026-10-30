# Jugabilidad actual — Caso 001: La habitación 304

Fecha: 29 de octubre de 2026. Base revisada: commit `ca0d75f`, integración de PROMPT 11 y corrección UX posterior. Informe solicitado a raíz de: «Resulta un poco tedioso jugar, hay demasiadas cosas y no se indica nada».

## 1. Dictamen

El caso permite empezar, investigar, tomar decisiones, guardar y llegar a tres cierres. La revisión posterior mejora la orientación y elimina operaciones redundantes. Sin embargo, **el problema de tedio está mitigado; todavía no está demostrado que esté resuelto para el jugador**.

La corrección intervino principalmente en cómo se presenta y recorre el juego. Conservó sus textos, reglas, pruebas necesarias y decisiones. Por eso hay menos fricción para usarlo, pero la actividad sigue siendo leer, consultar distintas herramientas, relacionar fuentes y regresar a la conversación. Si esa alternancia era parte central del cansancio, puede seguir presente.

La distinción es relevante: poder terminar el caso acredita funcionamiento; comprender el siguiente paso y querer continuar requiere observar una partida humana.

## 2. Alcance y método

Se revisaron el código de orientación y de los cuatro paneles, los datos oficiales, el diseño, los informes de implementación/UX, el progreso y las decisiones D-068–D-071. Se inspeccionaron de nuevo cuatro capturas existentes de 720 × 1280: investigación inicial, selección de evidencias, mapa y transcripción. Son evidencia de la versión entregada, no capturas de una sesión humana nueva.

Se repitieron las pruebas automatizadas de orientación/contexto y de flujo del caso; sus resultados finales se consignan en la sección de validación. Las otras pruebas y las capturas en cuatro resoluciones se citan como verificaciones previas documentadas. No se volvieron a ejecutar todas en esta revisión.

Este informe distingue tres tipos de afirmación:

- **Comprobado:** comportamiento presente en código/datos, captura o prueba ejecutada.
- **Evaluación:** interpretación de su posible efecto sobre comodidad, claridad o ritmo.
- **Pendiente:** algo que necesita medición con jugadores o dispositivo.

No se asigna una nota numérica de diversión o usabilidad porque no existe una medición que la sostenga. El informe evita detallar la combinación ganadora de pruebas y decisiones.

## 3. Qué se juega actualmente

El jugador opera una central de emergencias en Puerto Umbral, en 1998. Una llamada desde la habitación 304 del Hotel Mirador entra en contradicción con los registros del establecimiento. La tarea consiste en entender esa contradicción, contrastar fuentes, orientar una inspección exterior y decidir qué comunicar a la interlocutora.

| Elemento | Contenido actual | Implicación para jugar |
| --- | --- | --- |
| Caso | Un caso integrado | Hay un recorrido completo delimitado |
| Conversación | 38 nodos de diálogo y 57 opciones | Son el total entre rutas; una partida no exige leerlos todos |
| Investigación | Diez evidencias y cuatro deducciones | No todo hallazgo o conclusión es obligatorio para terminar |
| Grabaciones | Dos registros con cinco segmentos en total | En el caso oficial se examinan mediante texto; faltan los archivos sonoros |
| Operaciones | Dos accesos del mismo hotel y una unidad R1 | Se decide una inspección exterior; no se gestiona una ciudad completa |
| Consecuencias | Tres desenlaces básicos | Las decisiones sí afectan el cierre |
| Persistencia | Nueva partida, autoguardado y Continuar | Se puede interrumpir y retomar la investigación |

Las herramientas comparten la misma partida. Consultar una evidencia, recibir un parte o confirmar una deducción se refleja en la conversación cuando corresponde.

## 4. Recorrido desde la perspectiva del jugador

### Entrada y primera llamada

Se entra por **Nueva partida · Caso 001**. La introducción permite elegir **Atender la línea dos** directamente; ya no hay que responder una vez y después volver a confirmar que se atiende. Las herramientas quedan deshabilitadas durante la apertura, hasta completar el contexto inicial.

Esto limita la cantidad de funciones que el jugador tiene que aprender al empezar. Sigue siendo una introducción principalmente escrita: no hay una conversación oficial doblada que sostenga el ritmo por sí misma.

### Contradicción e investigación

Tras conocer el testimonio y el registro, se abre la investigación. La interfaz muestra un objetivo y, cuando procede, un acceso a la sección correspondiente. Por ejemplo, «Contrasta el testimonio» con «Revisar expediente».

En el recorrido cordial inicial, la conversación presenta dos consultas principales y agrupa otras siete en **Otras consultas**. Ese reparto cambia según el estado: una pregunta crítica recién habilitada o una intervención necesaria de calma puede aparecer entre las principales. Las 57 opciones continúan en el motor.

La reducción es de opciones expuestas simultáneamente, no una eliminación de contenido. La ventaja es que el jugador tiene un punto de partida. El riesgo es que todavía interprete las consultas secundarias como una lista que debe agotar.

### Expediente y deducciones

Se elige una pregunta, se consultan las fuentes reunidas y se seleccionan dos o tres evidencias. La pregunta activa, el número seleccionado y **Comprobar relación** permanecen al pie de la pantalla mientras se recorren las tarjetas.

La selección no se pierde por desplazarse. Una confirmación correcta limpia la selección temporal y enfoca la explicación. Los errores permiten corregir sin borrar evidencias ni avanzar la emergencia.

La comprobación exige el conjunto exacto definido para la hipótesis. Esto mantiene una solución coherente y verificable, pero introduce el mayor riesgo de atasco actual: alguien puede comprender una idea y no identificar qué fichas concretas espera el sistema. Los mensajes distinguen fuentes insuficientes o que no sostienen juntas la hipótesis, pero no equivalen a una explicación personalizada del razonamiento del jugador.

### Inspección exterior y partes

En Mapa se elige un acceso y se confirma el envío. R1 y el incidente se preseleccionan cuando solo existe una opción válida para ese destino. Cancelar no modifica el estado operativo.

El procedimiento principal pasa de seleccionar ubicación, incidente y unidad, revisar y confirmar, a **elegir acceso → confirmar**. Esta comparación excluye abrir pestañas, desplazarse, leer y recibir posteriormente el parte; no es el número total de gestos de la operación.

Los partes pueden recibirse desde los contextos compatibles aunque se haya entrado en Mapa por su pestaña. Se elimina así la dependencia de recordar una ruta concreta de pantallas. Un plan ya preparado sigue requiriendo corrección explícita: navegar no lo cancela ni lo transmite.

### Consulta de grabaciones

La pestaña Audio conserva registros y segmentos, pero las dos grabaciones oficiales todavía no tienen archivos con habla. Se selecciona un fragmento y una variante y se pulsa **Leer fragmento**. Esa acción muestra el texto y registra la observación correspondiente cuando procede.

Se retiraron el transporte inactivo y la segunda acción redundante de registro. Abrir Audio o seleccionar un fragmento no concede por sí solo una evidencia.

El recorrido es funcional y accesible en silencio. Su limitación de experiencia es importante: una herramienta que debería variar la actividad y aportar tensión sonora continúa requiriendo lectura. No debe confundirse la demo técnica de reproducción de audio con la producción sonora del caso oficial.

### Decisión y cierre

El jugador vuelve a la llamada, contrasta nueva información y prepara una instrucción. Puede revisar pruebas y corregir el plan antes de transmitirlo. La orientación indica qué tarea está pendiente sin escoger el destino o la respuesta por él.

Las decisiones, las conclusiones relevantes, la cooperación y el estado de la inspección intervienen en el resultado. Hay tres cierres básicos: salida comunicada, refugio sin confirmación y contacto perdido en riesgo. Las fuentes permanecen consultables al terminar, con nuevas operaciones bloqueadas.

La presentación de cierre existe, pero no incluye la evaluación definitiva prevista para PROMPT 12. La sensación de recompensa o de comprender por completo el propio desempeño todavía puede resultar limitada.

## 5. Qué cambió respecto a la queja

| Dificultad detectada | Comportamiento actual comprobado | Evaluación |
| --- | --- | --- |
| Demasiadas opciones con igual peso | Consultas principales y secundarias desplegables | Baja la carga inicial; no desaparece la cantidad total |
| No saber a dónde ir | Objetivo contextual y acceso a la herramienta pertinente | Ofrece dirección; no explica por completo una deducción difícil |
| No advertir avances | Avisos de evidencia, deducción y respuesta nueva; marcas NUEVO | Hace más visible la relación entre acción y avance |
| Volver mediante varios pasos | Retomar llamada fijo en herramientas | Reduce navegación de regreso |
| Perder la posición | Desplazamiento independiente por pestaña | Facilita alternar sin buscar otra vez el punto de lectura |
| Confirmación lejos de las fichas | Selección y confirmación al pie | Evita recorrer la lista para comprobar una relación |
| Selección operativa repetitiva | Acceso y confirmación con opciones únicas preseleccionadas | Elimina elecciones sin alternativa real |
| Mismo mapa con distinta disponibilidad según entrada | Partes coherentes desde contextos compatibles | Reduce la necesidad de adivinar cómo navegar |
| Audio pendiente con controles inútiles | Consulta textual explícita única | Aclara qué se puede hacer; no aporta todavía variedad auditiva |

**Resultado:** se atendió la falta de indicaciones y parte de la sobrecarga operativa. No se cambió la estructura de lectura e investigación ni se ha acreditado una reducción de tedio mediante observación humana.

## 6. Fricciones que todavía pueden explicar el cansancio

### A. Predominio de lectura — prioridad alta de evaluación

Conversaciones, documentos, transcripciones, partes y conclusiones requieren leer. Aunque cambie la pestaña, la actividad física y mental puede sentirse parecida. La ausencia de las grabaciones oficiales reduce una fuente prevista de contraste y ambientación.

Es una evaluación del diseño actual, no una medición de aburrimiento. Tampoco significa que el texto deba sustituirse o recortarse sin aprobación editorial.

### B. Relacionar fichas puede sentirse como encontrar la combinación esperada — prioridad alta

El sistema valida fuentes exactas. La confirmación fija facilita operarlo, pero no garantiza que el razonamiento que exige sea evidente. Un atasco aquí puede convertirse en selección, rechazo y repetición.

Conviene observar especialmente la primera deducción: si el jugador sabe qué quiere demostrar pero no consigue expresarlo con las fichas, la dificultad está en la interacción o la explicación; si no entiende la contradicción, puede estar en la presentación narrativa. Las intervenciones posibles serían distintas.

### C. La orientación general puede competir con la intención local — prioridad media

El objetivo sigue prioridades de progreso. Si el jugador abre Mapa voluntariamente mientras aún falta una deducción, puede ver «Contrasta el testimonio / Revisar expediente» encima de las instrucciones de inspección.

Esto está presente en la captura revisada. No es un bloqueo: permite explorar. Sin embargo, puede suscitar la duda de si está usando una herramienta equivocada. La guía actual orienta el avance global y no siempre describe la acción local en curso.

### D. Mucho espacio fijo y tarjetas grandes — prioridad media

La cabecera, el objetivo, los avisos, la barra de acciones y las pestañas se mantienen accesibles. En la captura de deducción de 720 × 1280, estas zonas ocupan aproximadamente la mitad de la altura total. Las tarjetas restantes requieren desplazamiento.

En la captura de conversación ocurre algo diferente: al agrupar opciones queda un espacio vacío amplio antes de Otras consultas. Por tanto, el uso del espacio varía entre paneles; no basta con afirmar que toda la interfaz está compactada. Las dimensiones táctiles grandes favorecen la pulsación, pero reducen la información visible simultáneamente.

### E. Cuatro pestañas y memoria de trabajo — prioridad media

Se conserva el ciclo de investigar en una sección y aplicar lo aprendido en otra. El retorno y el scroll preservado reducen su coste, pero aún hay que recordar lo leído, la pregunta activa y la relación con la llamada.

No se ha medido cuántos cambios de pestaña realiza un jugador nuevo ni cuántos son necesarios frente a exploración voluntaria.

### F. Cierre básico — prioridad posterior

El caso ofrece consecuencias, pero la presentación final y la evaluación del desempeño todavía no están desarrolladas en su fase definitiva. Esto puede limitar la satisfacción al terminar, aunque no explica por sí solo un atasco temprano.

## 7. Ritmo, presión y libertad

No hay una cuenta regresiva global. Cambiar pestañas, revisar fuentes, leer despacio o equivocarse al relacionar evidencias no consume tiempo narrativo. La inspección progresa mediante acciones y partes discretos, no por esperar minutos reales.

Esto permite investigar con calma. También hace depender la tensión de la escritura, de las decisiones significativas y de su presentación. Sin producción sonora oficial y sin medición humana, no puede asegurarse que ese ritmo ya produzca el suspenso buscado.

No es necesario agotar todas las consultas o completar las cuatro deducciones para llegar a un cierre. Las fuentes opcionales amplían el misterio. Aun así, la presencia de opciones y fichas puede transmitir una expectativa de completitud a ciertos jugadores; habría que comprobar si distinguen qué es ampliación voluntaria y qué está bloqueando su avance.

La duración de 8–15 minutos es un objetivo de diseño. No existe una medición de primera partida que permita presentarla como duración real.

## 8. Validación y límites de la evidencia

La entrega UX documenta 20 suites aprobadas y 13 519 aserciones de referencia, además de 56 capturas gráficas en cuatro tamaños: 720 × 1280, 1080 × 1920, 1080 × 2400 y 720 × 1600. Son resultados anteriores registrados en [la revisión UX](CASE_001_UX_REVIEW.md) y [PROGRESS](../PROGRESS.md). Las repeticiones por tamaño no se consideran partidas o escenarios humanos diferentes.

La cobertura de flujo anterior incluye diez rutas, los tres desenlaces y, entre todas las rutas, los 38 diálogos, las 57 opciones y las diez evidencias. No demuestra todas las secuencias posibles de exploración.

Comprobaciones repetidas para este informe:

- Orientación/contexto: `test_case_guidance.gd`, 108 aserciones aprobadas.
- Flujo: `test_case_flow.gd`, diez rutas aprobadas hacia A/B/C y 3285 aserciones aprobadas. Total repetido para este informe: 3393 aserciones; no se suma de nuevo a las verificaciones históricas como cobertura adicional.

Estas comprobaciones sirven para acreditar progresión, coherencia de partes, conservación de decisiones y recuperación del estado. No miden diversión, comprensión espontánea, cansancio o satisfacción.

Continúan pendientes la partida observada con jugadores, la duración real, Android físico, tacto/gestos, legibilidad en densidad real, accesibilidad móvil y rendimiento. No se generó APK ni se realizó una nueva prueba auditiva oficial.

## 9. Cómo comprobar si se resolvió el problema original

La siguiente evaluación útil sería una primera partida observada, sin explicar la ruta ni proporcionar combinaciones. Este apartado propone una comprobación; no comunica resultados de una sesión ya realizada.

| Momento | Qué observar | Qué permitiría distinguir |
| --- | --- | --- |
| Tras la introducción | Si puede expresar la tarea inmediata | Claridad inicial |
| Primera contradicción | Si encuentra el expediente usando la guía | Orientación efectiva |
| Primera deducción | Selecciones, mensajes recibidos y necesidad de ayuda | Razonamiento frente a ensayo repetitivo |
| Envío de R1 | Si entiende acceso, confirmación y parte | Coherencia operativa |
| Consulta de fragmento | Si sabe qué examinar y detecta el nuevo hallazgo | Claridad del modo textual |
| Nueva respuesta | Si percibe el aviso y retoma la llamada | Visibilidad del avance |
| Instrucción final | Si entiende qué decide y puede revisar antes de transmitir | Decisión informada |
| Cierre | Si comprende las consecuencias y desea otra ruta | Recompensa y continuidad del interés |

Registrar duración, peticiones de ayuda, cambios de pestaña sin avance, intentos de deducción y puntos donde el jugador dice «¿y ahora qué?». Un toque más o menos no basta: interesa si la persona entiende por qué actúa.

Antes de modificar otra vez, conviene localizar el primer punto real de cansancio. Si está en la combinación de fichas, revisar sus explicaciones; si está en lectura y alternancia, evaluar ritmo y presentación; si está en encontrar acciones, revisar jerarquía local. Son líneas propuestas que pueden afectar producto o narrativa y requerirían delimitar una nueva autorización.

## 10. Consistencia documental encontrada

La cabecera de ROADMAP todavía describe el estado anterior a 11 y una frase histórica de PROGRESS mantiene 11 como pendiente. Sus apartados específicos de 11 y el estado actual de PROGRESS sí registran la integración y sus límites. UI_NAVIGATION señala expresamente que conserva descripciones históricas.

Para este informe se tomó como referencia el código y contenido del commit revisado, el estado actual y la revisión UX. La diferencia es de actualización documental; no demuestra ausencia de las funciones. Se registra aquí y no se reescriben los documentos de planificación dentro de este encargo.

## 11. Entrega y alcance

- Archivo creado: este informe, `docs/cases/CASE_001_GAMEPLAY_REPORT.md`. Se añade en PROGRESS el registro documental y las comprobaciones repetidas.
- Cambios en el juego: ninguno. No se modifica historia, interfaz, reglas, contenido o guardados oficiales.
- Decisiones nuevas de producto: ninguna. Se analizan las ya registradas en D-068–D-071; las prioridades anteriores son propuestas de evaluación.
- Supuesto de trabajo: la queja se refiere al Caso 001 oficial de la versión publicada, no a las demos de desarrollo.
- Duda abierta principal: en qué punto y por qué el jugador concreto sigue sintiendo tedio después de la corrección.
- Cierre: análisis y reporte únicamente. No se inicia 09B, 12 o 13; no se realizan commit, push o cambios remotos para este informe.

## Referencias locales

- [Revisión UX y límites](CASE_001_UX_REVIEW.md).
- [Implementación del Caso 001](CASE_001_IMPLEMENTATION_REPORT.md).
- [Diseño aprobado](CASE_001_DESIGN.md).
- [Progreso](../PROGRESS.md) y [decisiones](../DECISIONS.md).
- [Orientación contextual](../../scripts/ui/case_guidance.gd).
- [Servicio de deducciones](../../scripts/systems/deduction_manager.gd).
- [Captura: investigación](../validation/case_001_ux/720x1280/contradiction.png).
- [Captura: selección y confirmación](../validation/case_001_ux/720x1280/deduction_selection.png).
- [Captura: mapa y guía global](../validation/case_001_ux/720x1280/map.png).
- [Captura: transcripción](../validation/case_001_ux/720x1280/transcript.png).
