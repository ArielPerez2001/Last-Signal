# Caso 001 — Plan de pruebas narrativas y de estado

Versión 1.0 · 2026-10-27 · PROMPT 02. Fuentes: [diseño](CASE_001_DESIGN.md) y [especificación](CASE_001_TECHNICAL_SPEC.md).

## 1. Qué se verifica ahora y qué queda previsto

**Revisión documental de esta fase:** inventario y referencias; nodos y opciones; destinos y condiciones; trazas manuales de A/B/C; disponibilidad y recuperación de evidencias; exhaustividad de reglas y correspondencia cronológica. Las comprobaciones estáticas pueden usar comandos de lectura sobre Markdown, sin crear un simulador del juego.

**Pruebas previstas para fases de implementación:** ejecutar recorridos en Godot, validar datos funcionales, persistencia real, fallos de disco/audio, interfaz y tiempos de lectura. **Pruebas Android/dispositivo:** pendientes de las fases 15–17. Ningún resultado documental acredita estas pruebas.

Notación: una flecha entre nodos con salida única usa O01. Los saltos por panel se identifican con M/T o Q; se mantiene el ID del nodo hasta volver o recibir parte. Nueva partida siempre reinicia confianza 1, estrés 1, unidad disponible y conjuntos vacíos.

## 2. Matriz de rutas completas

### TR01 — Favorable, investigación con audio y patio directo

1. N01.O01 → N03.O01: confianza 2, estrés 0. N04 → N05 → N06 → N07.O01 → N08 → N10: E01/E02.
2. N10.O01 → N11 → N10: E04. N10.O03 → N13: T01 G01, T02 S02, T03 voz de fondo, T05 transcripción; obtiene E03; volver N10.
3. N10.O06 → N16: M02 patio, M04 recibir → N20 → N10: unidad patio_lista, E04/E06/E07.
4. N10.O07 → N17: confirmar Q01 con E01/E02 y Q02 con E03/E04/E06; volver N10.
5. N10.O09 → N21.O01 → N22 → N23 → N24: E08/E10, confianza 2, estrés 0, etapa E.
6. N24.O03 → N25.O01: servicio, Q02, patio_lista, cooperación suficiente. K02 selecciona A, unidad cerrada y comunicación cerrada.
7. N27 → N28 → N29 → N36 sin Q03 → N37 → END.

**Esperado documental:** A, «Salida comunicada»; sin rescate físico confirmado; no requiere E05, E09, Q03, Q04 ni N18. La pista N-4 se conserva. **Revisión de escritorio:** ruta válida por las tablas.

### TR02 — Favorable tras errores recuperados, sin oír audio

1. Misma entrada, pero N03.O02: confianza 0, estrés 2.
2. N11 obtiene E04; N12 obtiene E03 por conversación; M01/M03 → N19 obtiene E06 y deja R1 frente_lista.
3. En N17 intentar Q02 con E01/E04: retroalimentación incorrecta sin cambios. Confirmar Q01 con E01/E02 y Q02 con E03/E04/E06.
4. N10.O09 → N21.O02: confianza 0, estrés 2 saturados; N22 → N23 → N24.
5. N24.O01 → N10.O08 → N18.O01: confianza 1, estrés 0. Abrir N16, M05 reubicar y M04 recibir → N20: patio_lista y E07.
6. N10.O10 → N24.O03 → N25.O02 para cancelar; volver N24.O03 → N25.O01.
7. N27 → N28 → N29 → N36 → N37 → END.

**Esperado documental:** A; los errores de deducción, trato y primer destino se corrigen antes de transmitir; cancelar no consume K02. **Revisión:** válida; no reproduce ningún audio.

### TR03 — Parcial deliberado, ruta de investigación mínima

1. Entrada cordial hasta N10; confirmar Q01 con E01/E02.
2. M01/M03 → N19: E06 y frente_lista. No abrir audio, plano ni archivos opcionales.
3. Contrastar fecha → N21.O01 → N22 → N23 → N24.
4. N24.O02 refugio → N25.O01 → N30 → N31 → N32 → N36 → N37 → END.

**Esperado documental:** B; no hay bloqueo por omitir pruebas. Se conoce humo explícitamente por N21/N23/N24 antes de decidir, aunque no se haya clasificado E03. Evaluación identifica plan no evacuatorio, Q02 pendiente y acceso posterior no verificado. **Revisión:** válida.

### TR04 — Parcial con ruta preparada pero sin interpretación confirmada

1. Entrada cordial, E03 por N12, E04 por N11; unidad al patio con M02/M04; confirmar solo Q01.
2. N21.O01 y etapa E; elegir servicio sin confirmar Q02 y transmitir.
3. N30, variante servicio → N31 → N32 → N36 → N37 → END.

**Esperado documental:** B; sin Q02 la instrucción transmitida es genérica y no identifica una puerta; N30 expresa esa confusión. N25 advierte que falta precisar la ruta y permite volver a deducir. No se transmite el mismo texto preciso para después castigarlo por una marca interna. Evaluación identifica Q02 pendiente. **Revisión:** válida.

### TR05 — Parcial con mala cooperación

1. N03.O02, investigar E03/E04/E06/E07, confirmar Q01/Q02; N21.O02, sin usar N18.
2. Servicio preparado y transmitido con confianza 0, estrés 2.

**Esperado documental:** B, no C, porque no se pidió abrir al pasillo. Clara no logra completar la instrucción; se registra cooperación insuficiente. **Revisión:** válida; C no es un castigo automático por trato.

### TR06 — Adverso por acumulación de decisiones

1. N03.O02 lleva a confianza 0, estrés 2. Obtener E06 por frente y confirmar Q01.
2. N21.O02 mantiene confianza 0 y estrés 2. No usar N18.
3. N24.O04 → N26: advertencia visible. N26.O02 → N25, plan pasillo. N25.O01 ejecuta K02.
4. N33 → N34 → N35 → N36 → N37 → END.

**Esperado documental:** C; amenaza de humo comunicada antes de transmitir, apertura peligrosa y vínculo deteriorado; no confirma muerte ni expone R1 a derrumbe. **Revisión:** válida.

### TR07 — Misma última instrucción, distinto historial

Repetir TR06 con N03.O01 y N21.O01, manteniendo apertura al pasillo y sus dos confirmaciones. Confianza 2, estrés 0 al transmitir.

**Esperado documental:** B, variante de N30 en que Clara entreabre y vuelve atrás. Comparado con TR06 demuestra que C no depende solo del último botón. **Revisión:** válida.

### TR08 — Pista ampliada e identidad histórica

Agregar a TR01: consultar N14 y N15 antes de revelar (E05/E09); después de N22, volver a N10, confirmar Q03 E09/E10 y Q04 E01/E05/E08; consultar N38 y volver. Elegir servicio en cooperación suficiente.

**Esperado documental:** A sin cambiar su regla; N36 menciona Nadir y ECO, evaluación registra correspondencia histórica. Repetir agregados en TR03 y TR06 conserva B y C respectivamente. No se desbloquea otro caso. **Revisión:** condiciones compatibles; pistas opcionales no cambian resultado.

## 3. Pruebas de nodos y decisiones

| ID | Procedimiento | Resultado esperado | Estado en PROMPT 02 |
| --- | --- | --- | --- |
| GN01 | Extraer las cabeceras N01–N38 y los destinos de sus tablas | 38 ID únicos; toda opción tiene destino existente o END | Comprobación estática |
| GN02 | Revisar opciones condicionales de N10 | C ofrece contraste bloqueado con explicación; E ofrece volver a decisión; N38 exige Q04 | Revisado documentalmente |
| GN03 | Revisar entradas por eventos | N19/N20 son alcanzables desde N16; N27/N30/N33 por K02 | Revisado documentalmente |
| GN04 | Buscar nodos sin salida habilitada en estados válidos | Ninguno: paneles tienen Volver; N24 siempre ofrece refugio; N37 tiene END | Revisado documentalmente |
| GN05 | Recorrer N25.O02 y N26.O01 | Vuelven a N24 sin modificar emociones ni fijar resultado | Revisado documentalmente |
| GN06 | Abrir historial o volver al menú antes de resolver | Conserva cursor y progreso, no consume acciones críticas | Prueba de interfaz pendiente |
| GN07 | Intentar N38 antes de E08/Q04 | No aparece; no puede filtrar la fecha ni identidad histórica | Condición revisada; ejecución pendiente |

## 4. Verificación de todas las evidencias

| Evidencia | Ruta principal | Ruta de recuperación / comprobación | Criterio |
| --- | --- | --- | --- |
| E01 | N04 | Historial obligatorio y carga de checkpoint | Nunca se depende de recordar un dato no guardado |
| E02 | N08 | Ficha conservada y entrada obligatoria | Ninguna ruta a C omite la contradicción |
| E03 | G01.S02 voz de fondo T04/T05 | N12 sin audio | Mismo contenido útil; Q02 alcanzable en silencio |
| E04 | N11 | N20 por placa de planta | Patio directo recupera información sin plano previo |
| E05 | N14 | Reconsulta | Omitirla no bloquea Q02 ni A |
| E06 | N19 | N20 por patio directo | Cualquier primer despacho puede permitir D |
| E07 | N20 | Frente → reubicar → N20 | Ninguna primera asignación elimina la ruta favorable |
| E08 | N21 | Historial y G02 | Siempre anterior a K02 |
| E09 | N15 | Reconsulta | Omitirla no bloquea un resultado |
| E10 | N22 | Ficha G02 después de N22 | Pista N-4 anterior al final, sin nueva solución decisiva tardía |

**Revisión documental:** diez pruebas con fuente y desbloqueo definidos; esenciales recuperables por fuente alternativa o punto obligatorio persistente. En ejecución verificar igualdad de contenidos, ausencia de duplicados y preservación de fuentes.

## 5. Deducciones y combinaciones incorrectas

| ID | Preparación e intento | Resultado esperado |
| --- | --- | --- |
| DQ01 | Q01 con E01/E02 | Confirma una vez; permite D solo si también E06 |
| DQ02 | Q02 con E03/E04/E06 en cualquier orden | Confirma; no otorga E07 ni garantiza A |
| DQ03 | Q03 con E09/E10 antes/después de N22 | Antes no existe E10 seleccionable; después confirma y cambia N36 |
| DQ04 | Q04 con E01/E05/E08 | Confirma; abre N38, no cambia finales |
| DQ05 | Subconjunto correcto, como E03/E04 para Q02 | «Falta contrastarla con otra fuente»; sin penalización |
| DQ06 | Evidencia ajena o conjunto correcto más una extra | Retroalimentación de relación incorrecta; sin cambios |
| DQ07 | Repetir deducción confirmada | Explicación disponible; sin efectos duplicados |
| DQ08 | Sin tarjeta, sin selección o referencia obsoleta | Mensajes definidos; no confirma ni revela la prueba ausente |

**Estado:** conjuntos y efectos revisados documentalmente; evaluación interactiva pendiente de implementación.

## 6. Estados, límites y finales

| ID | Caso límite | Resultado esperado |
| --- | --- | --- |
| ST01 | Sumar/restar en límites de emociones | Saturación 0–2; sin desbordamiento |
| ST02 | N03 hostil + N21 cordial | Confianza 1/estrés 1; cooperación suficiente; A sigue posible con investigación y patio |
| ST03 | N03 cordial + N21 hostil | Confianza 1/estrés 1; cooperación suficiente |
| ST04 | Hostil/hostil y N18 después | Confianza 1/estrés 0; A recuperable |
| ST05 | Usar N18 antes de N21 y después volver a acusar | No se ofrece N18 otra vez; si cooperación insuficiente, B sigue alcanzable; no se promete recuperación infinita |
| ST06 | Doble toque de M01/M02 | Una asignación; segunda petición rechazada, sin duplicar R1 |
| ST07 | Recibir parte sin asignación o recibirlo dos veces | Sin transición válida ni evidencias extra |
| ST08 | Servicio sin E04; con E04 sin patio | Oculto en primer caso; visible bloqueado con explicación en segundo |
| ST09 | Recibir patio directo sin consultar plano | N20 otorga E04/E06/E07; Q02 y servicio siguen alcanzables |
| ST10 | Elegir refugio con todos los requisitos favorables | B; decisión conservadora impide salida comunicada, sin alterar evidencia |
| ST11 | Transmitir con plan ninguno, fuera de E o después de resolver | No ejecutar K02; no producir final nuevo |
| ST12 | Resolver con unidad patio_lista y luego cerrarla | A usa la instantánea previa, no se degrada a B |
| ST13 | Comparar todos los planes y nueve pares de emociones, Q02 sí/no, unidad frente/patio | 108 combinaciones del resolutor: A solo servicio+patio+Q02+cooperación; C solo pasillo+0/2; B el resto; servicio al frente es entrada inválida |
| ST14 | Intentar adquirir evidencia o deducir después de K02 | Solo lectura; no cambia la evaluación ya comprometida |

ST13 cuenta 3 planes × 9 pares × 2 estados de Q02 × 2 posiciones = **108**; **18** combinaciones servicio/frente son inválidas por requisitos de acción, y quedan **90** estados de entrada válidos. De ellos **4** son A (cuatro pares cooperantes), **4** C (pasillo, par 0/2, dos Q02, dos posiciones) y **82** B. El recuento es algebraico sobre el contrato del resolutor; no implica que todos los pares sean alcanzables por el guion ni que se haya ejecutado un simulador. Las rutas TR01–TR07 prueban alcanzabilidad documental de los tres tipos de resultado.

## 7. Persistencia y casos de fallo previstos

| ID | Acción de prueba futura | Criterio |
| --- | --- | --- |
| PS01 | Guardar/cargar en N03 antes y después de elegir | Emociones correctas; no repetir efectos; E01 consistente con N04 |
| PS02 | Guardar con R1 en tránsito | Misma asignación; ningún tiempo offline ni unidad duplicada |
| PS03 | Cerrar durante recepción de U02 | Checkpoint anterior o posterior completo; nunca E07 con asignación incompleta |
| PS04 | Guardar tras N18, reabrir N10 | N18 no vuelve a estar disponible |
| PS05 | Guardar en N21 y N22 | Fecha/cabecera según punto correcto, sin saltar respuesta ni repetir emoción |
| PS06 | Guardar en N25 con plan pendiente | No resolver automáticamente; corregir sigue disponible |
| PS07 | Cerrar después de K02 antes de ver la rama | Reanuda la misma rama y resultado, con instantánea previa al cierre de R1 |
| PS08 | Doble toque de Transmitir | Una K02, una instantánea, un solo desenlace |
| PS09 | Fallo de escritura y Reintentar | Reescribir estado en memoria sin aplicar efectos otra vez; avisar si solo hay checkpoint anterior durable |
| PS10 | Guardado desconocido, corrupto o con Q sin sus pruebas | Rechazo explicado, conservar archivo y no sobrescribir automáticamente |
| PS11 | Pausar audio, cerrar aplicación y cargar | Audio detenido y selección temporal vacía; E03 adquirida permanece |
| PS12 | Finalizar, menú y continuar | Expediente cerrado de solo lectura; no se reabre el peligro |
| PS13 | Nueva partida con progreso existente | Confirmar reemplazo; cancelar conserva el progreso |

**Estado:** previstas, sin ejecución real ni afirmación de archivos de guardado existentes.

## 8. Cronología y coherencia narrativa

| Comprobación | Resolución de diseño |
| --- | --- |
| Diecisiete años | 14/11/1981 → 14/11/1998; consola recibe a las 02:17 |
| Clausura e incendio | Ficha afirma clausura tras incendio de ese día; no se fija hora exacta del incendio ni de la clausura |
| Anexo anterior al fuego | 10/11/1981 precede al incendio; registra ensayo, no causa ni conocimiento previo del desastre |
| Hotel funciona en testimonio y está cerrado en presente | Fuentes contradictorias deliberadas; se mantienen separadas y fechadas |
| Clara histórica | Nombre/habitación/fecha coinciden; registro no certifica su destino; no se afirma que fuera declarada muerta |
| Golpes | Se reinterpretan mediante voz y humo; no se inventa un agresor en el cierre |
| Unidad sin humo y llamada con humo | Describen fuentes y fechas distintas; no se despliega una simulación de dos tiempos |
| Salida favorable sin persona encontrada | Clara comunica alivio y salida; la unidad no confirma contacto físico; evaluación explicita límite |
| Nadir y ECO | Solo relación documental N-4; no se revela su función ni se iguala el incendio al incidente general de 1981 |
| Pistas antes del final | E03/E04/E06/E07 y N21/N22 son accesibles antes de transmitir; N36 no añade una solución indispensable |
| Campaña y MVP | Solo Caso 001; tres resultados de atención, no finales de los cinco capítulos |

**Estado:** revisión documental sin contradicciones detectadas después de separar estas afirmaciones. La dirección de misterio gradual y la arquitectura prevista conservan GDD y STORY_BIBLE; los nuevos detalles están registrados como diseño de fase 02, sujetos a revisión del usuario.

## 9. Usabilidad, duración y aceptación

Pruebas futuras: primera partida sin guía externa; todas las fuentes en pantalla vertical; alternativas de audio en silencio; lectura lenta sin deterioro; acceso a historial; botones de peligro con confirmación; estado vacío y errores con mensaje. Registrar dispositivo, tamaño de pantalla, ruta, evidencias, tiempos, intervenciones y comprensión del resultado.

La estimación 8–15 minutos se revisará con partidas reales. No hay mediciones en PROMPT 02 ni se considera la longitud del documento como tiempo observado. Registrar por separado lectura, herramientas, indecisión y problemas de interfaz; obtener observaciones suficientes para ajustar el ritmo, sin fijar aquí un tamaño de muestra no acordado.

Criterios de aceptación documental:

- Tres documentos creados, relacionados con el seguimiento y sin código ni recursos.
- Nodos, elecciones, efectos, estados, pistas, deducciones, grabaciones, despachos y cierres especificados.
- Cada nodo tiene salida y las tres ramas tienen trazas desde nueva partida.
- Las pruebas esenciales son recuperables; las opcionales no condicionan A.
- Condiciones de resultado exhaustivas y explícitas antes de confirmar, con consecuencias del historial.
- Ningún intento de deducción castiga lectura, consume una unidad o bloquea el caso.
- Continuidad de 1981/1998 revisada y explicación global del fenómeno abierta.
- Pruebas reales y decisiones de producto pendientes claramente separadas de revisión documental.

La revisión editorial del usuario permanece pendiente. Completar la elaboración documental no equivale a aprobar definitivamente sus nuevos detalles ni a autorizar PROMPT 03.
