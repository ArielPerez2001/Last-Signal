# PROMPT 11R — Plan de reestructuración

2026-10-29. Autorización: PROMPT 11R. Base ca0d75f y reporte de jugabilidad posterior, conservando los dos informes locales preexistentes. Sustituye para esta tarea la restricción de la corrección anterior de conservar la presentación y navegación; no autoriza 09B, 12, 13 ni publicación.

## Auditoría y recorrido actual

La partida oficial expone cuatro módulos con un objetivo superior, avisos y barra de acciones. Atender → respuesta emocional → identificación → descripción del peligro → comprobar → confirmar consulta → abrir ficha → confirmar archivo → investigación. Desde allí se alternan pestañas para escoger hipótesis, fichas exactas, grabación/segmento/filtro o acceso/confirmación/parte. El avance exige Q01 + E06; el cierre favorable requiere además Q02 y las condiciones operativas/emocionales ya aprobadas.

Obligatorio para cualquier cierre: responder, identificar, leer registro, reconocer contradicción Q01, recibir al menos un parte E06, contrastar fecha, preparar y transmitir un plan, leer cierre. La elección de tono, respuesta a la fecha, recuperación emocional, destino, reubicación, plan y confirmación de riesgo tienen consecuencias. Q02 influye en A; Q03/Q04, huéspedes, telefonía y la consulta de todas las grabaciones son opcionales. E03 tiene alternativa por testimonio o transcripción; E04 por plano o parte posterior; no se impone una única ruta a esos datos.

Los retornos de documentos, archivo de ficha ya obtenida, selección de una única unidad y elección de filtros sin audio aportan operaciones administrativas. No eliminar una pregunta porque sea larga: conservar información de peligro, precauciones, emociones y decisiones de desenlace.

## Recorrido propuesto

Una superficie de comunicación: llamada → consulta contextual en la misma superficie → resultado visible → retomar llamada. Sin barra de cuatro pestañas oficial. Cabecera de una línea, texto vigente, objetivo narrativo breve debajo, acciones relevantes y acceso secundario a Registros/Ayuda. Un solo desplazamiento para contenido y controles; nada de paneles gigantes ni confirmaciones separadas al pie.

1. Atender es la única acción principal inicial.
2. Dos respuestas conservan sus consecuencias emocionales.
3. Verificar establecimiento abre directamente la ficha, agrupando consultas redundantes N05→N06→N07→N08. Los comandos originales se ejecutan en candidato atómico y se conservan en historial; no se eliminan IDs.
4. Tras leer la ficha, Examinar contradicción abre Q01 con dos fuentes conocidas y dos conclusiones. DeductionManager valida el razonamiento y usa la confirmación existente.
5. La inspección aparece después de reconocer la contradicción. Acceso → confirmar, una unidad implícita y partes explícitos sin reloj real. No hay mapa obligatorio.
6. Sonidos/plano permiten investigar el peligro; audio textual abre el fragmento pertinente sin selectores técnicos. Q02 permanece una decisión de interpretación, no un premio del tutorial.
7. La fecha desbloquea la decisión crítica. Se agrupan N22→N23→N24 en el acceso a preparar instrucción, conservando la petición de Clara en la presentación. Se mantiene corrección y advertencia del pasillo.
8. Los tres cierres conservan sus textos y significado; no se añade puntuación de 12.

Registros permite releer las fuentes descubiertas y el historial, consultar documentos secundarios, estudiar otras conclusiones y revisar herramientas ya introducidas. No muestra evidencias ocultas ni contador de colección. Desde un plan preparado, explorar no cancela el plan; volver a investigar se realiza por su elección explícita existente.

## Arquitectura y persistencia

CaseFlowDirector proyecta configuración JSON de presentación, objetivos, ayudas, herramientas y acciones a partir del mismo motor. No escribe efectos ni escoge respuestas. La UI envía intención a CallController, DeductionManager, AudioAnalysisManager y DispatchManager. Los comandos agrupados usan las opciones reales y publican un único resultado estable; si una opción falla se revierte el grupo completo.

Los datos narrativos y fingerprint se conservan; no hace falta migrar una partida de ca0d75f. SaveManager admite una extensión opcional versionada de presentación con tutoriales vistos. Archivos anteriores sin extensión equivalen a ningún tutorial visto; al continuar un caso avanzado no se presenta una introducción fuera de contexto. Sin nuevos archivos de guardado ni otro servicio. Las versiones antiguas del ejecutable rechazarán campos nuevos conservadoramente; no se promete compatibilidad hacia atrás del binario.

Tutoriales breves se muestran en la primera interacción pertinente y se completan con una acción útil, sin modal obligatorio de aceptación. Ayuda voluntaria de objetivo, orientación y acción explícita, sin penalización ni respuesta favorable automática. Desbloqueos derivados de evidencia, acciones y etapa ya persistidas, nunca del tiempo o número de pantallas visitadas.

## Continuidad y cambios narrativos

[Auditoría individual de los 38 diálogos y 57 opciones](CASE_001_ACTION_AUDIT.md). Ningún identificador o condición canónica cambia; las fusiones de presentación se enumeran allí y en la comparativa.

Se mantienen los 38 diálogos, 57 opciones y condiciones A/B/C. Se fusiona su presentación administrativa, no sus decisiones. Los textos de ayuda y rótulos nuevos no añaden hechos a 1981/1998, no certifican rescate/muerte ni explican ECO. R1 continúa siendo rescate exterior. Voz/audio oficial siguen pendientes; el analizador 09A y las demos permanecen disponibles.

Riesgos: ocultar la corrección emocional, volver obligatorio Q02, mostrar secretos en tarjetas o ayuda, procesar una decisión al abrir herramientas, perder un contexto antiguo al continuar y cambiar inadvertidamente el fingerprint. Se verifican explícitamente. La matriz de clasificación de nodos/opciones se adjunta durante la auditoría; no se borra contenido por cantidad.

## Validación y aceptación

Pruebas de nueva partida, registro directo, razonamiento correcto/incorrecto/incompleto, revisión obsoleta, ayudas puras, tutoriales persistentes, restauración antigua/nueva, rollback del grupo, despachos válidos/inválidos/repetidos, partes y finales A/B/C. Mantener regresiones funcionales de sistemas y actualizar únicamente expectativas de UI sustituidas por el nuevo recorrido.

GUI y capturas gráficas en 720×1280, 1080×1920, 1080×2400 y 720×1600: cabecera, texto, acciones, registros, ayuda, errores, despacho, deducciones y reanudación. Medir operaciones de recorridos concretos; no inventar tiempos o satisfacción. Entregar comparación, protocolo de playtest e informe final. Android físico y evaluación humana se declaran pendientes si no se realizan. Continuar con implementación dentro de este prompt y detenerse al cerrar 11R.
