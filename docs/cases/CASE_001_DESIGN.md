# Caso 001 — La habitación 304

Versión documental 1.0 · 2026-10-27 · PROMPT 02. Diseño para revisión del usuario, sin implementación. Complementos: [especificación técnica](CASE_001_TECHNICAL_SPEC.md) y [plan de pruebas](CASE_001_TEST_PLAN.md).

## 1. Autoridad, alcance y sinopsis completa

El PROMPT 02 autoriza desarrollar el contenido del primer caso. Son requisitos del usuario: Puerto Umbral, 1998, llamada a las 02:17, Hotel Mirador, habitación 304, mujer amenazada por golpes, clausura tras un incendio de 1981, seis etapas y tres resultados. Los nombres secundarios, fechas concretas, textos y reglas siguientes son decisiones de diseño de esta fase, sujetas a revisión; no establecen la explicación global de ECO.

Propuesta de fecha diegética: **14 de noviembre de 1998**. Clara Salcedo llama desde la 304. Cree que alguien quiere entrar; interpreta los golpes como una amenaza humana. El registro municipal describe el hotel como clausurado tras el incendio del **14 de noviembre de 1981**. La diferencia es de diecisiete años exactos; no se fija la fecha del incidente general de Estación Nadir ni se equiparan ambos acontecimientos.

La llamada contiene humo y una voz de bomberos mal entendida, no pruebas de un agresor. El plano muestra una puerta de servicio desde la habitación a un descansillo exterior separado del pasillo. La unidad actual comprueba desde fuera que el acceso principal es inseguro y que la escalera posterior todavía existe. El jugador debe distinguir el peligro descrito por Clara de la situación observada en 1998: no hay incendio activo ni huéspedes visibles en el edificio actual.

La revelación parcial llega cuando Clara lee la fecha de su recibo: 14/11/1981. Su nombre figura en el registro histórico. Esto sostiene una correspondencia con aquella emergencia, sin demostrar si se trata de una persona, una reproducción o algún otro fenómeno. Una cabecera de circuito **N-4** puede relacionarse con un anexo de telefonía que menciona **Estación Nadir / Proyecto ECO**. No se explica la causa de la llamada ni el papel de Nadir en el incendio.

En el mejor recorrido, el operador reconoce el humo, prepara el acceso posterior, mantiene la cooperación y guía a Clara al descansillo. Ella comunica que puede respirar y que oye a los bomberos; la unidad de 1998 no encuentra a nadie allí. Se resuelve favorablemente la emergencia comunicada, sin certificar un rescate físico en 1998 ni una modificación del pasado. En el resultado parcial se conserva refugio y contacto hasta que la línea cae, sin evacuación confirmada. En el adverso, una instrucción peligrosa combinada con deterioro previo del vínculo lleva a la apertura al pasillo y a una pérdida de contacto entre humo. No se confirma una muerte.

## 2. Estructura narrativa A–F

| Etapa | Entrada y contenido | Acción de salida | Aprendizaje |
| --- | --- | --- | --- |
| A — La llamada | N01–N06: central, Clara, identidad, golpes | Confirmar consulta de registros | Tocar opciones, leer historial, efectos del trato |
| B — Primera contradicción | N07–N09: ficha municipal de clausura | N08 → N10 | Consultar un documento y conservar evidencia |
| C — Investigación | N10 y herramientas N11–N20 | En N10, contrastar fechas con Q01 confirmada y E06 obtenida | Audio/texto, plano, mapa, despacho, deducciones |
| D — Revelación parcial | N21–N22: recibo de 1981, circuito N-4 | N22 → N23 | Revisar hipótesis; no asumir fraude ni explicación paranormal definitiva |
| E — Decisión crítica | N23–N26, con regreso libre a N10 | Transmitir un plan en N25 | Combinar evidencia, recursos y cooperación |
| F — Resolución | N27–N38 según rama; N38 es consulta opcional previa | N37 → END | Consecuencias, evaluación y pista de continuidad |

N38 pertenece a las herramientas de C/E y solo se habilita después de la revelación. La ubicación numérica del nodo no establece orden temporal. Leer, analizar, abrir herramientas y probar deducciones no hacen avanzar el peligro. La única acción que resuelve la crisis es «Transmitir instrucción» en N25. La llegada de la unidad se tramita mediante «Recibir parte», sin reloj oculto.

## 3. Personajes

| ID | Nombre / función | Personalidad, motivación y emoción | Conoce / desconoce | Estrés y evolución |
| --- | --- | --- | --- | --- |
| P01 | El Operador; protagonista | Voz profesional elegida por el jugador; busca atender y decidir con fundamento; incertidumbre inicial | Conoce lo que descubre el jugador; no conoce de antemano la historia del hotel ni ECO | Puede tranquilizar, prejuzgar o rectificar; no tiene estadísticas personales |
| P02 | Clara Salcedo; interlocutora | Directa, asustada, atenta a indicaciones breves; quiere salir y que alguien la encuentre | Conoce su nombre, habitación, recibo, sonidos y puerta de servicio; desconoce la clausura, 1998 y la identidad de quien golpea | Con confianza se concentra y describe detalles; con estrés se precipita. Puede recuperar cooperación antes de transmitir el plan |
| P03 | Elena Vargas; supervisora | Serena, concreta; protege a interlocutora y personal; inquietud contenida ante las fechas | Conoce protocolos de la central y acceso a archivos; desconoce el fenómeno y el destino histórico de Clara | No revela soluciones globales. Insiste en contrastar fuentes y puede facilitar la recuperación de información |
| P04 | Inés Duarte; jefa de unidad R1 | Cauta, observadora; busca verificar accesos sin exponer al equipo; alerta profesional | Conoce el exterior actual y lo que informa el despacho; desconoce el interior de 1981 y no oye directamente a Clara | Mantiene perímetro; informa riesgos y acepta cambiar de acceso antes de la instrucción final |
| P00 | Sistema; textos de interfaz | Denominación técnica para fichas, paneles y evaluación; no es un personaje del mundo | Muestra solo información desbloqueada | No improvisa ni altera testimonios |

Tomás, Lucía y La Voz no intervienen. Clara no se identifica con La Voz. R1 es una unidad ficticia de rescate de la central, sin definir organización nacional ni protocolo de emergencias real.

## 4. Convenciones del guion

Los ID completos son `c001_n01`…`c001_n38`, `c001_e01`…`c001_e10`, `c001_q01`…`c001_q04`; aquí se abrevian N, E y Q. Las opciones usan ID completo `c001_nXX_oYY`. «Siempre» significa disponible al estar en ese nodo; los requisitos adicionales se escriben en la tabla. Un guion en efectos significa ninguno. Los efectos se aplican **al confirmar la opción**, nunca al mostrarla. Los efectos de entrada se indican por separado y son idempotentes. No hay líneas implícitas necesarias para completar las rutas.

«Volver al expediente» y «Continuar» son botones exactos. Los paneles de herramientas mantienen su propio texto; sus acciones completas están en las secciones 6–9. No se cuentan como elecciones de diálogo. Las elecciones representan palabras del Operador cuando son frases dirigidas a alguien; no generan otro nodo de repetición de esa misma frase.

## 5. Guion interactivo completo

### N01 — P03 · A

**Texto:** «Turno de noche. Soy Elena Vargas, tu supervisora. La línea dos está entrando. Primero escucha; después comprobamos los datos.»

| Opción | Texto exacto | Condición | Efectos | Destino |
| --- | --- | --- | --- | --- |
| O01 | Atender la línea dos | Siempre | comunicación = activa | N03 |
| O02 | Ver los controles de la consola | Siempre | — | N02 |

### N02 — P03 · A

**Texto:** «La conversación queda en el historial. El expediente reúne lo que confirmes. Puedes volver a leer sin perder la llamada.»

| Opción | Texto exacto | Condición | Efectos | Destino |
| --- | --- | --- | --- | --- |
| O01 | Atender la línea dos | Siempre | comunicación = activa | N03 |

### N03 — P02 · A

**Texto:** «¿Emergencias? Por favor… alguien está golpeando. Estoy encerrada en una habitación.»

| Opción | Texto exacto | Condición | Efectos | Destino |
| --- | --- | --- | --- | --- |
| O01 | Estoy aquí. Dígame su nombre y dónde está. | Siempre | confianza +1, estrés −1 | N04 |
| O02 | Necesito datos, no suposiciones. ¿Quién es y dónde está? | Siempre | confianza −1, estrés +1 | N04 |

### N04 — P02 · A

**Texto:** «Clara Salcedo. Hotel Mirador, habitación trescientos cuatro. No puedo salir por el pasillo.»

**Entrada:** añadir E01.

| Opción | Texto exacto | Condición | Efectos | Destino |
| --- | --- | --- | --- | --- |
| O01 | ¿Qué ha visto de la persona que golpea? | Siempre | — | N05 |

### N05 — P02 · A

**Texto:** «No la he visto. Golpea tres veces y grita algo. La luz se ha ido. Hay otra puerta, junto al baño, pero no sé adónde lleva.»

| Opción | Texto exacto | Condición | Efectos | Destino |
| --- | --- | --- | --- | --- |
| O01 | Voy a comprobar el hotel. Mantenga la línea. | Siempre | — | N06 |

### N06 — P01 · A

**Texto:** «Clara, sigo escuchándola mientras consulto los registros.»

| Opción | Texto exacto | Condición | Efectos | Destino |
| --- | --- | --- | --- | --- |
| O01 | Consultar Hotel Mirador | Siempre | etapa = B | N07 |

### N07 — P03 · B

**Texto:** «La dirección existe. Pero la ficha dice que el hotel lleva diecisiete años clausurado. Comprueba la fecha antes de sacar conclusiones.»

| Opción | Texto exacto | Condición | Efectos | Destino |
| --- | --- | --- | --- | --- |
| O01 | Abrir ficha municipal | Siempre | — | N08 |
| O02 | ¿Seguimos tratándolo como una emergencia? | Siempre | — | N09 |

### N08 — P00 · B

**Texto:** «HOTEL MIRADOR. Paseo del Faro, 18. Clausurado tras el incendio del 14/11/1981. Prohibido acceder por el vestíbulo: forjado dañado. Anexos: plano de planta, huéspedes y telefonía.»

**Entrada:** añadir E02; al salir, desbloquear expediente, audio, mapa y deducciones.

| Opción | Texto exacto | Condición | Efectos | Destino |
| --- | --- | --- | --- | --- |
| O01 | Guardar ficha en el expediente | Siempre | etapa = C | N10 |

### N09 — P03 · B

**Texto:** «Sí. Que el registro no encaje no significa que nadie necesite ayuda. Podemos enviar una unidad a comprobar el exterior.»

| Opción | Texto exacto | Condición | Efectos | Destino |
| --- | --- | --- | --- | --- |
| O01 | Abrir ficha municipal | Siempre | — | N08 |

### N10 — P00 · C o E · Centro de investigación

**Texto C:** «Línea dos activa. Contraste las fuentes antes de decidir. Las consultas no avanzan la emergencia.»

**Texto E:** «Clara sigue al teléfono. Puede revisar el expediente y preparar la unidad antes de transmitir una instrucción.»

| Opción | Texto exacto | Condición | Efectos | Destino |
| --- | --- | --- | --- | --- |
| O01 | Consultar plano de planta | Siempre | — | N11 |
| O02 | Preguntar por los sonidos y el aire | Siempre | — | N12 |
| O03 | Abrir analizador de audio | Siempre | — | N13 |
| O04 | Consultar registro de huéspedes | Siempre | — | N14 |
| O05 | Consultar anexo de telefonía | Siempre | — | N15 |
| O06 | Abrir mapa y despacho | Siempre | — | N16 |
| O07 | Relacionar evidencias | Siempre | — | N17 |
| O08 | Recuperar la calma con Clara | Solo si no existe elección N18.O01 en el historial de transacciones | — | N18 |
| O09 | Contrastar la fecha con Clara | Solo C; visible siempre, habilitada con Q01 y E06 | etapa = D | N21 |
| O10 | Volver a la decisión crítica | Solo E | — | N24 |
| O11 | Hablar del registro de 1981 | Solo si Q04 confirmada | — | N38 |

Las opciones de consulta repetidas no vuelven a sumar evidencias ni alteran emociones. N10 no tiene opción de abandonar la llamada antes de elegir un resultado. Salir al menú conserva el punto de retorno, no resuelve el caso.

### N11 — P00 · Plano

**Texto:** «PLANTA TERCERA, archivo de 1981. La 304 tiene una puerta al pasillo interior y otra de servicio junto al baño. Esta segunda puerta comunica con un descansillo abierto al patio y una escalera exterior posterior. El plano no certifica el estado actual de la escalera.»

**Entrada:** añadir E04.

| Opción | Texto exacto | Condición | Efectos | Destino |
| --- | --- | --- | --- | --- |
| O01 | Volver al expediente | Siempre | — | N10 |

### N12 — P02 · Comprobación sensorial

**Texto:** «Ahora huelo humo por debajo de la puerta del pasillo. Entre los golpes oigo “bomberos”… y “no abra al pasillo”. Yo creía que venían a buscarme. La otra puerta tiene una placa: servicio.»

**Entrada:** añadir E03. Es la recuperación alternativa a analizar la primera grabación.

| Opción | Texto exacto | Condición | Efectos | Destino |
| --- | --- | --- | --- | --- |
| O01 | Lo anoto. Seguimos comprobando. | Siempre | — | N10 |

### N13 — P00 · Audio

**Texto:** «Grabaciones de la línea dos. Seleccione un fragmento y una variante, o lea su transcripción equivalente. Ninguna pista exige oír el audio.»

**Entrada:** abrir panel de audio; acciones y textos en sección 8. Volver no exige reproducir nada.

| Opción | Texto exacto | Condición | Efectos | Destino |
| --- | --- | --- | --- | --- |
| O01 | Volver al expediente | Siempre | — | N10 |

### N14 — P00 · Huéspedes

**Texto:** «REGISTRO HISTÓRICO, 14/11/1981. Clara Salcedo, habitación 304. Anotación posterior: evacuación no confirmada en este folio. Este documento no permite determinar su destino.»

**Entrada:** añadir E05.

| Opción | Texto exacto | Condición | Efectos | Destino |
| --- | --- | --- | --- | --- |
| O01 | Volver al expediente | Siempre | — | N10 |

### N15 — P00 · Telefonía

**Texto:** «ANEXO DE TELEFONÍA, 10/11/1981. Hotel Mirador, circuito N-4. Copia de ensayo de enlace: Estación Nadir / Proyecto ECO. El anexo no describe el objetivo del ensayo ni lo relaciona con el incendio.»

**Entrada:** añadir E09.

| Opción | Texto exacto | Condición | Efectos | Destino |
| --- | --- | --- | --- | --- |
| O01 | Volver al expediente | Siempre | — | N10 |

### N16 — P00 · Mapa

**Texto fijo:** «Vestíbulo clausurado; acceso posterior por el patio. La unidad no entrará en una estructura insegura.»

**Texto de estado, una sola variante:** disponible: «R1 disponible. Seleccione un destino para inspección exterior»; rumbo_frente: «R1 asignada al frente. Pulse “Recibir parte”»; rumbo_patio: «R1 asignada al patio. Pulse “Recibir parte”»; frente_lista: «Parte del frente recibido. Puede reubicar R1 al patio»; patio_lista: «Acceso posterior comprobado. R1 mantiene posición exterior». El panel no admite unidad cerrada porque no se abre después de K02.

**Entrada:** abrir mapa; acciones completas en sección 9. Recibir un parte interrumpe este panel hacia N19 o N20. No hay llegada por tiempo real.

| Opción | Texto exacto | Condición | Efectos | Destino |
| --- | --- | --- | --- | --- |
| O01 | Volver al expediente | Siempre | — | N10 |

### N17 — P00 · Deducciones

**Texto:** «Seleccione una hipótesis y las pruebas que la sostienen. Una combinación incompleta o equivocada puede corregirse sin penalización.»

**Entrada:** abrir panel de deducciones; acciones completas en sección 7.

| Opción | Texto exacto | Condición | Efectos | Destino |
| --- | --- | --- | --- | --- |
| O01 | Volver al expediente | Siempre | — | N10 |

### N18 — P02 · Rectificación

**Texto:** «Está bien. Le escucho. Pensé que no me creía. Dígame una cosa cada vez.»

| Opción | Texto exacto | Condición | Efectos | Destino |
| --- | --- | --- | --- | --- |
| O01 | Voy a basarme en lo que podamos comprobar. | Siempre | confianza = 1; estrés = 0; registrar uso de esta opción | N10 |

### N19 — P04 · Parte del frente

**Texto:** «R1 en Paseo del Faro. Hotel cerrado, sin humo actual ni personas visibles. El vestíbulo tiene riesgo de derrumbe; no vamos a entrar. Podemos rodear hasta el patio si lo autoriza.»

**Entrada:** añadir E06; unidad = frente_lista.

| Opción | Texto exacto | Condición | Efectos | Destino |
| --- | --- | --- | --- | --- |
| O01 | Recibido. Revisaré el acceso posterior. | Siempre | — | N10 |

### N20 — P04 · Parte posterior

**Texto:** «R1 en el patio. No hay humo actual ni personas visibles. El vestíbulo sigue siendo inseguro. Desde fuera confirmamos la escalera posterior y el descansillo de la tercera planta. La puerta de servicio de la 304 da allí, según la placa de planta conservada. Nos quedamos en zona segura.»

**Entrada:** añadir E06, E07 y E04; unidad = patio_lista. La placa permite recuperar el plano aunque no se haya abierto N11.

| Opción | Texto exacto | Condición | Efectos | Destino |
| --- | --- | --- | --- | --- |
| O01 | Mantengan posición exterior. | Siempre | — | N10 |

### N21 — P02 · D

**Texto:** «Mi recibo está aquí, junto al teléfono. Clara Salcedo, 304… catorce de noviembre de mil novecientos ochenta y uno. ¿Por qué me pregunta eso? El humo está entrando más.»

**Entrada:** añadir E08; desbloquear G02. No volver a entrar tras salir de D.

| Opción | Texto exacto | Condición | Efectos | Destino |
| --- | --- | --- | --- | --- |
| O01 | Gracias, Clara. Eso ayuda a entender la llamada. | Siempre | confianza +1, estrés −1 | N22 |
| O02 | Esa fecha es imposible. ¿Me está mintiendo? | Siempre | confianza −1, estrés +1 | N22 |

### N22 — P03 · D

**Texto:** «Nuestra consola marca catorce de noviembre de 1998. Su recibo dice 1981. Además, la captura lleva la cabecera N-4, un circuito que no figura entre los activos. Conserva la grabación. Ahora resuelve el peligro que está describiendo.»

**Entrada:** añadir E10.

| Opción | Texto exacto | Condición | Efectos | Destino |
| --- | --- | --- | --- | --- |
| O01 | Volver a Clara | Siempre | etapa = E | N23 |

### N23 — P02 · E

**Texto:** «Los golpes han parado. El humo sigue por la puerta del pasillo. La puerta de servicio está a mi lado. No sé qué hacer. ¿Me quedo o intento salir?»

| Opción | Texto exacto | Condición | Efectos | Destino |
| --- | --- | --- | --- | --- |
| O01 | Preparar una instrucción | Siempre | — | N24 |

### N24 — P03 · E

**Texto:** «El pasillo de su llamada tiene humo; nuestro equipo ve un edificio clausurado. No confundas esas dos situaciones. Antes de transmitir, revisa qué acceso has comprobado y si Clara puede seguirte.»

| Opción | Texto exacto | Condición | Efectos | Destino |
| --- | --- | --- | --- | --- |
| O01 | Revisar pruebas y despacho | Siempre | — | N10 |
| O02 | Mantenerla en la habitación, apartada del pasillo | Siempre | plan = refugio | N25 |
| O03 | Guiarla a la puerta de servicio y al descansillo | Visible con E04; habilitada solo con unidad = patio_lista | plan = servicio | N25 |
| O04 | Pedirle que abra la puerta del pasillo | Siempre, marcada «riesgo conocido: humo» | — | N26 |

### N25 — P01 · Confirmación

**Texto si refugio:** «Clara, manténgase en la habitación, junto a la puerta de servicio y apartada del pasillo. Seguimos con usted mientras verificamos cómo alcanzarla.»

**Texto si servicio con Q02:** «Clara, la puerta junto al baño comunica con el descansillo exterior. La unidad ha comprobado ese acceso. Siga mi voz hasta esa puerta; no use el pasillo.»

**Texto si servicio sin Q02:** «Clara, nuestra unidad está detrás del hotel. Busque una salida por ese lado.»

**Texto si pasillo:** «Clara, abra la puerta del pasillo para comprobar quién está fuera.»

Antes del botón se muestran tres filas derivadas: «Amenaza: interpretada / sin deducción confirmada» (Q02), «Unidad: frente / patio» y «Clara: cooperando / necesita calma». Si servicio sin Q02, añadir «La instrucción aún no identifica una puerta concreta. Relacione las fuentes para precisarla». El jugador puede corregir antes de transmitir. La deducción cambia el contenido de la instrucción, no solo una marca interna; no hay requisito oculto para A.

| Opción | Texto exacto | Condición | Efectos | Destino |
| --- | --- | --- | --- | --- |
| O01 | Transmitir instrucción | Siempre; plan distinto de ninguno | evento K02: resolver según sección 10; comunicación y resultado fijados atómicamente | N27 si A; N30 si B; N33 si C |
| O02 | Corregir antes de transmitir | Siempre | plan = ninguno | N24 |

### N26 — P03 · Advertencia

**Texto:** «Ha descrito humo en el pasillo. Abrir puede empeorar su situación. Si está alterada, quizá no consiga retroceder a tiempo. Todavía puedes comprobar la salida de servicio o mantenerla apartada.»

| Opción | Texto exacto | Condición | Efectos | Destino |
| --- | --- | --- | --- | --- |
| O01 | Cancelar esa instrucción | Siempre | plan = ninguno | N24 |
| O02 | Preparar la apertura pese al riesgo | Siempre | plan = pasillo | N25 |

### N27 — P02 · Final A

**Texto:** «La puerta de servicio abre… estoy en el descansillo. Aquí puedo respirar. Hay una luz abajo. Oigo a los bomberos. Voy con ellos. Gracias por seguir ahí.»

| Opción | Texto exacto | Condición | Efectos | Destino |
| --- | --- | --- | --- | --- |
| O01 | Pedir confirmación a R1 | Siempre | — | N28 |

### N28 — P04 · Final A

**Texto:** «El descansillo está vacío. No hemos visto salir a nadie. La escalera sigue donde le dijimos. Confirmo: nuestra unidad no ha establecido contacto físico con Clara.»

| Opción | Texto exacto | Condición | Efectos | Destino |
| --- | --- | --- | --- | --- |
| O01 | Registrar ambas versiones | Siempre | — | N29 |

### N29 — P03 · Final A

**Texto:** «Su respiración mejoró y comunicó que había alcanzado una salida. Eso es lo que sabemos. Registra la ayuda prestada y la ausencia de confirmación física. No inventemos lo que pasó después.»

| Opción | Texto exacto | Condición | Efectos | Destino |
| --- | --- | --- | --- | --- |
| O01 | Cerrar la atención de emergencia | Siempre | — | N36 |

### N30 — P02 · Final B

**Texto si refugio:** «Me quedo junto a la puerta de servicio. Aquí entra menos humo. ¿Sigue conmigo? La línea… apenas le oigo.»

**Texto si servicio sin Q02:** «¿Por qué lado? No sé qué salida dice. Me quedo junto al baño, lejos del pasillo. Repítalo… su voz se está cortando.»

**Texto si servicio con Q02 y cooperación insuficiente:** «No consigo seguirlo. Me he apartado del pasillo, junto a la otra puerta. Repítalo… su voz se está cortando.»

**Texto si pasillo:** «He abierto un poco. Hay humo; cierro otra vez. Me aparto. No puedo pasar por ahí. ¿Me oye?»

| Opción | Texto exacto | Condición | Efectos | Destino |
| --- | --- | --- | --- | --- |
| O01 | Consultar el último parte | Siempre | — | N31 |

### N31 — P04 · Final B

**Texto:** «Mantenemos la inspección desde zona segura. No encontramos a la interlocutora ni podemos confirmar una evacuación. El edificio actual no presenta humo.»

| Opción | Texto exacto | Condición | Efectos | Destino |
| --- | --- | --- | --- | --- |
| O01 | Registrar contacto perdido | Siempre | — | N32 |

### N32 — P03 · Final B

**Texto:** «La mantuvimos apartada del pasillo, pero no pudimos confirmar que saliera. Anota qué faltó: una interpretación comprobada, un acceso preparado o recuperar su cooperación. El expediente conservará lo que sí averiguaste.»

| Opción | Texto exacto | Condición | Efectos | Destino |
| --- | --- | --- | --- | --- |
| O01 | Cerrar la atención de emergencia | Siempre | — | N36 |

### N33 — P02 · Final C

**Texto:** «Abro… no veo nada. El humo… no sé volver a la puerta. ¿Dónde está? ¿Me oye?»

| Opción | Texto exacto | Condición | Efectos | Destino |
| --- | --- | --- | --- | --- |
| O01 | Solicitar comprobación exterior | Siempre | — | N34 |

### N34 — P04 · Final C

**Texto:** «No localizamos a nadie desde el exterior. No hay una entrada interior segura. No voy a exponer al equipo a un derrumbe sin una localización verificable.»

| Opción | Texto exacto | Condición | Efectos | Destino |
| --- | --- | --- | --- | --- |
| O01 | Registrar pérdida de contacto en riesgo | Siempre | — | N35 |

### N35 — P03 · Final C

**Texto:** «La instrucción la llevó hacia el humo cuando ya no conseguía seguirte con calma. Había una advertencia y una alternativa. No podemos confirmar su destino; sí podemos registrar cómo empeoró la atención.»

| Opción | Texto exacto | Condición | Efectos | Destino |
| --- | --- | --- | --- | --- |
| O01 | Cerrar la atención de emergencia | Siempre | — | N36 |

### N36 — P03 · Pista de continuidad, todos los finales

**Texto si Q03:** «N-4 coincide con el anexo del hotel: Estación Nadir, Proyecto ECO. Tenemos una relación documental, no una explicación. Separa esa copia para revisar su procedencia.»

**Texto sin Q03:** «Conserva la cabecera N-4. No corresponde a un circuito activo de la central. Su procedencia queda pendiente; no borres la captura.»

| Opción | Texto exacto | Condición | Efectos | Destino |
| --- | --- | --- | --- | --- |
| O01 | Ver evaluación del caso | Siempre | — | N37 |

### N37 — P00 · Evaluación

**Texto fijo:** «CASO 001 — ATENCIÓN CERRADA. El resultado describe la atención comunicada, no certifica el destino histórico de Clara. Evidencias y grabaciones conservadas.»

**Filas exactas, escogidas por estado:** «Resultado: Salida comunicada / Refugio sin confirmación / Contacto perdido en riesgo»; «Interpretación del peligro: confirmada / pendiente» (Q02); «Acceso posterior: verificado / no verificado» (E07); «Cooperación al transmitir: suficiente / insuficiente»; «N-4: vinculado documentalmente a ECO / procedencia pendiente» (Q03); «Identidad histórica: correspondencia documentada / sin contrastar» (Q04).

Si B, añadir cada motivo verdadero: «No se eligió una evacuación por servicio»; «Faltó confirmar la interpretación del peligro»; «Faltó verificar el acceso posterior»; «Faltó recuperar la cooperación». Si C: «Se indicó abrir al pasillo pese al humo, con confianza agotada y estrés alto». No hay puntuación oculta ni experiencia numérica.

| Opción | Texto exacto | Condición | Efectos | Destino |
| --- | --- | --- | --- | --- |
| O01 | Volver al menú principal | Siempre | cerrar presentación; mantener expediente de solo lectura | END |

### N38 — P02 · Consulta histórica opcional

**Texto:** «Sí, ese es mi nombre. Me dieron la trescientos cuatro al llegar. Si ese papel está ahí, por favor, no deje que mi llamada se pierda también.»

| Opción | Texto exacto | Condición | Efectos | Destino |
| --- | --- | --- | --- | --- |
| O01 | Conservaré el registro junto a la llamada. | Siempre | — | N10 |

### Árbol de decisiones

```text
N01 → [N02] → N03 → N04 → N05 → N06 → N07 → [N09] → N08
  → N10 ↔ herramientas N11–N18; N16 → partes N19 / N20 → N10
  → confirmar Q01 + recibir E06 → N21 → N22 → N23 → N24
  ↔ N10 (mismas herramientas, más N38 si Q04)
  → refugio / servicio preparado → N25
  → pasillo → N26 → cancelar N24 / preparar N25
N25 → corregir N24 / transmitir K02
  → A: N27 → N28 → N29 ┐
  → B: N30 → N31 → N32 ├→ N36 → N37 → END
  → C: N33 → N34 → N35 ┘
```

Son **38 nodos y 57 elecciones de diálogo**. El conteo se obtiene de las tablas, sin sumar variantes de texto ni botones de herramientas (siete acciones de audio, cinco de mapa y las operaciones del panel de deducciones). Los nodos N19 y N20 son entradas por eventos de despacho; N27/N30/N33 por el resolutor documentado. END es un destino terminal, no un diálogo.

## 6. Estado narrativo mínimo

Los nombres completos, tipos e invariantes están en la especificación. Las únicas magnitudes emocionales almacenadas son confianza y estrés; cooperación se deriva para evitar combinaciones contradictorias.

| Variable | Tipo / inicial / permitidos | Modificadores | Condiciones y consecuencias |
| --- | --- | --- | --- |
| confianza | Entero, 1; 0–2 | N03, N21 ±1 saturado; N18 fija 1 | Con estrés determina cooperación; 0 junto con estrés 2 agrava apertura al pasillo |
| estres | Entero, 1; 0–2 | N03, N21 ±1 saturado; N18 fija 0 | No sube por leer o fallar deducciones; condiciona seguimiento seguro |
| cooperacion | Derivada, inicialmente suficiente; no se guarda | Suficiente si confianza ≥1 y estrés ≤1 | Se muestra antes de transmitir; necesaria para A |
| evidencias | Conjunto de ID, vacío; E01–E10 | Entradas de nodos y acciones de audio | No se eliminan; determinan hipótesis y opciones |
| deducciones | Conjunto de ID confirmados, vacío; Q01–Q04 | Confirmación válida en panel | Q01 habilita D; Q02 interviene en A; Q03 y Q04 enriquecen cierre |
| unidad | Enum, disponible | Despachar, recibir parte, reubicar, resolver | Una sola R1; estados definidos en sección 9; impide duplicar recursos |
| plan | Enum, ninguno; ninguno/refugio/servicio/pasillo | N24, N26; cancelar N25 | Se puede corregir hasta K02; combina sus efectos con investigación y vínculo |
| comunicacion | Enum, entrante; entrante/activa/cerrada/interrumpida | Atender; K02 | A cierra voluntariamente; B/C pierden comunicación; bloquea nuevas acciones tras resolver |
| resultado | Enum, pendiente; pendiente/A/B/C | Solo K02 | Inmutable al resolver; selecciona la rama final |
| etapa | Enum, A; A–F | Salidas A/B, revelar y resolver | Controla herramientas y avance único; nunca retrocede |

El cursor de diálogo, el historial de transacciones y el registro de efectos únicos son infraestructura de persistencia, no estadísticas. El uso de N18 se consulta en ese registro. Las acciones críticas son contrastar fechas (K01) y transmitir el plan (K02); no se añade un contador de urgencia.

## 7. Evidencias y deducciones

### Catálogo íntegro de evidencias

«Esencial» indica necesaria para el recorrido favorable o para la comprensión obligatoria, no una obligación de encontrarla para llegar a cualquier cierre. Ninguna evidencia opcional bloquea A. Todo contenido de fichas se conserva con texto, fuente y fecha, sin reinterpretarlo como hecho probado del fenómeno.

| ID / nombre / categoría | Descripción e información | Fuente, obtención y desbloqueo | Relación e importancia | Recuperación alternativa |
| --- | --- | --- | --- | --- |
| E01 — Clara, habitación 304 · Esencial | Nombre declarado, hotel y habitación; testimonio sin identidad verificada | Llamada, entrada N04, siempre en A | Q01, Q04; establece qué se investiga | Historial obligatorio de N04; se restaura desde el estado si se cierra la app |
| E02 — Clausura del Mirador · Esencial | Incendio y clausura 14/11/1981; daño del vestíbulo | Ficha municipal N08, B | Q01; contradicción inicial y advertencia de seguridad | Entrada obligatoria N08; ficha siempre consultable en expediente |
| E03 — Humo y aviso de bomberos · Esencial | Hay humo; los golpes no prueban un agresor; voz dice «no abra al pasillo» | G01 fragmento S02 con voz aislada o su transcripción, desde C | Q02; reinterpretar la amenaza | Pregunta N12 reproduce la información por testimonio directo |
| E04 — Dos puertas de la 304 · Esencial | Puerta al pasillo y servicio al descansillo/escalera exterior; plano histórico, no certificación actual | Plano N11, desde C | Q02 y opción de servicio; permite localizar ruta | Parte N20 y placa de planta conservada añaden la misma evidencia con segunda fuente |
| E05 — Huésped de 1981 · Opcional | Clara Salcedo consta en la 304; folio no confirma evacuación | Registro N14, desde C | Q04; correspondencia histórica, no final favorable | Reabrir registro, sin vencimiento |
| E06 — Exterior actual clausurado · Esencial | Sin humo ni huéspedes visibles; vestíbulo inseguro en 1998 | Parte N19 o N20 tras despacho | Q02 y acceso a D; contrasta situación actual | Ambas asignaciones de R1 proporcionan el parte; nunca depende de una ubicación secreta |
| E07 — Acceso posterior verificado · Esencial para A | Escalera y descansillo existentes y observados desde zona segura | Parte N20, tras enviar o reubicar a patio | Requisito de servicio y A; no demuestra que Clara esté allí | Desde el frente se puede reubicar R1 antes de K02 sin coste de peligro |
| E08 — Recibo del 14/11/1981 · Esencial de continuidad | Clara lee una fecha incompatible con la consola de 1998 | N21 obligatorio en D | Q04; revelación parcial anterior a la decisión | Historial y transcripción de G02; se otorga al entrar en N21, sin necesidad de oído |
| E09 — Anexo Nadir / ECO · Opcional | Copia de ensayo del circuito N-4 del 10/11/1981; no declara causa del incendio | Telefonía N15, desde C | Q03; pista ampliada del misterio central | Reabrir anexo, sin vencimiento |
| E10 — Cabecera N-4 · Contextual | Circuito de captura no activo en la central; etiqueta, no voz sobrenatural | Elena N22 obligatorio; ficha técnica G02 | Q03; pista persistente en todos los cierres | Historial de N22 y datos textuales de G02 |

No se pierde E03 si se evita el audio ni E04 si se omite el plano. E01/E02/E08 son de obtención obligatoria y lectura recuperable. E06/E07 tienen despacho recuperable. No hay búsquedas por píxeles ni pistas fuera de pantalla.

### Reglas del panel de deducciones

Cuatro tarjetas de hipótesis visibles desde C; sus títulos son preguntas orientadoras. Seleccionar una tarjeta, tocar entre dos y tres evidencias y pulsar «Comprobar relación». La selección debe coincidir exactamente con su conjunto requerido. Los intentos no cambian emociones, tiempo ni resultado. Las tarjetas confirmadas conservan su explicación; no se acumulan otra vez.

| ID / hipótesis | Evidencias necesarias | Interpretación y texto exacto de confirmación | Opciones, efectos y relación con finales |
| --- | --- | --- | --- |
| Q01 — ¿Encaja la llamada con el registro actual? | E01 + E02 | «El testimonio sitúa una habitación ocupada en un hotel registrado como clausurado desde 1981. La contradicción requiere comprobación; no demuestra una broma.» | Tutorial sencillo; añade Q01; habilita contrastar fecha cuando llegue E06. Necesaria para todos los cierres |
| Q02 — ¿Qué amenaza hay y qué salida tiene sentido? | E03 + E04 + E06 | «Clara describe humo y un aviso de bomberos. El pasillo es el peligro comunicado; servicio ofrece una ruta separada en el plano. La unidad actual debe verificarla antes de usarla.» | Añade Q02; sustituye la instrucción genérica por la referencia precisa a la puerta junto al baño y el pasillo a evitar. Habilita evaluación «confirmada». Necesaria para A junto con E07 y cooperación; por sí sola no garantiza rescate |
| Q03 — ¿De dónde procede el circuito? | E09 + E10 | «La cabecera N-4 coincide con el ensayo de telefonía que menciona Estación Nadir y Proyecto ECO. Hay un vínculo documental; su función y relación con el incendio siguen abiertas.» | Opcional, añade Q03; variante N36 y expediente ampliado; no altera A/B/C |
| Q04 — ¿Coincide la identidad con el archivo histórico? | E01 + E05 + E08 | «Nombre, habitación y fecha coinciden con el registro de 1981. La correspondencia apoya revisar esa emergencia, pero no prueba quién habla ni qué ocurrió después.» | Opcional, añade Q04; habilita N38 y fila histórica de evaluación; no altera A/B/C |

Retroalimentación completa del panel:

- Sin tarjeta: «Seleccione una hipótesis antes de comprobar pruebas».
- Selección vacía: «Seleccione las evidencias que sostienen esta hipótesis».
- Subconjunto correcto: «La relación es plausible, pero falta contrastarla con otra fuente».
- Cualquier evidencia ajena al conjunto: «Estas pruebas no sostienen juntas la hipótesis elegida. Compare qué afirma cada fuente».
- Prueba aún no descubierta: no se muestra su contenido ni permite seleccionarla; «Todavía no consta en el expediente» si una referencia queda desactualizada.
- Ya confirmada: «Deducción ya registrada. Puede consultar su explicación».

La falta de E05/E09 no impide el recorrido favorable. El hotel funcionando y los golpes son indicios potencialmente engañosos por interpretación; no son mentiras insertadas por el sistema. Ningún intento incorrecto consume una oportunidad.

## 8. Analizador: dos grabaciones predefinidas

No se generan grabaciones en esta fase. Cada variante se producirá como recurso predefinido; no se aplica procesamiento real. El diálogo principal es texto, con ambientación y fragmentos sonoros breves; no requiere doblaje completo.

### G01 — Primer contacto, aproximadamente 18 segundos

Se desbloquea al llegar a C. Contexto: captura ficticia de N03–N05; no exige que el texto haya durado dieciocho segundos al leerlo.

| Segmento | Sonido y transcripción exacta | Variantes seleccionables | Pista y significado |
| --- | --- | --- | --- |
| S01, 00–06 s | Clara: «Hotel Mirador… habitación trescientos cuatro». Zumbido de línea | Original; voz cercana | E01 ya obtenida; repetir no añade nada |
| S02, 06–14 s | Tres golpes, alarma grave, tos. Voz lejana: «¡Bomberos! ¡No abra al pasillo!» | Original: voz marcada [poco clara]; voz de fondo: frase inteligible pregrabada | E03 al consultar voz de fondo o su transcripción; distingue aviso de rescate de amenaza humana |
| S03, 14–18 s | Clara: «No puedo salir por ahí». Tos, roce junto al teléfono | Original; ambiente | Contexto sin nueva evidencia; no exige distinguir una frecuencia sutil |

### G02 — Fecha y cabecera, aproximadamente 12 segundos

Se desbloquea en N21. Contexto: fragmento predefinido de la lectura del recibo. La ficha de cabecera se hace visible al pasar N22, igual que E10.

| Segmento | Sonido y transcripción exacta | Variantes seleccionables | Pista y significado |
| --- | --- | --- | --- |
| S01, 00–09 s | Clara: «Clara Salcedo, trescientos cuatro. Catorce de noviembre de mil novecientos ochenta y uno» | Original; voz cercana | E08 ya recibida por diálogo; vuelve a consultarse sin costes |
| S02, 09–12 s | Línea con chasquido; sin mensaje secreto ni voz nueva | Original; ambiente | Sin pista auditiva adicional. Ficha textual: «Cabecera de captura: N-4. No consta como circuito activo», visible después de N22; E10 |

Acciones del panel, sin rutas adicionales de diálogo:

| ID | Botón / condición | Resultado |
| --- | --- | --- |
| T01 | Seleccionar grabación / desbloqueada | Abre lista de segmentos; no otorga pistas por sí solo |
| T02 | Seleccionar segmento / existente | Marca intervalo fijo; sin arrastre de precisión |
| T03 | Seleccionar variante / incluida en segmento | Muestra nombre de variante y dos botones equivalentes |
| T04 | Reproducir / selección válida | Reproduce variante predefinida; E03 se registra al iniciar S02 de G01 en voz de fondo, no tras esperar al final |
| T05 | Leer transcripción / selección válida | Muestra el texto equivalente completo y produce el mismo efecto de evidencia que T04 |
| T06 | Ver datos de captura / G02 y N22 consumido | Muestra E10; idempotente |
| T07 | Detener | Detiene audio; no quita evidencias |

Todos los sonidos relevantes tienen rótulo textual y transcripción. Para E03 basta T05 sin altavoces. Transcripciones y variantes no consumen tiempo narrativo. Si no hay audio disponible por un fallo futuro, la transcripción y N12 conservan la ruta de investigación.

## 9. Mapa y despacho

Un distrito ficticio, **Frente Costero**, y un único edificio con dos puntos de observación. No se diseña el resto de la ciudad.

| ID | Ubicación e información inicial | Información desbloqueable |
| --- | --- | --- |
| L01 | Mirador, Paseo del Faro 18: dirección de la ficha; vestíbulo clausurado | E06: situación actual sin humo, riesgo de derrumbe interior |
| L02 | Patio posterior del mismo hotel: rótulo «acceso exterior por comprobar» | E04/E07: relación con puerta de servicio y existencia actual de escalera/descansillo |

L02 está visible desde C para no bloquear el despacho a quien aún no abrió el plano. No permite deducir el destino de la puerta de Clara sin E04. Solo existe R1, con Inés Duarte; no se crean policía, ambulancia u otras unidades decorativas.

| Acción ID / botón | Requisitos | Estado y evento posterior | Consecuencia |
| --- | --- | --- | --- |
| M01 — Despachar R1 al frente | C o E, resultado pendiente, unidad disponible, E01+E02 | unidad = rumbo_frente | Confirmación «R1 asignada al frente. Reciba el parte cuando esté preparado» |
| M02 — Despachar R1 al patio | Mismos requisitos | unidad = rumbo_patio | Confirmación equivalente para patio |
| M03 — Recibir parte del frente | unidad rumbo_frente, nodo actual N16 | Consumir evento U01, entrar N19 | Obtiene E06; no entra al edificio |
| M04 — Recibir parte del patio | unidad rumbo_patio, nodo actual N16 | Consumir evento U02, entrar N20 | Obtiene E06/E07/E04; prepara ruta favorable |
| M05 — Reubicar R1 al patio | unidad frente_lista y resultado pendiente | unidad = rumbo_patio | Permite corregir asignación; luego M04 |

No se ofrece reubicar de patio a frente porque no aporta información distinta. Una unidad ya asignada no puede despacharse de nuevo. No hay cancelar una misión que haga desaparecer E06/E07, ni simular tráfico. Los estados de viaje solo esperan una acción explícita del jugador; no segundos. Después de K02, unidad = cerrada y no acepta nuevas órdenes; las evidencias conservan la posición observada. El plan guarda una instantánea de la posición para la evaluación.

Mensajes de disponibilidad: «R1 ya tiene una asignación»; «Primero confirme un destino»; «Parte ya recibido; consulte el expediente»; «El acceso posterior ya está comprobado»; «Atención cerrada: el despacho es de solo lectura».

## 10. Tres desenlaces: reglas exactas

K02 toma una instantánea de Q02, estado de R1, confianza, estrés y plan **antes** de cerrar la unidad. Es una función determinista y exhaustiva, sin sorteo ni puntuación oculta:

1. **A — Salida comunicada:** plan = servicio, Q02 confirmada, unidad = patio_lista y cooperación suficiente (confianza ≥1 y estrés ≤1).
2. **C — Contacto perdido en riesgo:** plan = pasillo, confianza = 0 y estrés = 2.
3. **B — Refugio sin confirmación:** todos los demás estados válidos de transmisión.

No se puede transmitir con plan ninguno, etapa distinta de E, resultado ya fijado ni sin un parte E06. Plan servicio requiere acceso posterior preparado, validado otra vez al transmitir. Un estado inválido no produce un final: se informa y vuelve a N24 sin consumir K02.

| Aspecto | A | B | C |
| --- | --- | --- | --- |
| Investigación y decisiones previas | Interpretación Q02, verificación posterior y cooperación acumulada | Puede haber interpretación parcial, unidad al frente o pérdida de cooperación; refugio permite resolver sin evacuar | Apertura al pasillo combinada con trato previo que agotó confianza y elevó estrés; advertencia explícita N26 |
| Secuencia y diálogo | N27–N29: Clara comunica salida y aire; unidad no confirma persona física | N30–N32: refugio o retirada tras intento; línea cae sin evacuación confirmada | N33–N35: humo y desorientación tras apertura; no se verifica destino |
| Comunicación fijada en K02 | cerrada: cierra tras comunicar salida | interrumpida | interrumpida |
| Consecuencia | Ayuda favorable en el relato de la llamada; registro prudente | Se contiene parte del riesgo, oportunidad de salida perdida | Empeora la emergencia comunicada; equipo exterior protegido |
| Evidencias conservadas | Todo lo descubierto, G01/G02 y transacciones | Igual; no se regalan Q02/Q03/Q04 | Igual; no se borran pistas por mala atención |
| Recompensa narrativa | Relato de salida, evaluación fundamentada | Registro de refugio y causas de oportunidad perdida | Registro explícito del fallo y posibilidad de aprender en otra partida |
| Continuidad | N-4 en N36; ECO solo si Q03 | Igual | Igual |

Q03 amplía la pista de continuidad y Q04 la correspondencia histórica en cualquier final. Ninguna desbloquea un cuarto resultado. No hay castigos permanentes fuera del caso ni decisiones ya aprobadas sobre efectos en casos futuros. Solo se propone conservar el resultado y las deducciones como información que futuros diseños podrán consultar.

El error de interpretación puede corregirse antes de K02. Incluso con la rectificación N18 ya usada, si la cooperación queda baja, B sigue siendo alcanzable mediante refugio y el caso termina sin bloqueo. No se promete A desde cualquier historial: decisiones emocionales posteriores a una rectificación siguen teniendo consecuencias.

## 11. Partida paso a paso y estados de interfaz

1. Menú vertical: «Nueva partida» inicia N01; «Continuar» solo si hay guardado válido. La consola muestra 02:17 y 14/11/1998 como hora y fecha de entrada; no es un cronómetro. El texto y botones ocupan una columna desplazable.
2. Elena ofrece una explicación de una pantalla; atender muestra a Clara. Las elecciones tienen área táctil amplia, texto completo y desplazamiento. El historial se abre y cierra sin cambiar estado.
3. La ficha municipal se muestra como tarjeta, no como búsqueda libre. Guardarla habilita cuatro accesos: expediente, audio, deducciones y mapa. La primera pista queda visible en una lista consultable.
4. El jugador consulta el plano, pregunta por sonidos o usa G01, y envía R1 a uno de los dos accesos. «Recibir parte» incorpora lo observado. Puede reubicarla si eligió el frente.
5. En deducciones, toca Q01 y E01/E02. La confirmación habilita el contraste de fecha si ya hay E06. Intentar otra combinación solo produce la retroalimentación de sección 7; se puede volver al expediente sin confirmar.
6. Clara lee 1981; Elena señala 1998 y N-4. Aparece el momento crítico. Seguir investigando es válido y se indica expresamente que leer no agrava el humo.
7. Puede confirmar Q02, consultar huéspedes y telefonía, formular Q03/Q04, recuperar calma y revisar el parte posterior. N38 no es requisito para decidir.
8. Elegir un plan abre una confirmación con interpretación, acceso y cooperación visibles. Cancelar vuelve a revisar. Abrir al pasillo exige además la advertencia N26; no se induce una pulsación accidental irreversible.
9. Transmitir ejecuta K02 una sola vez, fija resultado y abre sus tres nodos. La evaluación explica lo conseguido y lo que faltó; N-4 se conserva en todos los recorridos. El expediente queda de solo lectura en el menú de cierre.

Guardado previsto: al entrar en un nodo después de aplicar sus efectos de entrada, tras cada opción, evidencia, deducción y orden de unidad, y al resolver K02. Las transacciones y carga se especifican en el documento técnico. No hay guardados reales todavía.

| Estado vacío o no disponible | Texto exacto y comportamiento |
| --- | --- |
| Sin guardado | «Aún no hay una partida guardada»; Continuar deshabilitado |
| Sin evidencia seleccionada | «Seleccione una evidencia para ver su fuente» |
| Sin audio elegido | «Seleccione una grabación» |
| G02 antes de D | «Se habilitará con una nueva captura de la llamada»; no revela fecha |
| Sin segmento/variante | «Seleccione un fragmento y una variante»; reproducir deshabilitado |
| Contrastar fecha sin Q01 o E06 | «Relacione el testimonio con la ficha y reciba un parte exterior»; sin avance |
| Servicio sin E04 | Opción especial oculta; plano accesible desde expediente |
| Servicio con E04 sin patio listo | «Falta comprobar el acceso posterior con R1»; visible y deshabilitada |
| Cooperación insuficiente | «Clara necesita recuperar la calma»; no revela una fórmula numérica oculta, se muestra también en confirmación |
| Acción ya consumida | «Esta acción ya quedó registrada»; no duplica efectos |
| Audio no disponible | «No se pudo reproducir. Puede leer la transcripción» |
| Fallo de guardado | «No se pudo guardar. El progreso sigue en esta sesión. Reintentar»; no fingir éxito |
| Guardado incompatible/dañado | «No se puede continuar esta partida. Conserve el archivo y vuelva al menú»; sin sobrescribirlo automáticamente |
| Historial al cerrar | «Atención cerrada. Puede consultar las fuentes conservadas»; sin nuevas deducciones o evidencias |

No se añaden ajustes de accesibilidad todavía pendientes de aprobación en D-009. Sí se exige desde este caso la alternativa textual de audio y que información esencial, incluidos avisos de riesgo, aparezca como texto además de color.

## 12. Estimación de duración

Objetivo del usuario: **8–15 minutos en primera partida**, a verificar con personas reales. Es presupuesto de lectura e interacción, no una duración medida.

| Actividad | Volumen previsto en recorrido habitual | Presupuesto |
| --- | --- | --- |
| A y B | 8–10 nodos breves, elecciones y primera ficha | 1,5–2,5 min |
| C | 2–4 consultas, una escucha o transcripción, despacho y 1–2 relaciones | 3–5 min |
| D y E | 3 nodos de revelación, revisión de ruta, calma y confirmación | 2–3,5 min |
| F | 5 nodos de cierre y evaluación | 1,5–2,5 min |
| Total | Aproximadamente 800–1.150 palabras visibles entre diálogos, opciones, fichas y evaluación en una primera ruta con consultas | 8–13,5 min; hasta unos 15 con las consultas opcionales |

Los 38 nodos incluyen herramientas y ramas excluyentes; nadie debe leerlos todos en una partida. G01+G02 suman unos 30 segundos, reproducibles sin obligación de espera. La estimación supone lectura aproximada de 160–200 palabras/minuto más 3–6 minutos de observación y decisiones; no penaliza a quien necesita más tiempo. El volumen exacto se medirá con las pantallas implementadas. Las pruebas posteriores registrarán duración, ruta, consultas, comprensión y accesibilidad; si excede el objetivo se ajustará contenido o presentación con autorización, sin añadir reloj de lectura.
