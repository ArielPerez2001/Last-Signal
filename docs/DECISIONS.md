# ÚLTIMA SEÑAL — Registro de decisiones

Las fechas indican el registro documental, no una fecha histórica de aprobación que no conste. Fuentes iniciales: PROMPT 00 y PROMPT 01.

Estados usados: **aprobada** (requisito del usuario), **adoptada para esta fase** (organización documental dentro de la autorización), **diseñada para revisión** (contenido elaborado bajo PROMPT 02 sin aprobación editorial definitiva), **propuesta** y **pendiente de decisión**. Ningún registro documental autoriza por sí solo implementar la fase siguiente.

## D-001 — Desarrollo por fases autorizadas

- **Fecha:** 2026-10-27.
- **Tema:** método de trabajo y límites.
- **Decisión tomada:** trabajar por prompts numerados; consultar instrucciones y documentación, limitar cambios al alcance, verificar, documentar, informar y detenerse.
- **Justificación:** continuidad entre sesiones y control del usuario sobre alcance y producto; PROMPT 00 y 01.
- **Consecuencias:** el roadmap no autoriza fases; cambios narrativos o de requisitos requieren autorización. Commits, pushes, publicaciones y cambios externos también la requieren explícitamente.
- **Estado:** aprobada.

## D-002 — Plataforma y base tecnológica

- **Fecha:** 2026-10-27.
- **Tema:** tecnologías del juego.
- **Decisión tomada:** Android como plataforma principal, Godot 4.x y GDScript; 2D, vertical, español, un jugador y offline.
- **Justificación:** requisitos del contexto maestro.
- **Consecuencias:** interfaz y recursos adecuados para móvil; no se necesita backend. La versión estable concreta del motor permanece abierta en D-008.
- **Estado:** aprobada.

## D-003 — Límite del MVP

- **Fecha:** 2026-10-27.
- **Tema:** alcance del primer juego ejecutable.
- **Decisión tomada:** construir solo el Caso 001, «La habitación 304», con los sistemas mínimos descritos en GDD, tres resultados y guardado local.
- **Justificación:** validar la experiencia investigativa con alcance acotado, conforme a PROMPT 00.
- **Consecuencias:** la campaña de quince casos es expansión posterior. Se excluyen inicialmente multijugador, servidores, IA generativa en tiempo real, publicidad, compras integradas, doblaje completo y 3D.
- **Estado:** aprobada.

## D-004 — Principios de arquitectura

- **Fecha:** 2026-10-27.
- **Tema:** modularidad, contenido y persistencia.
- **Decisión tomada:** preferir escenas reutilizables, interfaz desacoplada, contenido estructurado preferentemente JSON, validación de referencias y condiciones, estado centralizado y guardado local versionado.
- **Justificación:** mantenibilidad, reutilización entre casos y complejidad media indicada por el usuario.
- **Consecuencias:** definir esquemas y módulos en fases técnicas autorizadas; evitar complejidad y dependencias sin necesidad justificada.
- **Estado:** aprobada como principios; detalles de implementación pendientes.

## D-005 — Investigación y análisis de audio

- **Fecha:** 2026-10-27.
- **Tema:** experiencia y complejidad de sistemas.
- **Decisión tomada:** exigir observación y conexión de pruebas; usar grabaciones predefinidas, fragmentos y filtros simulados con alternativas textuales. La tensión avanza por eventos y acciones concretas, sin presión permanente.
- **Justificación:** priorizar decisiones razonadas y accesibilidad conforme al contexto maestro.
- **Consecuencias:** no implementar procesamiento avanzado de señales ni reconocimiento de voz; definir condiciones y consecuencias por caso.
- **Estado:** aprobada.

## D-006 — Continuidad y dirección artística

- **Fecha:** 2026-10-27.
- **Tema:** hechos narrativos y presentación.
- **Decisión tomada:** conservar Puerto Umbral en 1998, incidente de 1981, Estación Nadir, Proyecto ECO y personajes aprobados; comenzar desde investigación criminal creíble y avanzar gradualmente hacia lo inexplicable. Estética de finales de los noventa con tonos oscuros, verde petróleo y ámbar.
- **Justificación:** identidad definida en PROMPT 00.
- **Consecuencias:** registrar los vacíos como abiertos; no inventar causas, biografías o resultados. La coincidencia aritmética del año de clausura del hotel no establece causalidad narrativa.
- **Estado:** aprobada.

## D-007 — Organización documental inicial

- **Fecha:** 2026-10-27.
- **Tema:** persistencia entre sesiones.
- **Decisión tomada:** usar `AGENTS.md` en la raíz y `GDD.md`, `STORY_BIBLE.md`, `ROADMAP.md`, `PROGRESS.md` y `DECISIONS.md` en `docs/`.
- **Justificación:** entregables expresamente solicitados en PROMPT 01; carpeta inicial vacía sin estructura equivalente.
- **Consecuencias:** consultar y mantener documentos pertinentes en las fases siguientes. No crear aún la estructura de Godot ni inicializar Git.
- **Estado:** adoptada para esta fase.

## D-008 — Selección de versión del motor

- **Fecha:** 2026-10-27.
- **Tema:** versión estable concreta de Godot 4.x.
- **Decisión tomada:** inicialmente pendiente; resuelta en la fase 03 con Godot 4.7.2 estable, según D-018.
- **Justificación:** el contexto maestro la deja explícitamente por definir.
- **Consecuencias:** no instalar motor ni herramientas ni fijar compatibilidad específica en esta fase.
- **Estado:** resuelta por D-018 al ejecutar PROMPT 03; se conserva el registro de su situación inicial.

## D-009 — Público y accesibilidad adicional

- **Fecha:** 2026-10-27.
- **Tema:** destinatarios y mejoras de interfaz.
- **Decisión tomada:** se propone dirigir el juego a personas interesadas en misterio narrativo e investigación razonada en móvil, y considerar texto ajustable, información que no dependa solo del color y volúmenes independientes.
- **Justificación:** precisar el público solicitado en GDD y ampliar la comodidad de lectura e interacción móvil.
- **Consecuencias:** requieren aprobación antes de convertirse en requisitos. No fijan edad objetivo, clasificación, controles definitivos ni alcance adicional implementado.
- **Estado:** propuesta.

## D-010 — Modelo comercial

- **Fecha:** 2026-10-27.
- **Tema:** monetización y distribución.
- **Decisión tomada:** modelo y canal sin definir; se conservan las etapas futuras 20–22 del roadmap.
- **Justificación:** PROMPT 01 las pide como planificación; PROMPT 00 excluye publicidad y compras integradas del MVP.
- **Consecuencias:** ninguna integración comercial ni operación de publicación está autorizada; cualquier decisión posterior debe respetar el alcance o registrar su modificación aprobada.
- **Estado:** pendiente de decisión.

## D-011 — Alcance específico del PROMPT 02

- **Fecha:** 2026-10-27.
- **Tema:** autorización de diseño y premisa ampliada.
- **Decisión tomada:** diseñar documentalmente todo el Caso 001 en seis etapas, con guion, reglas, modelo de datos y pruebas. Se incorporan los requisitos explícitos Hotel Mirador, llamada a las 02:17, golpes en la puerta y clausura tras incendio de 1981; objetivo estimado de 8–15 minutos de primera partida.
- **Justificación:** autorización y requisitos directos del PROMPT 02, posteriores al estado inicial documentado en 01.
- **Consecuencias:** se actualiza la restricción temporal de AGENTS para permitir este diseño; continúan prohibidos código, escenas, recursos, instalaciones y comienzo de 03. La duración deberá medirse después.
- **Estado:** aprobada como alcance y premisa del usuario; no supone aprobación de todos los detalles elaborados.

## D-012 — Identidad, fechas y localización del caso

- **Fecha:** 2026-10-27.
- **Tema:** continuidad local necesaria para el guion.
- **Decisión tomada:** proponer a Clara Salcedo como interlocutora, Inés Duarte como jefa de R1, Frente Costero y Paseo del Faro 18 como ubicación. La consola recibe el 14/11/1998 y el recibo y fuego se sitúan el 14/11/1981.
- **Justificación:** concretar las fuentes y mantener diecisiete años exactos; identificar personajes, mapa y registros sin diseñar otros casos.
- **Consecuencias:** se conserva incertidumbre sobre la naturaleza de Clara y su destino. No se fija la fecha exacta del incidente general de Nadir ni se lo equipara al incendio del hotel. El usuario puede revisar nombres y fechas antes de su aprobación editorial.
- **Estado:** diseñada para revisión.

## D-013 — Peligro, deducciones y tres resultados

- **Fecha:** 2026-10-27.
- **Tema:** investigación justa y consecuencias.
- **Decisión tomada:** el peligro comunicado es humo en el pasillo; golpes y voz se reinterpretan como aviso de bomberos. Plano y unidad verifican una ruta posterior. El resultado combina plan, deducción de amenaza, posición de R1 y cooperación derivada de confianza/estrés.
- **Justificación:** hacer necesarias varias fuentes y evitar que la última respuesta o una pista final secreta determinen por sí solas el resultado.
- **Consecuencias:** A registra salida comunicada; B refugio sin evacuación confirmada; C pérdida de contacto tras apertura peligrosa con vínculo deteriorado. Q02 cambia la instrucción genérica por una indicación precisa, de modo que confirmar la relación tiene una consecuencia concreta. No se verifica muerte, rescate físico en 1998 ni modificación del pasado.
- **Estado:** diseñada para revisión.

## D-014 — Pista N-4 y límite de la revelación

- **Fecha:** 2026-10-27.
- **Tema:** conexión con el misterio central.
- **Decisión tomada:** conservar la cabecera N-4 antes de la decisión final y proponer un anexo del 10/11/1981 que menciona Estación Nadir / Proyecto ECO. Una deducción opcional relaciona ambas fuentes.
- **Justificación:** ofrecer una pista persistente en los tres resultados y recompensar investigación adicional sin revelar el fenómeno.
- **Consecuencias:** solo se afirma coincidencia documental; no se establece causa del fuego, propósito de ECO ni intervención de La Voz. Omitir el anexo o la deducción no bloquea A. La revisión editorial de esta conexión sigue pendiente.
- **Estado:** diseñada para revisión.

## D-015 — Estado mínimo, eventos y persistencia

- **Fecha:** 2026-10-27.
- **Tema:** contrato técnico del caso.
- **Decisión tomada:** nueve campos persistentes de caso, cooperación derivada, dos grabaciones con transcripciones, una unidad con dos destinos y cuatro deducciones. Los únicos avances críticos son contrastar fechas y transmitir el plan; la recepción de partes es explícita. Guardado propuesto transaccional con instantánea de resolución y claves idempotentes.
- **Justificación:** complejidad media, ausencia de penalización por lectura y prevención de duplicaciones o estados incoherentes.
- **Consecuencias:** lectura, consultas y combinaciones incorrectas no avanzan peligro; se puede corregir despacho o plan antes de transmitir. El diseño declara contratos y ejemplos en Markdown, sin archivos de datos funcionales ni sistemas ejecutables.
- **Estado:** diseñada para revisión; implementación pendiente de sus fases autorizadas.

## D-016 — Estado real de la fase documental

- **Fecha:** 2026-10-27.
- **Tema:** aceptación y evidencia de validación.
- **Decisión tomada:** dar por elaborados y revisados documentalmente los tres entregables de PROMPT 02; conservar la etapa 02 en proceso hasta la revisión editorial del usuario exigida por su criterio de aceptación existente.
- **Justificación:** distinguir trabajo documental realizado, revisión del producto y pruebas reales aún imposibles sin implementación.
- **Consecuencias:** las trazas A/B/C, el grafo y las condiciones pueden revisarse en documentos. Guardado, audio, interfaz, duración y Android siguen sin pruebas ejecutables. No se cambia el criterio de aceptación para declarar una aprobación inexistente ni se inicia 03.
- **Estado:** adoptada para esta fase.

## Actualización de decisiones al iniciar PROMPT 03

Los registros D-012–D-015 describen el estado de diseño al entregar 02. Su aprobación editorial posterior consta en D-017. D-016 conserva la revisión pendiente histórica, resuelta por esa misma aprobación.

## D-017 — Aprobación de las etapas previas y autorización técnica

- **Fecha:** 2026-10-27.
- **Tema:** continuidad de autorización y seguimiento.
- **Decisión tomada:** registrar la aprobación expresa de los PROMPTS 00, 01 y 02 y la autorización para crear y verificar exclusivamente la base técnica de 03.
- **Justificación:** el usuario declara en PROMPT 03 que las etapas previas están aprobadas y que comienza formalmente la programación con alcance limitado.
- **Consecuencias:** la etapa 02 pasa a completada. Las restricciones de AGENTS que aún prohibían iniciar 03 y las menciones de revisión pendiente se actualizan como estado, sin reescribir el Caso 001. No se autoriza 04 ni se amplía el MVP. Se resuelve la condición de revisión pendiente registrada en D-016.
- **Estado:** aprobada por el usuario mediante PROMPT 03.

## D-018 — Motor y configuración base verificados

- **Fecha:** 2026-10-27.
- **Tema:** entorno técnico y compatibilidad.
- **Decisión tomada:** utilizar la instalación existente de Godot `4.7.2.stable.official.ed1daf0bf`, Compatibility en escritorio y móvil, lienzo 720 × 1280, `canvas_items`, `expand`, Portrait y español. Ventana inicial de escritorio de 360 × 640 para depuración.
- **Justificación:** coincide con la versión preferida; los valores admitidos se verificaron por introspección en el propio motor y el arranque gráfico confirmó Compatibility/OpenGL.
- **Consecuencias:** no requiere instalaciones, cambios de versión ni recursos externos. Denominación interna `ultima_senal` para el directorio local del motor, sin identificador Android comercial ni sistema de guardado. Resuelve D-008. Pruebas Android siguen pendientes.
- **Estado:** adoptada y verificada dentro de PROMPT 03.

## D-019 — Entrada mínima y Theme compartido

- **Fecha:** 2026-10-27.
- **Tema:** estructura, interfaz y límites de implementación.
- **Decisión tomada:** `main.tscn` declarativa con raíz Control, contenedores y anclajes; un Theme reutilizable con fondo oscuro, verde petróleo y ámbar; fuente incorporada. Crear solo carpetas con archivos necesarios y excluir documentación de la importación del motor.
- **Justificación:** pantalla mínima de inicialización solicitada, adaptable y coherente con el GDD, sin anticipar la biblioteca de componentes ni sistemas narrativos.
- **Consecuencias:** no hay script en la escena, botones, menú completo ni mecánicas. Las futuras carpetas de scripts/datos se crearán con contenido real autorizado. `.gitignore` excluye cachés y exportaciones, conserva fuentes y UID; no se inicializa Git.
- **Estado:** adoptada e implementada dentro de PROMPT 03.

## D-020 — Evidencia de arranque y límites de plataforma

- **Fecha:** 2026-10-27.
- **Tema:** validación reproducible.
- **Decisión tomada:** conservar un auxiliar `tests/bootstrap_smoke.gd`, tres capturas reales y los comandos en TECHNICAL_SETUP. Verificar explícitamente dimensiones de Window y lienzo, además de recursos, textos y ausencia de funcionalidades anticipadas.
- **Justificación:** una primera invocación headless mostró ventana ficticia de 64 × 64; no bastaba confiar en `--resolution` ni en la ausencia de errores para acreditar adaptabilidad.
- **Consecuencias:** el auxiliar fija el tamaño solicitado y lo comprueba. Pasaron importación, arranque normal, tres pruebas headless y tres gráficas en 720 × 1280, 1080 × 1920 y 1080 × 2400. Las imágenes fueron inspeccionadas; estos resultados de Windows no acreditan Android, APK o dispositivo real.
- **Estado:** adoptada y verificada dentro de PROMPT 03.

## D-021 — Autorización de la interfaz base

- **Fecha:** 2026-10-27.
- **Tema:** alcance del PROMPT 04.
- **Decisión tomada:** registrar la aprobación de 00–03 y construir únicamente menú, consola, cuatro secciones vacías y navegación funcional, reutilizando el proyecto existente.
- **Justificación:** autorización expresa de PROMPT 04, que sustituye la espera de autorización registrada al cerrar 03.
- **Consecuencias:** se conserva la configuración de Godot y el diseño del Caso 001; no se inicia una partida ni se implementan mecánicas, guardado, audio o mapas funcionales. PROMPT 05 sigue sin autorización.
- **Estado:** aprobada por el usuario mediante PROMPT 04.

## D-022 — Vistas persistentes y navegación local

- **Fecha:** 2026-10-27.
- **Tema:** estructura de interfaz.
- **Decisión tomada:** mantener main.tscn como raíz Control, con menú, consola y pantalla informativa reutilizable. Instanciar una vez los cuatro paneles de consola y cambiar su visibilidad; scripts limitados a interacción y presentación.
- **Justificación:** evitar duplicaciones y una arquitectura global excesiva para cuatro pestañas.
- **Consecuencias:** sin autoloads, pila de escenas ni estado de juego; al ingresar se abre Llamadas. Configuración y Créditos comparten una pantalla que regresa al menú y restaura foco. Cambios inmediatos, sin transiciones que retrasen la navegación.
- **Estado:** adoptada e implementada en PROMPT 04.

## D-023 — Estilo y accesibilidad de navegación

- **Fecha:** 2026-10-27.
- **Tema:** presentación y uso táctil/teclado.
- **Decisión tomada:** ampliar el Theme existente con la paleta de PROMPT 04, botones grandes, foco visible, iconos propios y marca textual ACTIVA. Continuar permanece deshabilitado; paneles vacíos explican disponibilidad. Añadir scroll vertical y margen seguro compartido.
- **Justificación:** identidad nocturna de comunicaciones y requisitos explícitos de no depender solo del color o iconos.
- **Consecuencias:** la distinción de estados por texto y forma pasa a ser requisito aprobado en 04; el tamaño de texto ajustable y volúmenes independientes de D-009 siguen sin implementarse. No se descargan recursos. La adaptación Android está programada, pero su verificación nativa queda pendiente; no equivale a prueba en teléfono.
- **Estado:** adoptada e implementada; requisito de accesibilidad autorizado por PROMPT 04.

## D-024 — Verificación de navegación y regresión

- **Fecha:** 2026-10-27.
- **Tema:** pruebas reproducibles y límites de evidencia.
- **Decisión tomada:** conservar las comprobaciones de configuración de bootstrap, actualizar su expectativa de arranque al menú y añadir navigation_smoke para clics, teclado, toque simulado, retroceso, scroll y ausencia de duplicaciones. Revisar siete vistas en cuatro resoluciones con capturas reales.
- **Justificación:** el cambio autorizado introduce interacción y vuelve obsoletas las aserciones de pantalla estática y ausencia de botones de 03; ver dibujos o emitir señales directamente no acredita el recorrido GUI.
- **Consecuencias:** las pruebas finales pasan con 106 nodos descendientes estables y 28 capturas inspeccionadas. Se corrigen el alcance de una constante del auxiliar, el ciclo de foco y la secuencia de inyección de eventos. La simulación de toque y de retroceso en escritorio no acredita hardware Android, recortes seguros o gesto físico.
- **Estado:** adoptada y verificada en PROMPT 04.

## D-025 — Alcance autorizado del motor narrativo

- **Fecha:** 2026-10-27.
- **Tema:** autorización de PROMPT 05.
- **Decisión tomada:** registrar la aprobación de 00–04 e implementar únicamente núcleo narrativo independiente, sesión temporal, JSON técnico y pruebas automatizadas aisladas.
- **Justificación:** alcance explícito del nuevo prompt, que sustituye la espera de autorización al cerrar 04.
- **Consecuencias:** la interfaz normal no se modifica ni conecta al motor; el Caso 001 sigue sin archivo funcional. No se autoriza persistencia ni ninguna implementación de 06–12.
- **Estado:** aprobada mediante PROMPT 05.

## D-026 — Esquema canónico 1 y correspondencia con preproducción

- **Fecha:** 2026-10-27.
- **Tema:** formato de contenido y validación.
- **Decisión tomada:** adoptar schema_version 1 con case_id, content_version, title, initial_node, initial_state, declaraciones de variables/catálogos y nodos dialogue, transition y ending. Mantener los significados de condiciones y efectos aprobados y documentar sus nombres canónicos y alias.
- **Justificación:** concretar el formato requerido por PROMPT 05 sin improvisar reglas del Caso 001. Se conservan all/any, visible_when/enabled_when, límites, claves únicas y aliases at_least/at_most.
- **Consecuencias:** id/entry_node de caso se representan por case_id/initial_node. Avance y terminación genéricos se expresan con destinos/nodos, no con ejecución de métodos desde JSON. Campos futuros de audio, despacho, variantes visuales y resolución específica K02 no se importan silenciosamente. Las adaptaciones y límites se detallan en NARRATIVE_ENGINE; ningún documento del caso se reescribe.
- **Estado:** adoptada e implementada dentro de PROMPT 05.

## D-027 — Sesión temporal transaccional e idempotencia

- **Fecha:** 2026-10-27.
- **Tema:** ejecución y consistencia de estado.
- **Decisión tomada:** procesar cada operación sobre una copia y publicar solo al alcanzar un nodo estable válido. Usar registros por visita/efecto, once_key de sesión, ID de acciones y revisión opcional al seleccionar. Exponer únicamente snapshots y vistas separados del estado interno.
- **Justificación:** impedir efectos por consultas, duplicados por vistas obsoletas, eventos parciales y corrupción por errores de transición.
- **Consecuencias:** errores revierten cursor, variables, evidencias, eventos y registros del candidato. Reentradas legítimas tienen otra visita; efectos globalmente únicos requieren clave o condición de acción. Revisiones e ID de evento son locales a cada sesión; reiniciar limpia registros. No hay escritura ni restauración de partidas.
- **Estado:** adoptada, implementada y probada en PROMPT 05.

## D-028 — Contrato seguro de eventos y ejecución automática

- **Fecha:** 2026-10-27.
- **Tema:** integración futura sin dependencias gráficas.
- **Decisión tomada:** usar seis componentes RefCounted, señales de carga/nodo/opciones/estado/evidencia/evento/final/error y solicitudes de evento registradas hasta confirmación explícita. Limitar a 64 transiciones consecutivas y condiciones de profundidad 32.
- **Justificación:** núcleo reutilizable sin autoloads, escena obligatoria, código dinámico o simulación de sistemas que aún no existen.
- **Consecuencias:** un evento sin consumidor sigue pendiente; confirmarlo no demuestra despacho o reproducción. Mutaciones reentrantes durante señales se rechazan. La validación detecta estructuras y rutas, sin resolver todas las condiciones; los fallos restantes se controlan en ejecución.
- **Estado:** adoptada, implementada y probada en PROMPT 05.

## D-029 — Evidencia de pruebas y conservación de interfaz

- **Fecha:** 2026-10-27.
- **Tema:** aceptación de fase 05.
- **Decisión tomada:** verificar el núcleo mediante dos suites SceneTree sin plugins externos, un caso técnico y seis fixtures; conservar las pruebas anteriores y ejecutar regresión de navegación y arranque.
- **Justificación:** cubrir las 17 pruebas solicitadas, errores de autoría, rollback, determinismo, consumo de eventos y ausencia de regresión visual.
- **Consecuencias:** pasan 151 comprobaciones del motor y 334 de validación, 485 en total. Bootstrap/navegación pasan headless en cuatro resoluciones; se revisan siete capturas gráficas nuevas a 720 × 1280. Las otras tres resoluciones no se revisan gráficamente de nuevo en 05. Android y persistencia siguen pendientes de sus fases.
- **Estado:** adoptada y verificada dentro de PROMPT 05.

## D-030 — Repositorio remoto autorizado

- **Fecha:** 2026-10-27.
- **Tema:** versionado y subida del proyecto existente.
- **Decisión tomada:** inicializar Git local con rama main, configurar origin como https://github.com/ArielPerez2001/Last-Signal.git y preparar el primer commit para su subida, conforme a la petición explícita del usuario posterior a PROMPT 05.
- **Justificación:** conservar en el repositorio indicado el proyecto y sus entregables actuales. El remoto se comprobó vacío antes de inicializar; no hay historial que sustituir.
- **Consecuencias:** incluir fuentes, documentación, pruebas y capturas; respetar .gitignore y excluir caché/credenciales/exports. Usar push normal, sin force. No se modifica el juego ni se inicia PROMPT 06; no se autoriza publicar cambios futuros automáticamente.
- **Estado:** inicialización y commit local realizados; push pendiente por HTTP 403 para arpe22. No se forzó ni completó la subida.

## D-031 — Alcance autorizado de persistencia

- **Fecha:** 2026-10-28.
- **Tema:** autorización de PROMPT 06.
- **Decisión tomada:** registrar aprobación de 00–05 e implementar exclusivamente estado persistente local, recuperación y autoguardado por API con pruebas aisladas.
- **Justificación:** autorización explícita del nuevo prompt, que sustituye la espera de 06.
- **Consecuencias:** Continuar deshabilitado, escenas/UI sin cambios, Caso 001 sin integrar y ninguna implementación de 07; sin commits, pushes, permisos Android o dependencias nuevas.
- **Estado:** aprobada e implementada en PROMPT 06.

## D-032 — Formato de guardado 1 y compatibilidad estricta

- **Fecha:** 2026-10-28.
- **Tema:** esquema persistente y detección de cambios.
- **Decisión tomada:** JSON con save_version 1, game_id, caso, content_version, narrative_schema_version separado, fingerprint SHA-256 del contenido, fecha UTC y los 17 campos reales de sesión de 05.
- **Justificación:** conservar todos los efectos/consumos y detectar contenido modificado incluso sin incremento de versión; no inventar sistemas futuros ni flags redundantes.
- **Consecuencias:** coincidencia exacta de contenido, enteros JSON normalizados solo tras validar tipo/rango, extensiones desconocidas rechazadas, sin migración automática ni rutas del dispositivo en datos. Límites: 4 MiB, profundidad 32, 250000 valores y 2048 decisiones/consumos confirmados.
- **Estado:** adoptada, implementada y probada.

## D-033 — Restauración lógica y verificación del historial

- **Fecha:** 2026-10-28.
- **Tema:** importación sin duplicar efectos.
- **Decisión tomada:** añadir validate_state_snapshot y restore_state_snapshot al motor; validar estructura y comparar con una reconstrucción en una instancia aislada sin observadores antes de reemplazar toda la sesión viva.
- **Justificación:** los registros de 05 permiten verificar decisiones/consumos intercalados y todo el estado, evitando reparaciones silenciosas y estados inventados.
- **Consecuencias:** la reconstrucción no afecta al juego vivo ni al disco. La importación emite session_restored, node_changed y choices_changed, sin eventos/evidencias/final nuevos; mutaciones reentrantes bloqueadas. El núcleo sigue sin lectura/escritura de partidas y las pruebas anteriores pasan.
- **Estado:** adoptada, implementada y probada.

## D-034 — Temporal, respaldo y recuperación conservadora

- **Fecha:** 2026-10-28.
- **Tema:** integridad de archivos locales.
- **Decisión tomada:** SaveManager administra una carpeta canónica bajo user:// y cuatro nombres fijos de slot_01. Escribe/valida temporal, confirma respaldo del principal válido anterior y solo entonces intenta sustituir/verificar principal.
- **Justificación:** no destruir el único checkpoint válido ni rotar corrupción al respaldo; inspección/carga no deben cambiar archivos.
- **Consecuencias:** cargas intentan principal y respaldo e informan del origen sin reparar originales. Un principal inválido sin respaldo compatible exige reemplazo explícito. No se promete atomicidad universal, durabilidad eléctrica o bloqueo entre procesos. delete_save conserva respaldo por defecto y true exige borrarlo también expresamente.
- **Estado:** adoptada, implementada y probada en escritorio Windows.

## D-035 — Autoguardado en puntos estables y ciclo de vida opcional

- **Fecha:** 2026-10-28.
- **Tema:** coordinación sin reentradas ni escrituras redundantes.
- **Decisión tomada:** conectar state_changed a dirty/llamada diferida coalescida; guardar fuera de callbacks, después de decisiones/transiciones/finales completos y consumos. Añadir SaveLifecycle opcional para pausa/foco/cierre y salida controlada.
- **Justificación:** una acción confirma primero toda su lógica; las señales de presentación no son checkpoints nuevos. Android puede terminar sin notificación final.
- **Consecuencias:** fallo mantiene memoria y dirty para reintento explícito, sin bucle. Bloqueos por carpeta dentro del proceso, servicio de hilo principal. Restaurar no reescribe archivos; borrar desactiva autoguardado. Adaptador no se añade a Main ni cierra el juego por su cuenta; simulaciones de escritorio no equivalen a Android.
- **Estado:** adoptada, implementada y probada con el caso técnico.

## D-036 — Pruebas aisladas y límites de evidencia

- **Fecha:** 2026-10-28.
- **Tema:** verificación reproducible de persistencia.
- **Decisión tomada:** dos suites de guardado con carpetas únicas user://save_tests, fallos de E/S inyectados y reales controlados, dos procesos separados y repetición de las suites narrativas y navegación previa.
- **Justificación:** demostrar progreso durable sin depender de memoria anterior y sin tocar partidas auténticas; conservar la distinción entre validación headless, capturas y plataforma móvil.
- **Consecuencias:** documentación de resultados reales en PROGRESS/SAVE_SYSTEM. Revisión gráfica de siete vistas a 720 × 1280 y regresión headless en cuatro tamaños. No se prueba corte eléctrico, disco físicamente lleno, APK, rendimiento o dispositivo Android; pruebas PS específicas del Caso 001 siguen futuras.
- **Estado:** adoptada y verificada en PROMPT 06.

## D-037 — Alcance autorizado de conversaciones

- **Fecha:** 2026-10-28.
- **Tema:** autorización de PROMPT 07.
- **Decisión tomada:** aprobar el estado 00–06 e implementar solamente controlador/presentación de llamadas conectados al motor y guardado, demostración no canónica y pruebas de integración.
- **Justificación:** alcance explícito del prompt; sustituye la espera de autorización al cerrar 06.
- **Consecuencias:** Llamadas deja de ser placeholder; no se integra Caso 001, audio, mapa, despacho, deducciones o resultados oficiales. Continuar sigue deshabilitado; sin commits, pushes, instalaciones o exportaciones.
- **Estado:** aprobada e implementada en PROMPT 07.

## D-038 — Controlador visual y propiedad de sesión

- **Fecha:** 2026-10-28.
- **Tema:** arquitectura y ciclo de vida.
- **Decisión tomada:** CallController RefCounted posee motor/gestor; CallsPanel presenta sus vistas en la instancia existente y posee SaveLifecycle opcional. Estados IDLE, INCOMING, CONNECTED, ENDED y ERROR; no añadir conexión telefónica al esquema narrativo.
- **Justificación:** el motor sigue siendo la única autoridad narrativa y la consola ya conserva paneles entre pestañas; no hacen falta autoloads o reescribir navegación.
- **Consecuencias:** responder inicia una sola sesión, errores con sesión válida no la destruyen, navegación no ejecuta decisiones. dispose desconecta señales y evita ciclos de referencias. Cabecera común refleja estado de llamada con un cambio mínimo.
- **Estado:** adoptada, implementada y probada.

## D-039 — Transcripción derivada de registros confirmados

- **Fecha:** 2026-10-28.
- **Tema:** historial y reanudación.
- **Decisión tomada:** añadir get_conversation_history al motor reutilizando su reconstrucción aislada de 06; proyectar nodos estables y elecciones reales con ID de visita/revisión.
- **Justificación:** el snapshot existente permite reconstruir contenido exacto con consumos intercalados; guardar otra copia introduciría otra fuente de verdad.
- **Consecuencias:** no cambian esquemas ni save_version 1. Transiciones, ramas no visitadas, rechazos y consumos no producen líneas. El registro acredita presentación lógica confirmada, no lectura humana o dibujo completo antes de una interrupción. No se repiten efectos en la sesión viva.
- **Estado:** adoptada, implementada y probada.

## D-040 — Demostración de desarrollo y separación de partidas

- **Fecha:** 2026-10-28.
- **Tema:** contenido/acceso y seguridad de datos de prueba.
- **Decisión tomada:** crear ui_call_demo.json sin historia oficial, con interlocutor desconocido, operador técnico, condiciones, evidencia y dos desenlaces. Acciones solo visibles/habilitadas en desarrollo; usar user://call_demo y pruebas únicas bajo user://save_tests/.
- **Justificación:** el caso de núcleo de 05 no cubría todos los participantes/textos largos de la prueba visual. El usuario exige evitar mezclar campaña y demostración.
- **Consecuencias:** constructor rechaza carpeta de producción. El menú queda intacto; Reiniciar prueba solicita explícitamente borrado de los archivos de esa ranura y no de otras partidas. No hay rechazo de llamada con consecuencias o nuevas misiones oficiales.
- **Estado:** adoptada, implementada y probada.

## D-041 — Presentación, entrada y desplazamiento

- **Fecha:** 2026-10-28.
- **Tema:** legibilidad e interacción.
- **Decisión tomada:** reutilizar Theme; transcripción numerada sin globos, respuestas multilínea de mínimo 88 unidades lógicas, dos áreas de scroll y navegación inferior fija. Bloquear repeticiones del turno y gestos dobles clasificados por Godot; enviar ID/revisión al motor.
- **Justificación:** preservar identidad y lectura móvil sin temporizadores narrativos ni duplicar condiciones. Conservar el punto del lector cuando consulta mensajes antiguos.
- **Consecuencias:** condiciones bloqueadas muestran motivo textual; historial nuevo revela intervención actual tras layout, actualizaciones idénticas no duplican controles. Errores de disco permiten reintentar sin reejecutar elección; detalles en API y logs de desarrollo. Sin estadísticas internas o sonidos nuevos.
- **Estado:** adoptada, implementada y probada en escritorio.

## D-042 — Evidencia reproducible de integración

- **Fecha:** 2026-10-28.
- **Tema:** validación de PROMPT 07.
- **Decisión tomada:** dos suites nuevas de controlador/GUI con mouse/toque simulado, rutas aisladas, recuperación y errores; conservar las cuatro suites previas y ejecutar navegación/arranque y captura gráfica en cuatro tamaños.
- **Justificación:** demostrar integración real además de apariencia, sin confundir desktop/headless con Android.
- **Consecuencias:** 68 comprobaciones de controlador y 402 de integración base, junto con 1504 anteriores; 40 capturas gráficas inspeccionadas. Cifras de otras proporciones/capturas registradas por ejecución. No se acredita Android físico, exportación release, rendimiento móvil o accesibilidad de lector de pantalla.
- **Estado:** adoptada y verificada en PROMPT 07.

## D-043 — Alcance autorizado de investigación

- **Fecha:** 2026-10-28.
- **Tema:** autorización de PROMPT 08.
- **Decisión tomada:** aprobar 00–07 y ejecutar exclusivamente evidencias, expedientes/deducciones, integración con los servicios existentes, demo no canónica y pruebas/documentación.
- **Justificación:** autorización expresa del nuevo prompt; sustituye la espera de 08 al cerrar 07.
- **Consecuencias:** Expedientes deja de ser placeholder. No se integra Caso 001 ni audio, mapas/despacho, resultados definitivos o fases posteriores. Continuar deshabilitado; sin commits/pushes, instalaciones o cambios externos. Detenerse antes de 09.
- **Estado:** aprobada e implementada en PROMPT 08.

## D-044 — Esquema 2, catálogo central y proyecciones

- **Fecha:** 2026-10-28.
- **Tema:** datos de investigación y compatibilidad.
- **Decisión tomada:** esquema narrativo 2 añade investigation con fichas, acciones y reglas, conservando lectura del esquema 1 sin modificaciones de sus casos. Ficha por ID de evidence_catalog; cinco categorías centrales, importancia solo de autoría y recursos de imagen opcionales restringidos.
- **Justificación:** contrato explícito que detecta referencias incompletas y evita inventar metadatos para contenido anterior.
- **Consecuencias:** UI recibe solo fichas/categorías descubiertas y acciones disponibles, sin importancia o total oculto. Detalle de ID oculto/desconocido es indistinguible. Ausencia de imagen admite advertencia/fallback; rutas inseguras se rechazan. Conjunto exacto de dos/tres evidencias, sin reglas ambiguas; la UI de esta fase selecciona dos.
- **Estado:** adoptada, implementada y probada; contrato en INVESTIGATION_SYSTEM.

## D-045 — Acciones externas atómicas y diario único

- **Fecha:** 2026-10-28.
- **Tema:** confirmación de investigación e idempotencia.
- **Decisión tomada:** motor confirma consultas/deducciones en candidato con el EffectProcessor existente, registra ID global único en executed_actions y transaction_log y valida que quede una opción elegible. No modifica cursor/visitas ni reentra al nodo.
- **Justificación:** evitar otro estado paralelo y conservar la validación completa del historial, efectos únicos y actualización inmediata de diálogo.
- **Consecuencias:** choice_id puede designar acción/deducción en esquema 2; ámbito de efecto investigation:<id>. Fallo revierte todo. Confirmación publica state_changed, avisos, deduction_confirmed y choices_changed, sin node_changed. La transcripción omite acciones externas, sin mensajes inventados; preview/consultas/repeticiones no mutan. ConditionEvaluator/EffectProcessor permanecen intactos.
- **Estado:** adoptada, implementada y probada, incluido rollback por diálogo bloqueado.

## D-046 — Formato de guardado 2 sin migración implícita

- **Fecha:** 2026-10-28.
- **Tema:** persistencia de investigación.
- **Decisión tomada:** esquema narrativo 2 escribe/lee save_version 2; esquema 1 conserva formato 1. Misma envoltura y 17 campos; conclusiones derivadas de executed_actions, sin catálogos o listas persistentes duplicados.
- **Justificación:** versionar la nueva semántica del diario y su reconstrucción sin invalidar artificialmente los casos anteriores ni prometer migradores inexistentes.
- **Consecuencias:** versión/contenido/fingerprint exactos. Rechazo conserva memoria y originales, con respaldo compatible conforme a 06. Reconstrucción aislada revalida acciones/condiciones, no produce efectos vivos al restaurar. Algoritmo de archivos/cotas/autoguardado preservado; 2048 operaciones también incluye acciones externas.
- **Estado:** adoptada y probada con formato 2 y regresión de formato 1.

## D-047 — Sesión compartida, interfaz y aislamiento de demo

- **Fecha:** 2026-10-28.
- **Tema:** composición y acceso de desarrollo.
- **Decisión tomada:** EvidenceManager/DeductionManager son fachadas del motor de CallController. DispatchConsole enlaza el panel existente y escucha controller_replaced; no hay otro motor/SaveManager. Nueva demo usa user://investigation_demo y botón Prueba de investigación; la anterior mantiene user://call_demo.
- **Justificación:** expediente y conversación deben ver las mismas consecuencias; pruebas y demostraciones no deben tocar partidas oficiales.
- **Consecuencias:** detalle/filtros/selección temporales, sin efectos ni escrituras; dos seleccionables, conclusiones consultables y cierre en solo lectura. Theme/iconos existentes y navegación fija; errores de E/S con reintento del mismo gestor. Pruebas solo user://save_tests con prefijos únicos. Desconexión/dispose al reemplazar/cerrar.
- **Estado:** adoptada, implementada y probada en escritorio.

## D-048 — Verificación de investigación y límites reales

- **Fecha:** 2026-10-28.
- **Tema:** aceptación de PROMPT 08.
- **Decisión tomada:** tres suites nuevas, regresión intacta de motor/guardado/llamadas, cuatro tamaños de integración/navegación y 56 capturas gráficas reales inspeccionadas. Correspondencia de los 24 grupos en PROGRESS.
- **Justificación:** verificar estado, GUI y recuperación, distinguiendo aserciones de escenarios y simulación de dispositivo.
- **Consecuencias:** 69 comprobaciones de evidencias, 88 de deducciones y 2349 de integración base, más 1974 anteriores: 4480 de referencia sin volver a sumar resoluciones/capturas. Las variantes altas tienen dos aserciones menos por scroll. Sin prueba Android/APK/release, cortes eléctricos o rendimiento móvil. Se documentan fallos de auxiliares corregidos; no se declaran como ensayos superados las ejecuciones fallidas.
- **Estado:** adoptada y verificada en PROMPT 08.

## D-049 — Autorización exclusiva de PROMPT 09A

- **Fecha:** 2026-10-28.
- **Tema:** alcance de grabaciones de investigación.
- **Decisión tomada:** aprobar 00–08 e implementar analizador, reproducción real/variantes locales, examen y descubrimiento, integración existente y pruebas/documentación. La nueva autorización sustituye la espera/prohibición temporal de audio al cerrar 08.
- **Justificación:** alcance expreso de PROMPT 09A, separado de 09B.
- **Consecuencias:** Audio deja de ser placeholder; no se integran Caso 001, voces/subtítulos de llamadas, TTS, APIs externas, mapa/despacho o resultados. No commits/pushes, instalaciones o descargas. Detenerse antes de 09B y 10.
- **Estado:** aprobada e implementada en 09A.

## D-050 — Catálogo de audio dentro del esquema 3

- **Fecha:** 2026-10-28.
- **Tema:** autoría, referencias y disponibilidad.
- **Decisión tomada:** esquema 3 extiende 2 con audio_analysis (recordings/discovery_rules), incluido en el fingerprint del caso; demo completa en data/audio/audio_analysis_demo.json. Validación sonora separada y condiciones/referencias reutilizadas del motor.
- **Justificación:** evitar un catálogo externo que cambie reglas sin afectar compatibilidad, sin introducir otro lenguaje de condiciones.
- **Consecuencias:** ID únicos, fichas declaradas, intervalos acotados, formatos/rutas oficiales y tres filtros centrales. Solo grabaciones desbloqueadas en API de jugador, sin títulos/reglas ocultos. Esquemas/casos 1/2 conservados.
- **Estado:** adoptada, implementada y probada.

## D-051 — Reproducción única, modos y sincronización

- **Fecha:** 2026-10-28.
- **Tema:** transporte físico y ciclo de vida.
- **Decisión tomada:** un AudioStreamPlayer en AudioPlaybackController; filtros por WAV preparados de la misma línea temporal, tolerancia de longitud 80 ms y posición/pausa conservadas al cambiar variante. Modo grabación completa distinto de segmento; seek acotado y fin notificado una vez.
- **Justificación:** usar el motor oficial y evitar solapamientos o una implementación manual de audio.
- **Consecuencias:** repetición idempotente, recursos ausentes deshabilitados sin sustitución, pausa al ocultar Audio/perder foco/suspender y sin reanudación automática. Corte directo entre mezclas, sin prometer crossfade. No es un gestor de locuciones de 09B.
- **Estado:** adoptada y verificada con AudioStreamPlayer y WASAPI en escritorio.

## D-052 — Examen real, texto equivalente y confirmación

- **Fecha:** 2026-10-28.
- **Tema:** descubrimiento sonoro e idempotencia.
- **Decisión tomada:** AudioAnalysisManager cualifica desde avance físico del reproductor en el intervalo/filtro requerido; la UI solo solicita Registrar observación. La demo exige tres segundos de cuatro, sin precisión de milisegundos. Texto equivalente disponible durante el mismo examen; no requiere audición fina.
- **Justificación:** abrir, seleccionar o buscar al final no debe conceder evidencia. El manager no recibe tiempos arbitrarios del jugador.
- **Consecuencias:** comprobante canónico validado de nuevo por el motor; evidencia/evento derivados de regla, sin efectos arbitrarios; transacción atómica de 08 y fachada EvidenceManager. Repetir/restaurar no otorga consecuencias nuevas. Diseño T04/T05 del Caso 001 permanece intacto; su concesión inmediata/transcripción se reconciliará al autorizar integración, sin cambio unilateral ahora.
- **Estado:** adoptada e implementada para la demo de 09A.

## D-053 — Guardado 3 y comprobante mínimo en el diario

- **Fecha:** 2026-10-28.
- **Tema:** persistencia y reconstrucción.
- **Decisión tomada:** formato 3 para esquema 3, lectores/escritores 1/2 intactos y sin migraciones. Solo entradas sonoras añaden analysis con recording_id/segment_id/filter_id/listened_ms al registro existente.
- **Justificación:** declarar la nueva semántica de reanudación y acreditar el contexto confirmado sin duplicar colecciones o guardar audio/posición por frame.
- **Consecuencias:** misma envoltura de ocho campos y snapshot de 17. Reproducción aislada de observaciones/consumos/deducciones, integralidad JSON estricta y rechazo conservador. Cualificaciones sin confirmar y posición son temporales; observaciones confirmadas persisten. El puente interno sirve a servicios/reconstrucción, no se presenta como protección contra archivos/código manipulados.
- **Estado:** adoptada y probada con recuperación exacta y rechazos incompatibles.

## D-054 — Recursos propios, onda y sesión compartida

- **Fecha:** 2026-10-28.
- **Tema:** demo, presentación y aislamiento.
- **Decisión tomada:** tres WAV sintéticos mono PCM 22050 Hz/16 bit, doce segundos, generados localmente con biblioteca estándar Python. Voces es un marcador electrónico, sin habla. Onda de 120 picos medida del PCM Original y etiquetada como precalculada.
- **Justificación:** demostrar audio real sin escoger proveedor de voz, descargar recursos o instalar herramientas.
- **Consecuencias:** AudioPanel reutiliza sección/Theme y datos de la misma sesión de CallController; no crea motor, guardado o inventario paralelos. Carpeta user://audio_analysis_demo; pruebas solo user://save_tests. Posición temporal al navegar y reinicio limpio al sustituir sesión. La onda no determina pistas.
- **Estado:** adoptada, implementada y probada.

## D-055 — Evidencia real y límites de verificación 09A

- **Fecha:** 2026-10-28.
- **Tema:** pruebas y cierre.
- **Decisión tomada:** validar catálogo/lógica, transporte físico específico, GUI real en cuatro tamaños, captura del bus PCM y regresión intacta de nueve suites anteriores.
- **Justificación:** distinguir reglas de juego, reproducción real, apariencia y comprobación auditiva humana.
- **Consecuencias:** 70 aserciones de catálogo, 58 de análisis, 11 de transporte físico y 1675 de integración base, más 4480 anteriores: 6294 de referencia. 48 capturas reales inspeccionadas, WASAPI con PCM no silencioso; simulación headless no se presenta como escucha. Pendientes escucha humana, Android/APK/release, accesibilidad física y perfil móvil. Cierre en 09A sin adelantar 09B/10.
- **Estado:** adoptada y verificada en 09A; resultados detallados en PROGRESS.

## D-056 — Alcance de PROMPT 10 y aplazamiento de 09B

- **Fecha:** 2026-10-28.
- **Tema:** autorización de mapa/despacho.
- **Decisión tomada:** aprobar 00–08/09A y ejecutar exclusivamente mapa, incidentes, dos tipos de unidades, partes discretos, persistencia/integración y demo técnica. 09B pospuesto intencionalmente, no es error ni bloquea 10/11.
- **Justificación:** alcance expreso del nuevo prompt; sustituye la prohibición temporal de mapa al cerrar 09A.
- **Consecuencias:** no cambiar R1/Caso 001, añadir bomberos, voz/TTS, GPS, tráfico, IA o vehículos. Sin commits/pushes, instalaciones o inicio de 11. Conservar cambios locales anteriores de 09A.
- **Estado:** aprobada e implementada en PROMPT 10.

## D-057 — Catálogo operativo y estados centrales

- **Fecha:** 2026-10-28.
- **Tema:** datos, visibilidad y autoridad.
- **Decisión tomada:** esquema narrativo 4 extiende 3 con operations, incluido en fingerprint; ubicaciones/sectores normalizados y reglas declaradas. MapManager proyecta visibilidad y DispatchManager administra solicitudes con DispatchRules compartido con el motor.
- **Justificación:** evitar inventarios operativos paralelos y otro lenguaje de condiciones.
- **Consecuencias:** estados/asignaciones enlazados a variables enum centrales; bindings exclusivos y protegidos contra efectos authored directos. HIDDEN/ACTIVE derivados de visibilidad/condiciones, sin flags duplicados. Tipos PATROL/AMBULANCE, sin asignaciones iniciales preestablecidas. Datos/casos 1/2/3 conservados.
- **Estado:** adoptada, implementada y probada.

## D-058 — Transacciones operativas, partes y recursos limitados

- **Fecha:** 2026-10-28.
- **Tema:** asignación y consecuencias.
- **Decisión tomada:** revisión/confirmación separadas; candidato atómico del motor con el EffectProcessor existente. Ciclo AVAILABLE→ASSIGNED→BUSY→AVAILABLE mediante asignación/llegada/resultado/liberación declarados, con enlace coincidente y estados anteriores exactos.
- **Justificación:** impedir recursos simultáneos, liberaciones ajenas, fases saltadas, repeticiones y efectos parciales.
- **Consecuencias:** partes con ID estable/global, evidencia mediante puente EvidenceManager; resultados no liberan implícitamente. Sin cronómetros o autoavance al navegar/cargar. La falsa alarma es una decisión legal poco útil explicada por datos previos/parte, sin penalización arbitraria. Cursor/visitas/historial hablado no se reinician.
- **Estado:** adoptada y probada, incluido rollback completo de un parte que bloquease el diálogo.

## D-059 — Formato 4 y registro de comandos

- **Fecha:** 2026-10-28.
- **Tema:** persistencia y compatibilidad.
- **Decisión tomada:** formato 4 para esquema 4, lectores 1/2/3 conservados y sin migración automática. Diario operativo añade dispatch con kind/unit_id/incident_id y event_id para partes; mismo snapshot de 17 campos/envoltura de ocho.
- **Justificación:** acreditar orden y semántica operativa sin duplicar catálogos/colecciones.
- **Consecuencias:** reconstrucción aislada por la misma API verifica comandos, referencias, estados, revisión/nodo, asignaciones y efectos antes de importar. Unidad ocupada sigue ocupada; no reactivar resueltos ni reemitir despachos/evidencias. Incompatibilidad conserva memoria/originales y política de respaldo. Garantías/cotas de guardado anteriores conservadas.
- **Estado:** adoptada, implementada y probada con disco y referencias incorrectas.

## D-060 — Plano de ensayo y sesión compartida

- **Fecha:** 2026-10-28.
- **Tema:** presentación, contenido y aislamiento.
- **Decisión tomada:** plano nativo 2D estático, tres sectores/lugares de ensayo no canónicos; marcadores grandes y lista alternativa, estados en texto, confirmación explícita y barra inferior fija. Mismo motor/gestor de CallController enlazado a MapPanel.
- **Justificación:** legibilidad táctil y coherencia con la central existente, sin cartografía externa o simulación innecesaria.
- **Consecuencias:** demo data/maps/dispatch_demo.json, user://dispatch_demo y pruebas únicas user://save_tests; no tocar producción. Selección/cancelación solo de presentación. Reiniciar/restaurar limpia selección, no libera recursos. Cierre conserva estados en modo consulta. Theme, iconos y guion oficial intactos.
- **Estado:** adoptada y verificada en escritorio.

## D-061 — Verificación de despacho y cierre

- **Fecha:** 2026-10-28.
- **Tema:** aceptación y límites.
- **Decisión tomada:** tres suites nuevas, regresión de trece anteriores, bootstrap/navegación en cuatro tamaños y 48 capturas gráficas reales inspeccionadas.
- **Justificación:** probar estado, GUI, persistencia y ausencia de efectos duplicados, distinguiendo simulación de Android.
- **Consecuencias:** 65 aserciones de mapa, 63 de despacho y 1714 de integración base; 6294 anteriores, total principal 8136 sin sumar repeticiones/capturas. Un ajuste de limpieza del auxiliar de audio conserva sus once aserciones y elimina el aviso observado en tres repeticiones finales. Pendientes Android/APK/release, gestos físicos, accesibilidad y perfil móvil. Registro de 25 grupos en PROGRESS; no iniciar 11.
- **Estado:** adoptada y verificada en PROMPT 10.

## D-062 — Autorización y autoridad del Caso 001

- **Fecha:** 2026-10-29.
- **Decisión:** PROMPT 11 autoriza integración oficial del diseño de 02 aprobado por D-017, menú, persistencia, herramientas, pruebas y cierre básico. Se conserva el guion/historia y se detiene antes de 12.
- **Motivo/consecuencias:** sustituye prohibiciones temporales de 10 respecto al Caso 001/Continuar, sin autorizar otros casos, 09B, instalaciones, APK o commits/pushes. Auditoría inicial sin bloqueo narrativo.
- **Estado:** autorizada por el usuario; implementada funcionalmente.

## D-063 — Contenido estable y resolución declarativa

- **Fecha:** 2026-10-29.
- **Decisión:** JSON oficial esquema 4, c001-1.0: 38 diálogos/57 opciones originales, siete transiciones y tres terminales. Variantes/filas declarativas validadas y compartidas por vista/historial; panel_id solo presenta herramientas.
- **Motivo/consecuencias:** reutiliza el motor sin lógica de hotel en scripts. K02 evalúa A/C/B según 02 y congela variables/acciones/última posición; el diario acredita el estado previo, sin duplicar resolution_snapshot o deducciones. N37 es cierre básico, no 12. Diez rutas/108 entradas sintéticas verifican exclusión y condiciones, sin prometer todas las secuencias posibles.
- **Estado:** implementada y probada.

## D-064 — Grabaciones pendientes y consulta textual explícita

- **Fecha:** 2026-10-29.
- **Decisión:** G01/G02 conservan IDs, segmentos y transcripciones; sus recursos con habla no existen. available=false y ruta vacía producen modo TEXT, sin reproducción ficticia. Regla consult permite descubrimiento explícito por transcripción con umbral cero; 09A conserva examen temporal. capture_information proyecta N-4 solo después de su descubrimiento.
- **Motivo/consecuencias:** aplica la alternativa accesible autorizada en 11, conserva ruta N12 y evita sustituir voces por señales engañosas. No hay TTS, proveedor o implementación de 09B. Inventario futuro de 48 líneas/variantes sin rutas inexistentes. Validación auditiva oficial pendiente.
- **Estado:** lógica textual implementada; producción/verificación sonora pendientes.

## D-065 — R1, partes y reubicación sin duplicación

- **Fecha:** 2026-10-29.
- **Decisión:** añadir RESCUE exterior, from_node/next de partes, reposition validada y closed_when/layout_kind opcionales al catálogo operativo. Mismos bindings centrales y comandos registrados.
- **Motivo/consecuencias:** U01/U02 avanzan N19/N20 y conceden entradas atómicamente; M05 cierra inspección del frente y asigna patio sin recurso libre intermedio. CLOSED es proyección del cierre, conservando posición para evaluación; no libera R1 ni crea bomberos actuales. Las reglas/demos originales de 10 conservan su ciclo.
- **Estado:** implementada y probada, incluida restauración y duplicados.

## D-066 — Menú oficial, conexión y conservación del progreso

- **Fecha:** 2026-10-29.
- **Decisión:** Nueva partida/Continuar usan contenido conocido y user://saves, con confirmación de reemplazo. connection_action referencia acción interna declarada para registrar respuesta; no aparece en Expedientes. Demos no pueden usar el espacio oficial.
- **Motivo/consecuencias:** restaura INCOMING/CONNECTED/ENDED, sin perder o repetir N01. Inspección compatible desde arranque frío; inválidos conservados, respaldo disponible validado. Una sesión sucia no abandona consola si falla guardar; reintento escribe el mismo snapshot. Intervención vigente separada del historial para que texto/opciones correspondan sin desplazar consultas anteriores.
- **Estado:** implementada y probada con ranuras aisladas, reemplazo cancelado/confirmado y fallos de E/S.

## D-067 — Alcance de verificación de 11

- **Fecha:** 2026-10-29.
- **Decisión:** diez rutas de referencia, cobertura de 38 diálogos/57 opciones/diez evidencias, tabla sintética de 108 entradas, checkpoints reales, tres suites nuevas y regresión de dieciséis anteriores; UI real en cuatro tamaños.
- **Motivo/consecuencias:** 3285 aserciones de flujo, 52 de validación y 1807 de GUI headless base; 8178 anteriores: 13322 de referencia, sin sumar repeticiones como escenarios nuevos. 52 capturas de Windows; tiempos automáticos no son duración humana. Android/audición, accesibilidad y perfil móvil pendientes. Se declara integración funcional realizada, no experiencia totalmente validada.
- **Estado:** comprobaciones funcionales de escritorio aprobadas; límites registrados en PROGRESS y el informe. Sin iniciar 12 ni operaciones remotas.

## D-068 — Autorización de corrección de experiencia

- **Fecha:** 2026-10-29.
- **Decisión:** aplicar el diagnóstico de orientación/tedio tras «Adelante, hazlo». Objetivos contextuales, navegación coherente, avisos, menos selección redundante y comprobaciones de UI. No es inicio de 12/13/09B.
- **Consecuencias:** conservar historia, elecciones relevantes, condiciones A/B/C y contenido/fingerprint. Sin commits/pushes, instalaciones o APK. [Revisión](cases/CASE_001_UX_REVIEW.md).
- **Estado:** autorizada e implementada.

## D-069 — Orientación y controles según contexto

- **Fecha:** 2026-10-29.
- **Decisión:** perfil de presentación c001 sin efectos; guía y avisos comunes, entrada sin doble responder, consultas secundarias plegables, retorno directo y posición por pestaña. Selector de hipótesis y barra fija, selección temporal limpia al confirmar. Mapas de destino único preseleccionan R1/incidente, manteniendo confirmación y cancelación; texto pendiente de audio tiene una sola consulta.
- **Consecuencias:** las herramientas se orientan con información conocida, sin revelar combinaciones o el destino correcto. No se elimina ninguna de las 57 opciones del motor. Demos y controles de audio real conservados. Foco de transcripción/explicación tras acción explícita; consulta y navegación no avanzan peligro.
- **Estado:** implementada y comprobada en escritorio; evaluación humana pendiente.

## D-070 — Preparación atómica del contexto de partes

- **Fecha:** 2026-10-29.
- **Decisión:** API optativa preview/process_contextual_dispatch, activada en DispatchManager para UI oficial. Solo opciones elegibles sin efectos y entradas de diálogo sin efectos pueden preparar from_node sobre una instancia candidata; comando real existente, una publicación estable y diario normal.
- **Consecuencias:** misma disponibilidad desde investigación/audio/expediente sin mutar al consultar pestañas. No se atraviesan pruebas, emociones, transiciones o cambios de plan. Fallo revierte navegación preparatoria/diario junto a los efectos. Revisión obsoleta rechazada antes de navegar; repetición no duplica partes. Mantiene API estricta, JSON, fingerprint y formatos de guardado.
- **Estado:** implementada y probada con rollback, reanudación exacta y plan crítico protegido.

## D-071 — Verificación y límites de la corrección UX

- **Fecha:** 2026-10-29.
- **Decisión:** mantener las diez rutas originales y regresión de dieciséis sistemas; añadir 108 aserciones de contexto/orientación y actualizar el recorrido GUI, en cuatro tamaños con capturas reales separadas de las originales.
- **Consecuencias:** funcionamiento y menor cantidad de pasos comprobables no equivalen a validar satisfacción o duración humana. Android físico, rendimiento/accesibilidad móvil y producción auditiva siguen pendientes. No presentar la actualización como implementación de 09B, 12 o 13.
- **Estado:** comprobada en escritorio; resultados en PROGRESS. Trabajo detenido al terminar esta corrección.

## Plantilla para nuevos registros

- **Identificador y tema:** D-XXX — título.
- **Fecha:** AAAA-MM-DD, fecha local del usuario.
- **Tema:** arquitectura, diseño o producto.
- **Decisión tomada:** contenido y fuente de autorización, o asunto todavía abierto.
- **Justificación:** motivo y evidencia disponible.
- **Consecuencias:** efectos, dependencias y documentos afectados.
- **Estado:** aprobado, propuesto, pendiente o sustituido, según corresponda; enlazar el registro que lo sustituya si aplica.
