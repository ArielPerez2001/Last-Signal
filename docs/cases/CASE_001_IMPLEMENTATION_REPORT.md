# Caso 001 — Informe de implementación

PROMPT 11 · 2026-10-29 · Godot 4.7.2 estable · Windows/Compatibility.

**Revisión posterior:** el usuario autorizó corregir orientación y pasos de interfaz. La navegación vigente, sus pruebas y capturas están en [CASE_001_UX_REVIEW.md](CASE_001_UX_REVIEW.md). Los recuentos de GUI/capturas siguientes documentan la entrega inicial de 11; no sustituyen los resultados de la revisión. El contenido narrativo y su fingerprint se conservan.

**Estado:** implementación funcional completada; validación auditiva y Android pendientes. Este informe no acredita una experiencia totalmente validada, una versión de distribución ni una partida humana de 8–15 minutos.

## 1. Resumen

Nueva partida prepara la comunicación oficial de «La habitación 304». Responder, investigar, deducir, inspeccionar el hotel, transmitir una instrucción y leer el cierre forman una sola sesión. Las rutas y textos proceden del diseño aprobado; no se explica la naturaleza de Clara, la causa del incendio o el funcionamiento de ECO.

## 2. Autoridad narrativa

Se conservaron sin reescritura [CASE_001_DESIGN.md](CASE_001_DESIGN.md), [CASE_001_TECHNICAL_SPEC.md](CASE_001_TECHNICAL_SPEC.md), [CASE_001_TEST_PLAN.md](CASE_001_TEST_PLAN.md) y STORY_BIBLE. D-017 registra su aprobación. [La auditoría](CASE_001_IMPLEMENTATION_CHECKLIST.md) relaciona el contrato anterior a los sistemas actuales. No hubo una contradicción narrativa que exigiera inventar otra solución.

## 3. Archivos

| Grupo | Entrega |
| --- | --- |
| Contenido oficial | data/cases/case_001/case_001.json; voice_inventory.json |
| Autoría/pruebas nuevas | tests/cases/case_001/build_case_content.py; test_case_flow.gd; test_case_validation.gd; test_case_integrations.gd y UID de Godot |
| Documentación nueva | Este informe; CASE_001_IMPLEMENTATION_CHECKLIST.md; matriz y capturas bajo docs/validation/prompt_11 |
| Núcleo modificado | narrative_engine.gd, narrative_validator.gd, narrative_state_validator.gd; catálogos/servicios de audio y despacho; map_manager.gd; deduction_manager.gd; call_controller.gd |
| Interfaz modificada | navigation_controller.gd, main_menu.gd, calls_panel.gd, dispatch_console.gd, evidence_panel.gd, audio_panel.gd, map_panel.gd, map_canvas.gd y cuatro escenas de menú/paneles |
| Auxiliares anteriores | bootstrap_smoke.gd aísla la ranura y solicita render real explícito al capturar; navigation_smoke.gd incluye Nueva partida en el foco |
| Seguimiento | AGENTS.md, GDD, ROADMAP, PROGRESS, DECISIONS, UI_NAVIGATION y contratos técnicos afectados |

No se modifican project.godot, Theme, iconos, JSON/WAV de las demos ni las pruebas funcionales anteriores de sistemas. SaveManager conserva su código/algoritmo y los ocho campos de envoltura; el snapshot sigue teniendo 17 campos.

Inventario final: **64 archivos nuevos** (52 capturas, dos JSON oficiales, tres suites/UID, auxiliar Python, dos documentos y matriz ejecutada) y **37 existentes modificados**. Verificación: 472 archivos no vacíos, 337 enlaces locales válidos y 78 referencias de recursos runtime resolubles. Los IDs internos de autoría no se imprimen como procedencia de las fichas; sus fuentes son etiquetas diegéticas legibles.

## 4. Sistemas y arquitectura

CallController posee una sola instancia de NarrativeEngine y SaveManager. CallsPanel, EvidencePanel, AudioAnalysisManager/AudioPlaybackController y MapManager/DispatchManager comparten esas instancias. La UI solicita ID/revisión, sin efectos o condiciones del caso en scripts generales. No hay autoload, dependencia, servidor o motor paralelo nuevo.

## 5. Nodos

38 nodos de diálogo aprobados y diez auxiliares: siete transiciones automáticas y tres terminales; **48 nodos en total**. Las transiciones eligen A/C/B y la salida terminal mediante datos, no comparaciones de textos visibles. N19/N20 entran por partes validados desde N16. Las variantes y filas condicionales se proyectan al texto y se reconstruyen en el historial según el estado de cada visita.

## 6. Opciones e identificadores

**57 opciones de diálogo**, con IDs originales c001_nXX_oYY. c001_nXX identifica cada intervención. El inventario futuro añade IDs estables de línea/variante sin rutas ficticias. Los botones de herramientas y c001_answer no se cuentan como opciones narrativas. build_case_content.py extrae textos/tablas del diseño y traduce sus reglas explícitas; es un auxiliar opcional de autoría, no dependencia del juego.

## 7. Evidencias

Diez fichas E01–E10, con descripción, categoría, procedencia e importancia. Entradas y partes utilizan el conjunto central, observado por EvidenceManager. E03 se recupera por N12 o transcripción G01.S02; E04 por plano o parte posterior. E06 llega desde cualquiera de los dos accesos; E07 desde patio. E05/E09 son opcionales. No hay inventario duplicado ni evidencia concedida por abrir una tarjeta.

## 8. Deducciones

Cuatro hipótesis Q01–Q04. La UI permite seleccionar la hipótesis y de dos a tres fuentes; el servicio exige conjunto exacto sin importar el orden. Los errores permiten corregir sin borrar pruebas o cambiar emociones. Se conservan las reglas de dos fuentes de las demos. Las conclusiones derivan de executed_actions; quedan consultables tras K02, sin nuevas confirmaciones.

## 9. Grabaciones

G01 tiene tres segmentos y G02 dos; duraciones editoriales de 18 y 12 s, **no duraciones de archivos producidos**. Los metadatos/variantes/textos son funcionales; las dos grabaciones con habla están pendientes. Las rutas de audio están vacías y available=false. AudioPlaybackController identifica modo TEXT, sin stream ni audio sintetizado. Cambiar grabación, segmento o filtro no concede E03; la acción explícita Leer transcripción usa AudioAnalysisManager y el puente de EvidenceManager. La regla consult tiene umbral cero declarado; la demo 09A conserva su examen temporal real.

G02 se desbloquea con E08; su cabecera N-4 solo se proyecta después de E10. Consultar datos de captura no añade otra pista o explicación. La interfaz permite completar la investigación en silencio, sin fingir que existe una voz reproducible.

## 10. Incidentes

Dos inspecciones del mismo Hotel Mirador: c001_i01 frente y c001_i02 patio, visibles desde la ficha municipal. Dos ubicaciones oficiales L01/L02 en Frente Costero. El plano es esquemático y no representa toda la ciudad ni una geografía nueva. No hay GPS, cartografía externa, tráfico o cronómetros.

## 11. Recurso y adaptación de estados

Una sola R1, Inés Duarte, tipo RESCUE exterior. Correspondencias: AVAILABLE/sin asignación → disponible; ASSIGNED/frente → rumbo_frente; BUSY/frente → frente_lista; ASSIGNED/patio → rumbo_patio; BUSY/patio → patio_lista. Al resolver, closed_when deriva las vistas CLOSED de unidad/incidentes y bloquea órdenes; los bindings conservan la última posición observada. No se duplica el enum unidad ni se libera automáticamente R1. No se crean bomberos actuales: la voz histórica de bomberos sigue siendo testimonio aprobado.

M01/M02 se registran como asignaciones generadas por el gestor; M03/M04 corresponden a U01/U02; M05 reubica en una transacción el frente comprobado al patio activo, sin estado disponible intermedio. U01/U02 incluyen entrada N19/N20 y sus evidencias dentro del mismo candidato. next requiere from_node válido; las reglas sin next conservan el comportamiento de 10.

## 12. Eventos críticos y resolución inmutable

K01 exige Q01/E06 y etapa C, entra en N21 y no vuelve a consumirse desde E. K02 exige etapa E, comunicación activa, plan válido/E06 y patio verificado para servicio. Calcula A/C/B en ese orden y fija resultado, comunicación, etapa F y clave c001_k02 juntos. Las emociones, plan, deducciones y última posición quedan congelados después; el diario conserva la revisión previa. Eso permite recuperar la instantánea lógica de resolución sin otra colección o campo resolution_snapshot redundante. Ni navegación, lectura lenta, consultas o errores de relación avanzan la emergencia.

## 13. Tres desenlaces

| ID | Condición exacta | Secuencia y límite narrativo |
| --- | --- | --- |
| c001_final_a · Salida comunicada | Servicio + Q02 + patio listo + confianza ≥1 y estrés ≤1 | N27–N29. Clara comunica aire/salida; R1 no confirma contacto físico |
| c001_final_c · Contacto perdido en riesgo | Pasillo + confianza 0 + estrés 2 | N33–N35. Humo/desorientación; no se confirma muerte |
| c001_final_b · Refugio sin confirmación | Resto de entradas válidas | N30–N32, variante según plan/Q02; no se confirma evacuación |

Los tres siguen por N36/N37. Q03 amplía la relación documental ECO; Q04 la correspondencia histórica, sin cambiar el resultado. N25 permite corregir y explica interpretación, posición y cooperación antes de confirmar. N37 muestra solamente el cierre básico aprobado; no se construyó la puntuación/pantalla definitiva de 12.

## 14. Flujos y matriz

TR01–TR08 del plan aprobado se ejecutan con servicios reales; TR09/TR10 añaden Q03/Q04 a B/C. La matriz final se conserva en [narrative_coverage.json](../validation/prompt_11/narrative_coverage.json) y PROGRESS. Se verifican visitas a los 38 diálogos, ejecución de las 57 opciones y obtención de diez evidencias entre rutas. Esto acredita cobertura representativa de elementos, **no todas las secuencias posibles** de consultas/bucles.

El dominio sintético del resolutor prueba 108 entradas: 18 servicio/frente inválidas, 4 A, 4 C y 82 B. No se afirma que todos los pares emocionales sintéticos sean alcanzables por el guion.

## 15. Problemas encontrados

Se reconciliaron contratos propuestos de 02 con APIs reales, sin cambiar la historia: selector de tres fuentes, consulta textual inmediata, reubicación, partes que avanzan diálogo y cierre operativo. La prueba inicial usó dispose inexistente de SaveManager; se corrigió el auxiliar. La revisión visual descubrió historial antiguo junto a respuestas nuevas: la campaña ahora presenta la intervención vigente por separado y permite consultar historial sin desplazarlo. Dos intentos gráficos agotaron el vigilante esperando render bajo carga/ocultación; se sustituyó la espera de frame_post_draw por un fotograma de proceso y RenderingServer.force_draw. Se verifican las capturas reales posteriores. También se protege la consulta de hipótesis con contenido cargado pero sin sesión iniciada.

## 16. Cambios técnicos y persistencia

Extensiones opcionales del esquema 4: text_variants/text_rows y panel_id de diálogo; connection_action de caso y internal de acciones; closed_when/layout_kind de operaciones; RESCUE y reglas reposition/from_node/next; discovery_mode=consult y capture_information. Se validan tipos, referencias, condiciones, bindings y transiciones. Formatos 1–4 anteriores conservados, sin migración ni cambio de cantidad de campos del snapshot. El fingerprint incluye el contenido oficial completo.

La conexión se confirma como acción interna c001_answer. Antes de responder existe un checkpoint de llamada entrante; después de responder se recupera conectada, sin reiniciar N01. No aparece como consulta del expediente. Nueva partida conserva progreso hasta confirmar sustitución; Continuar inspecciona el contenido conocido y solo ofrece una ranura compatible. Una sesión oficial viva conserva cambios en memoria; salir al menú intenta guardar y, si falla, mantiene la consola con reintento. Las demos siguen en sus carpetas propias y no pueden usar user://saves. Pruebas exclusivamente bajo user://save_tests.

## 17. Recursos provisionales

Plano esquemático nativo y textos aprobados completos. No hay marcadores sonoros que pretendan sustituir habla ni recursos de terceros. La ausencia de voces no detiene diálogo o análisis textual.

## 18. Recursos faltantes

Producción legítima de G01/G02 y sus variantes con el contenido auditivo aprobado; verificación de inteligibilidad, alineación semántica y correspondencia con transcripciones. 09B sigue aparte, pendiente de autorización; este pendiente de audio de investigación no se presenta como un recurso de voz ya integrado.

## 19. Pruebas automatizadas

test_case_flow recorre diez rutas, guarda cada paso en disco, restaura en otro motor y compara estado/historial; comprueba señales de restauración sin consecuencias nuevas. test_case_validation rechaza datos/estados inválidos, simula fallo de escritura/reintento y recupera respaldo conservando el principal dañado. test_case_integrations opera controles reales de menú, llamadas, audio, mapa, hipótesis, confirmación, cierre y recuperación. Las dieciséis suites anteriores se ejecutan también; resultados finales y comandos en PROGRESS.

| Comprobación | Resultado final |
| --- | --- |
| Flujo y persistencia | PASS, 3285 aserciones, diez rutas y 108 entradas del resolutor |
| Validación y fallos | PASS, 52 aserciones, incluido contenido cargado sin sesión iniciada |
| GUI headless | PASS, 1807 en 720×1280/1080×1920; 1803 en 1080×2400/720×1600 |
| GUI gráfica | PASS, 1872 en 720×1280/1080×1920; 1868 en 1080×2400/720×1600 |
| Dieciséis suites anteriores | PASS, 8178 aserciones |
| Referencia sin sumar repeticiones | **13322 = 8178 + 3285 + 52 + 1807**; son aserciones, no escenarios independientes |
| Arranque y navegación | Importación y arranque gráfico/headless salida 0; bootstrap/navegación en cuatro tamaños, 198 nodos estables |

Comandos reproducibles desde la raíz, usando la instalación existente:

```powershell
$caseGodot = 'D:\Descargas\Exe\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe'
& $caseGodot --headless --path 'D:\Ultima Señal' --script res://tests/cases/case_001/test_case_validation.gd
& $caseGodot --headless --path 'D:\Ultima Señal' --script res://tests/cases/case_001/test_case_flow.gd
& $caseGodot --headless --path 'D:\Ultima Señal' --script res://tests/cases/case_001/test_case_integrations.gd -- 720x1280
& $caseGodot --path 'D:\Ultima Señal' --script res://tests/cases/case_001/test_case_integrations.gd -- 720x1280 'D:/Ultima Señal/docs/validation/prompt_11/720x1280'
```

Repetir GUI en 1080x1920, 1080x2400 y 720x1600. El vigilante del auxiliar detecta bloqueos de prueba y no avanza el tiempo del caso.

## 20. Revisión de experiencia y capturas

Recorrido de UI automatizado de inicio a A y revisión visual por el agente, en Windows. Capturas reales del viewport, no maquetas. Trece estados por tamaño: menu, incoming, contradiction, transcript, map, confirmation, restored, deduction, revelation, critical, ending_a, resolution y closed_archive. B/C se ejecutan mediante el núcleo real y su presentación de datos; no se afirma una partida humana cronometrada de cada rama.

Inicio manual: **F5 → Nueva partida · Caso 001 → Responder comunicación**. La consola de desarrollo es un acceso separado visible en debug. Volver al menú conserva partida; Nueva partida vuelve a pedir confirmación. La grabación pendiente se examina seleccionando G01, Voces, fragmento 02 y Leer transcripción. Q01 usa E01/E02; Q02 E03/E04/E06. Para la ruta A preparar patio, mantener/recuperar cooperación y elegir servicio con Q02 antes de transmitir.

Muestras: [mapa](../validation/prompt_11/720x1280/map.png), [transcripción](../validation/prompt_11/720x1280/transcript.png), [instrucción](../validation/prompt_11/720x1280/critical.png), [resolución](../validation/prompt_11/720x1280/resolution.png).

## 21. Limitaciones

Sin grabaciones reproducibles del caso ni validación auditiva completa. Sin APK, Android físico, zonas seguras/gestos/accesibilidad real o medición de rendimiento móvil. Los toques y fallos de E/S son simulados. No hay medición de lectura humana: 8–15 minutos sigue siendo objetivo/estimación editorial, no un tiempo demostrado por la ejecución automática. La cobertura estática no demuestra todas las combinaciones dinámicas; se declaran las rutas y el dominio concreto probados. El guardado conserva las garantías/cotas reales de 06, sin durabilidad eléctrica universal.

## 22. Preparación para 12

Resultado estable c001_final_a/b/c, variables/diario congelados y explicaciones de N37 disponibles para una futura presentación. Sin puntuaciones, clasificaciones, galería de finales ni implementación de 12. No se empieza la siguiente fase.

## 23. Preparación para 09B y cierre

voice_inventory.json contiene 48 entradas de línea/variante con speaker_id y status pending_09b; no rutas a audios inexistentes, proveedor, TTS o temporización. No son 48 diálogos distintos: hay 38 nodos y variantes. 09B sigue pendiente. Solo se integró el Caso 001; sin Caso 002, capítulos posteriores, instalaciones, APK, commits o pushes.
