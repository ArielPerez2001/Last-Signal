# ÚLTIMA SEÑAL — Estado, guardado y recuperación

**11R · 2026-10-29:** c001 acepta la envoltura previa de ocho campos y una extensión opcional presentation v1 con tutorials_seen (hasta ocho IDs conocidos, únicos). Ausencia equivale a vacío; dirty incluye presentación. Se conserva esquema/save_version 4 y snapshot de 17 campos, mismo bloqueo, escritura, respaldo y rutas. Nuevo lector compatible con archivos anteriores; binarios viejos pueden rechazar el campo nuevo sin borrar. No hay migración narrativa ni guardado paralelo. [Contrato exacto](CASE_FLOW_EXPERIENCE.md). Las tablas de ocho campos siguientes describen el formato base conservado.

**Revisión UX posterior a 11:** no cambia código de SaveManager, JSON oficial, fingerprint, versión de contenido o formato. Los objetivos, avisos, selecciones y posiciones de lectura son proyecciones/presentación temporal. La recepción contextual de partes agrega opciones normales de consulta seguidas del comando existente al diario; se confirma atómicamente y restaura mediante el replay actual. Las partidas de la entrega inicial siguen siendo compatibles. [Revisión y pruebas](../cases/CASE_001_UX_REVIEW.md).

**Integración 11 · 2026-10-29:** Nueva partida/Continuar ya usan el Caso 001 conocido en user://saves. Las referencias posteriores a Continuar deshabilitado o Caso 001 no integrado describen fases anteriores. SaveManager conserva código, ocho campos y snapshot de 17; esquema/formato 4 del contenido oficial, sin migración. La acción interna de conexión distingue llamada entrante/respondida; variables, diario y condiciones recuperan herramientas, última asignación y desenlace congelado. [Informe y pruebas](../cases/CASE_001_IMPLEMENTATION_REPORT.md).

El menú inspecciona ranura compatible incluso en arranque frío, conserva archivos inválidos y requiere confirmación para sustituir archivos/progreso existente. Una restauración fallida no autoriza reemplazo. Al salir al menú, un fallo de escritura mantiene la consola con reintento; no se abandona silenciosamente la sesión sucia. Las demos tienen carpetas independientes y no pueden preparar/restaurar su contenido en user://saves. Todas las pruebas escriben bajo user://save_tests. No se añaden ranuras o progresión de campaña.

PROMPT 06 · 2026-10-28 · Godot 4.7.2 estable · formato de guardado 1.

Integración PROMPT 07: [CallController/CallsPanel](CALL_SYSTEM.md) utilizan el servicio sin modificar código de guardado, estructura o versiones. La demo usa user://call_demo y las pruebas user://save_tests; user://saves sigue reservado para producción. Su transcripción se deriva de transaction_log/visitas/consumos, sin campos nuevos.

Integración PROMPT 08: formato **2** para casos narrativos esquema **2**, con registro de acciones externas/deducciones. Los casos de esquema 1 conservan escritura/lectura de formato 1. Sin migración automática. La envoltura y los 17 campos de session permanecen; se amplía la semántica validada del registro. La demo nueva usa user://investigation_demo. El resto de garantías de archivo de 06 se conserva; ver el apartado de formato 2 y [INVESTIGATION_SYSTEM.md](INVESTIGATION_SYSTEM.md).

Integración PROMPT 09A: formato **3** solo para esquema **3**, con comprobantes mínimos de observaciones de audio en transaction_log. Formatos 1/2 y sus garantías conservados; sin migraciones. Nueva demo user://audio_analysis_demo; no hay audio de llamadas ni archivos PCM en la partida. Contrato del formato 3 más abajo y en [AUDIO_ANALYZER.md](AUDIO_ANALYZER.md).

## Objetivo y alcance

Conservar una sesión lógica completa, recuperarla offline y seguir sin repetir consecuencias. El sistema se integra con el [motor narrativo](NARRATIVE_ENGINE.md) mediante API; no conoce escenas de la consola ni necesita Llamadas. El flujo normal del juego conserva su menú: Continuar sigue deshabilitado. El Caso 001 y las mecánicas de fases posteriores no se integran aquí.

## Arquitectura y archivos

| Archivo | Responsabilidad |
| --- | --- |
| [save_manager.gd](../../scripts/systems/save_manager.gd) | Servicio RefCounted: JSON, metadatos, archivos, validación, respaldo, restauración, resultados y coordinación de autoguardado |
| [save_lifecycle.gd](../../scripts/systems/save_lifecycle.gd) | Adaptador Node opcional de ciclo de vida; sin escena obligatoria ni autoload |
| [narrative_state_validator.gd](../../scripts/narrative/narrative_state_validator.gd) | Formato del snapshot, tipos, límites JSON y normalización explícita de enteros |
| [narrative_engine.gd](../../scripts/narrative/narrative_engine.gd) | Valida historial determinista, importa una sesión completa y notifica restauración; no lee/escribe partidas |
| [test_save_manager.gd](../../tests/save/test_save_manager.gd) | Escritura/lectura, errores, respaldos, borrado, autoguardado y ciclo de vida |
| [test_save_validation.gd](../../tests/save/test_save_validation.gd) | Tipos, versiones, registros, corrupción e invariantes de restauración |
| [save_test_support.gd](../../tests/save/save_test_support.gd) | Aserciones y rutas aisladas de pruebas |
| [failing_save_manager.gd](../../tests/save/failing_save_manager.gd) | Fallos inyectados de escritura/renombrado para pruebas |
| [save_process_worker.gd](../../tests/save/save_process_worker.gd) | Dos procesos separados: uno escribe; otro carga y continúa desde disco |

NarrativeSessionState conserva su estructura de 05. No se añaden flags redundantes: los indicadores bool, confianza/estrés/cooperación cuando se declaren, son variables del caso. En 08 las conclusiones reales se derivan de los ID de executed_actions, sin otra lista persistente. No se crean grabaciones, recursos o progreso de campaña vacíos para simular sistemas futuros.

## Formato 1

La raíz tiene exactamente estos campos, todos obligatorios:

| Campo | Contrato |
| --- | --- |
| save_version | Entero 1; versión del archivo de guardado |
| game_id | ultima_senal |
| case_id | ID del caso cargado |
| content_version | Versión exacta de ese contenido |
| narrative_schema_version | Entero 1; versión del esquema narrativo, independiente de save_version |
| content_fingerprint | SHA-256 del JSON canónico del contenido validado; detecta cambios aunque se olvide aumentar content_version |
| saved_at | Fecha UTC del reloj del sistema, YYYY-MM-DDTHH:MM:SSZ |
| session | Snapshot completo de NarrativeSessionState |

No contiene rutas absolutas, ruta del caso, cuentas, credenciales ni datos personales. La aplicación debe cargar explícitamente un caso conocido antes de inspeccionar su compatibilidad/restaurarlo: un archivo de partida no elige un recurso ni una ruta arbitraria. El fingerprint detecta cambios de contenido, no firma el archivo ni ofrece protección contra manipulación intencionada. La fecha no decide qué archivo tiene prioridad ni avanza la historia; un reloj incorrecto no cambia las consecuencias.

session incluye los 17 campos de 05: schema_version, content_version, case_id, current_node, variables, evidence, events, consumed_events, executed_actions, applied_once_keys, applied_effects, visits, visit_serial, transaction_log, revision, finished y ending_id. Se conserva la cola de eventos y su consumo, las visitas y todos los registros de idempotencia. Las selecciones de interfaz, audio reproduciéndose y animaciones no son parte del estado lógico.

Ejemplo parcial orientativo, no un archivo completo válido:

```json
{
  "save_version": 1,
  "game_id": "ultima_senal",
  "case_id": "test_narrative",
  "content_version": "test-1.0",
  "narrative_schema_version": 1,
  "content_fingerprint": "<SHA-256 del contenido cargado>",
  "saved_at": "2026-10-28T00:00:00Z",
  "session": {"current_node": "test_n02", "variables": {"signal": 1, "prepared": true}}
}
```

Los ID/versiones reales se obtienen del [caso técnico](../../data/cases/test_narrative.json). No copiar los marcadores o un session incompleto a producción.

## Rutas y una ranura

La carpeta de producción predeterminada es user://saves; los únicos nombres gestionados son:

- slot_01.json: principal.
- slot_01.tmp: candidato al principal.
- slot_01.bak: checkpoint anterior válido.
- slot_01.bak.tmp: candidato verificado para reemplazar el respaldo.

El constructor permite otra carpeta canónica bajo user:// suministrada por código de aplicación/pruebas. Rechaza res://, raíz user://, navegación con .., barras invertidas y barras finales. El JSON no define rutas. Ningún constructor o consulta crea carpetas ni modifica archivos. No hay múltiples ranuras, perfiles o nube.

Las pruebas siempre generan user://save_tests/<grupo>_<pid>_<ticks>. El worker rechaza cualquier argumento fuera de ese prefijo. Conservan sus archivos aislados para diagnóstico; no usan ni borran slot_01 de producción. El borrado del gestor solo opera sobre los nombres fijos de su carpeta, nunca recorre el directorio ni borra archivos ajenos.

## Escritura y respaldo

1. Adquirir el bloqueo de la carpeta; rechazar otra operación mutante/reentrante.
2. Obtener copia de la sesión estable y metadatos del motor. Validar todo antes de serializar.
3. Preparar la carpeta y escribir slot_01.tmp. Comprobar apertura, flush, error y longitud escrita; cerrar.
4. Reabrir, analizar y validar el temporal; comparar con la instantánea prevista.
5. Leer/validar el principal anterior. Si es válido, escribir su documento a slot_01.bak.tmp, verificarlo, renombrar a slot_01.bak y volver a verificarlo antes de reemplazar el principal.
6. Si el principal es corrupto o incompatible, nunca copiarlo al respaldo. Un respaldo compatible existente se conserva. Sin ese respaldo, un principal inválido exige una decisión explícita de reemplazo: devolver replacement_required y conservar originales. Borrar la ranura mediante API es una decisión explícita disponible; la aplicación futura puede conservar una copia externa antes.
7. Renombrar slot_01.tmp al principal sin borrar antes el destino. Comprobar resultado; reabrir y validar el principal confirmado.
8. Solo entonces registrar saved, actualizar el checkpoint en memoria y limpiar dirty.

La primera escritura no inventa un checkpoint anterior: todavía no hay .bak. Escrituras consecutivas conservan como respaldo el principal válido previo. Una recuperación no cambia esos archivos; un guardado posterior explícito puede reemplazar un principal dañado si existe respaldo válido, sin destruir ese respaldo. Si se carga una copia anterior y luego se guarda, la rotación sigue basándose en el principal válido existente en disco, no en la fecha de la sesión restaurada.

Errores conservan la sesión en memoria y dejan pendiente el guardado. Un fallo de temporal no toca el principal/respaldo; un fallo al confirmar respaldo detiene el reemplazo del principal. Si falla la sustitución o verificación del principal, se informa del error y se puede cargar el respaldo disponible. Los temporales residuales se conservan, no se promueven ni se borran durante una carga; la siguiente escritura explícita puede reutilizarlos.

### Garantías reales

Se comprueban los resultados observables de FileAccess/DirAccess y se verifica el contenido releído. La prueba de escritorio confirmó renombrado con destino existente. No se afirma atomicidad universal, fsync de directorios, durabilidad frente a fallo eléctrico, resistencia del hardware o garantía de ejecución de callbacks al terminar un proceso. Un cierre abrupto durante la primera escritura puede dejar solo el temporal; no se confunde con un principal confirmado.

Los bloqueos cubren gestores del mismo proceso/hilo principal y carpeta canónica. No son un bloqueo entre procesos, mutex para threads ni protección contra editores externos. El servicio es síncrono y debe usarse desde el hilo principal. El coste de validación aumenta con el historial; no se midió rendimiento móvil ni se promete tiempo constante.

Referencias de APIs: [FileAccess](https://docs.godotengine.org/en/4.7/classes/class_fileaccess.html) y [DirAccess](https://docs.godotengine.org/en/4.7/classes/class_diraccess.html). El contrato comprobado corresponde al ejecutable 4.7.2 instalado, no a una suposición de atomicidad del sistema de archivos.

## Recuperación y validación

load_saved_session intenta principal y, si falla, respaldo. restore_backup solicita solo el respaldo, aunque exista principal válido. Se informa de restored_backup y de los diagnósticos del principal. Ninguna carga repara, sobrescribe o elimina archivos. Si ambos fallan, devuelve missing_save o unrecoverable_save con detalles; el juego puede seguir y la sesión activa permanece intacta. Un nuevo inicio requiere una acción posterior explícita.

Antes de reemplazar una sesión se comprueban raíz/campos/versiones/juego/caso/contenido, timestamp, valores JSON, tipos y estructura del snapshot. Solo se normalizan números JSON finitos sin parte fraccionaria cuando el contrato exige int y dentro del rango declarado. No se convierten strings, bool ni fracciones a enteros.

Se valida también la consistencia completa de referencias, evidencias, acciones, visitas, eventos y efectos contra la ejecución determinista del caso: el motor reconstruye el historial en otra instancia sin observadores, intercalando consumos según las revisiones de las decisiones, y compara el resultado completo. Las revisiones previas de transaction_log y el orden de consumed_events permiten reconstruir su cronología, incluso consumos tras un final.

Esa reconstrucción es una comprobación aislada: no llama consumidores del juego, no publica eventos a la sesión viva y no escribe archivos. Solo si coincide se asigna una copia nueva a la sesión activa. La importación no entra de nuevo al nodo ni aplica los efectos sobre el estado restaurado. Datos incoherentes se rechazan; no se inventan pistas ni se reparan registros silenciosamente.

Límites explícitos: 4 MiB por archivo, profundidad JSON 32, 250000 valores recorridos, enteros seguros hasta ±9007199254740991 y 2048 operaciones confirmadas (decisiones + consumos) por sesión guardable. Se rechazan objetos Godot, claves no String, números no finitos, ciclos, datos esenciales ausentes y extensiones desconocidas. El límite de 64 transiciones consecutivas por operación de 05 permanece. Estas cotas evitan aceptar entradas arbitrariamente grandes; antes de ampliarlas deben medirse rendimiento y memoria.

## Restauración y señales

API nueva del motor:

| Método/señal | Comportamiento |
| --- | --- |
| get_case_metadata() | Copia de case_id, content_version, narrative_schema_version y content_fingerprint; vacía sin caso |
| is_busy() | Indica si el motor está notificando/ejecutando una operación |
| validate_state_snapshot(snapshot) | Resultado ok/code/message/data, sin cambiar sesión, archivos ni diagnósticos vivos |
| restore_state_snapshot(snapshot) | bool; valida antes de sustituir; ante error conserva la sesión y notifica narrative_error |
| session_restored(snapshot) | Copia completa; seguida de node_changed y choices_changed para reconstruir presentación |

Restaurar no emite state_changed, evidence_registered, event_requested ni case_finished. El final ya alcanzado permanece finalizado y sin decisiones. Eventos pendientes permanecen consultables con get_pending_events; consumirlos vuelve a requerir una acción explícita. Las consultas continúan siendo puras. Las mutaciones durante callbacks de restauración están bloqueadas por busy, igual que en 05.

## API de SaveManager

Todas las operaciones devuelven Dictionary con ok, code, message y data. Las consultas no cambian archivos, sesión, diagnósticos del motor ni el último resultado del gestor.

| Método | Resultado/uso |
| --- | --- |
| save_current_session() | Guardado explícito del estado actual estable |
| load_saved_session() | Restauración principal o respaldo compatible |
| restore_backup() | Restauración explícita del respaldo; nunca lo copia al principal |
| has_save() | data.exists y data.backup_exists reflejan existencia, no validez |
| validate_save(backup_only = false) | Validación pura; document normalizado, recovered_from_backup y diagnostics |
| get_save_metadata() | Existencia, valid/recoverable, caso, versión, fecha, nodo/final y origen de recuperación; requiere caso compatible cargado para validación completa |
| delete_save(include_backup = false) | Solicitud explícita de borrado del principal/temporal; conserva respaldo por defecto. true incluye respaldo y su temporal |
| set_autosave_enabled(enabled) | Conecta/desconecta coordinación con el motor; no escribe por sí sola |
| request_autosave() | Solicitud diferida/coalescida; devuelve autosave_queued/unchanged o error |
| flush_pending_save() | Escritura síncrona explícita de cambios pendientes desde un estado estable |
| get_status() | Copia de dirty, busy, writes (confirmados por esta instancia) y autosave_enabled |
| get_last_result() | Copia del último resultado de una operación de archivos mutante |
| get_paths() | Rutas user:// de los cuatro archivos; ninguna ruta absoluta se guarda en el documento |

operation_completed(result) notifica el resultado estructurado de operaciones mutantes; permite a una integración futura informar del error y ofrecer reintento. Sus callbacks reciben copias y no pueden iniciar otro guardado/carga/borrado sobre la misma carpeta. Errores contienen códigos legibles y detalles; no dependen solo de imprimir en consola. No se solicitan permisos especiales.

Borrar no reinicia la sesión en memoria. include_backup=false deja una copia recuperable intencionalmente; para empezar sin ningún checkpoint se requiere delete_save(true). El borrado desactiva autoguardado para que un callback pendiente o una pausa no recree la ranura. Un reinicio de partida y la reactivación posterior son acciones explícitas de la futura integración; aquí no hay botón de borrado o confirmación visual.

## Autoguardado y ciclo de vida

El gestor escucha únicamente state_changed para progresos confirmados: inicio/reinicio, decisión completa con sus transiciones/final, y consumo de evento. Marca dirty y programa una llamada diferida fuera de los callbacks del motor. Señales de nodo/opciones/evidencia/final no producen escrituras adicionales. Varias solicitudes antes del siguiente turno se unen y guardan el estado estable más reciente, no cada estado intermedio. No hay _process, guardado por frame ni archivo por decisión.

La instantánea confirmada completa identifica cambios, no solo revision: reiniciar puede reutilizar una revisión con otro estado. Tras una carga del gestor, session_restored no genera un autoguardado redundante ni repara disco. Una importación directa mediante API del motor sí representa un cambio de memoria respecto del checkpoint conocido; si el autoguardado está activo, queda pendiente. Una carga de contenido limpia el seguimiento hasta iniciar una sesión nueva.

Un fallo conserva dirty, informa operation_completed y get_last_result y permite request_autosave o flush_pending_save posterior. No hay bucle automático de reintentos. La sesión ya comprometida no se revierte por un fallo de disco; cerrar antes del reintento vuelve al último checkpoint confirmado disponible.

save_lifecycle es opcional y solo opera cuando el autoguardado del gestor conectado está activo. Escucha NOTIFICATION_APPLICATION_PAUSED y NOTIFICATION_APPLICATION_FOCUS_OUT para vaciar cambios estables pendientes; NOTIFICATION_APPLICATION_RESUMED/FOCUS_IN permite reintentar pendientes. NOTIFICATION_WM_CLOSE_REQUEST se atiende cuando la plataforma lo entrega. Notificaciones redundantes sin cambios no escriben. prepare_controlled_exit devuelve el resultado antes de que un propietario futuro decida cerrar.

El adaptador no cambia auto_accept_quit, no invoca quit y no se añade a Main en esta fase. La integración futura de una salida controlada debe llamar explícitamente prepare_controlled_exit y revisar su resultado; SceneTree.quit no entrega por sí solo la notificación de cierre. Android puede terminar el proceso sin avisar: los checkpoints posteriores a decisiones son la defensa principal. [Referencia oficial de cierre y suspensión](https://docs.godotengine.org/en/4.7/tutorials/inputs/handling_quit_requests.html).

Ejemplo de uso técnico, no añadido al menú:

```gdscript
const Narrative = preload("res://scripts/narrative/narrative_engine.gd")
const Saves = preload("res://scripts/systems/save_manager.gd")
var engine = Narrative.new()
engine.load_case("res://data/cases/test_narrative.json")
var saves = Saves.new(engine) # producción; pruebas siempre usan carpeta aislada
# Acción explícita: cargar progreso existente o iniciar una sesión nueva.
var result: Dictionary = saves.load_saved_session()
if not result.ok:
    # Mostrar diagnóstico y esperar una decisión; no sobrescribir aquí.
    print(result.code, ": ", result.message)
```

En una sesión técnica nueva autorizada: engine.start_case, set_autosave_enabled(true), request_autosave; después las decisiones se siguen automáticamente. El ejemplo no convierte una carga fallida en una partida nueva ni autoriza reemplazar archivos incompatibles.

## Compatibilidad y ampliación

Cada formato requiere coincidencia exacta de versión de archivo, esquema narrativo, ID, content_version y fingerprint. No hay migraciones automáticas. Un cambio futuro debe introducir un lector/migrador explícito con validación de salida o informar incompatibilidad y conservar originales. El formato 2 de 08 declara los estados/invariantes de investigación descritos a continuación.

### Formato 2 — Investigación

SaveManager.INVESTIGATION_SAVE_VERSION = 2 se elige únicamente cuando el caso cargado declara esquema 2; SAVE_VERSION = 1 sigue siendo la versión legacy. El lector espera esa misma pareja: formato 1/esquema 1 o formato 2/esquema 2. No acepta formato 1 para la nueva investigación ni formato 2 para contenido antiguo. narrative_schema_version y session.schema_version deben coincidir con el caso; no se convierten tipos de manera permisiva.

La raíz conserva exactamente save_version, game_id, case_id, content_version, narrative_schema_version, content_fingerprint, saved_at y session. Session conserva sus 17 campos: evidence contiene los ID descubiertos; executed_actions contiene opciones/consultas/deducciones, con ID únicos por catálogo; applied_effects y applied_once_keys mantienen idempotencia. transaction_log conserva `{node_id, choice_id, revision}`, pero choice_id puede ser una acción/deducción declarada en esquema 2. Efectos externos usan claves investigation:<id>:<índice>. El diario conserva su orden real y el límite total de 2048 operaciones confirmadas incluye estas acciones además de decisiones/consumos.

La validación aislada reconstruye cada entrada por su tipo declarado, verifica condiciones, evidencias requeridas, revisión/nodo y efectos, e intercala consumos. ID inexistentes, conclusiones imposibles o datos incoherentes se rechazan antes de sustituir memoria. No se ejecutan efectos sobre la sesión viva al recuperar ni se emiten nuevos descubrimientos, deduction_confirmed o eventos; tampoco se escribe por cargar. Las conclusiones se reconstruyen desde executed_actions y el catálogo exacto, y las líneas de conversación omiten entradas externas.

No se guarda otra copia de fichas/reglas/conclusiones, ni selección/filtro/detalle de UI. Abrir detalles, una relación insuficiente o ALREADY_DISCOVERED no solicita autoguardado. Confirmar sí produce state_changed y usa el mismo guardado diferido/coalescido. Ante fallo el expediente informa y permite vaciar el estado pendiente, conservando memoria. Recuperar sigue probando principal/respaldo compatibles sin modificar originales; un archivo de otra versión no se migra ni se reemplaza silenciosamente.

Pruebas de 08: nueva instancia de motor/gestor recupera desde disco cinco evidencias y dos deducciones con snapshot/historial idénticos y sin señales de efectos; referencias inventadas y formato 1/esquema 2 rechazados conservando sesión. Fallo de escritura/reintento comprobado en GUI aislada. Las suites antiguas de formato 1 siguen pasando sin modificaciones (114 y 905 comprobaciones). Más resultados en [PROGRESS.md](../PROGRESS.md).

Los contratos narrativos de [CASE_001_TECHNICAL_SPEC.md](../cases/CASE_001_TECHNICAL_SPEC.md) siguen sin implementación: cursores específicos, K02, procedencia de pistas, variantes y recursos se validarán cuando se integre ese caso. Las pruebas PS01–PS13 de su plan continúan siendo futuras; los ensayos de esta fase verifican equivalentes genéricos con el caso técnico, sin afirmar que probaron esos eventos oficiales.

### Formato 3 — Observaciones de audio

SaveManager.AUDIO_SAVE_VERSION = 3, correspondiente al esquema narrativo 3; los tres lectores/escritores exigen que versión y esquema coincidan con el caso cargado. La envoltura conserva ocho campos y session los 17 originales. No hay listas paralelas de grabaciones/desbloqueos, evidencia sonora o deducciones; se derivan de variables, evidence, executed_actions y catálogos.

Una entrada de audio añade analysis a `{node_id, choice_id, revision}`. analysis requiere exactamente recording_id, segment_id, filter_id y listened_ms entero. choice_id es una regla del catálogo sonoro; el tiempo canónico representa el umbral de examen cumplido, no un contador por fotograma. Las entradas de otros tipos y esquemas anteriores rechazan este campo. El nuevo registro justifica contexto/consumo de la regla y mantiene determinismo entre recorridos iguales.

StateValidator comprueba tipos/rangos y normaliza enteros JSON, sin convertir bool/string/fracciones. NarrativeEngine reconstruye en una instancia aislada desbloqueo, condiciones, prueba de contexto/umbral, efectos y consumos intercalados antes de comparar todo el snapshot. Un comprobante corto, ausente, de otro filtro/regla o añadido a diálogo se rechaza. Solo después se sustituye memoria; no se emiten eventos/evidencias nuevos ni se reejecutan consecuencias sobre la sesión viva. No se afirma protección criptográfica frente a modificación deliberada de archivos/código.

Persisten las observaciones confirmadas, sus efectos/eventos y deducciones; escuchas sin confirmar, selección/filtro/posición del reproductor son temporales. Navegar conserva razonablemente la posición en memoria y pausa; restaurar empieza sin audio activo. Nunca se guarda WAV, onda, catálogo o posición en cada frame. Autoguardado sigue state_changed de una transacción estable; un intento insuficiente o repetido no escribe. Cotas de tamaño/profundidad/2048 operaciones y algoritmo de temporal/respaldo no cambian.

Compatibilidad estricta por versión, caso, content_version y fingerprint, sin migración automática. Rechazo conserva originales/sesión y prueba respaldo compatible. Pruebas de 09A guardan/restauran análisis, deducción y consumo de evento intercalado, e inyectan comprobantes/versiones incompatibles sin destruir memoria. Las nueve suites anteriores pasan con fuentes intactas; cifras y comandos en [PROGRESS.md](../PROGRESS.md).

### Formato 4 — Mapa y despacho

Formato 4 para esquema 4, con lectores/escritores 1/2/3 conservados y sin migraciones. La envoltura/sesión conserva ocho/17 campos. Unidad/estado de incidente/asignación son variables enum centrales enlazadas por catálogo, sin diccionarios persistentes paralelos; desbloqueos se derivan de condiciones. Los ID confirmados y efectos usan los registros existentes.

Una entrada operativa añade dispatch al diario de node_id/choice_id/revision. El comando es `{kind: "assign", unit_id, incident_id}` o `{kind: "event", unit_id, incident_id, event_id}`. Campos/tipos/acciones desconocidos se rechazan. choice_id coincide con la asignación generada o parte realmente ejecutado. Entradas operativas no pueden contener también analysis; esquemas anteriores no aceptan dispatch.

La reconstrucción aislada verifica todo el orden mediante la misma API: visibilidad/estado/compatibilidad, disponibilidad única, asignación coincidente y llegada/resultado/liberación autorizados. Se compara el snapshot entero antes de sustituir memoria; variables de asignación inventadas, unidad/incidente desconocidos, comando arbitrario o versión ajena no se reparan silenciosamente. Una unidad ocupada sigue ocupada al restaurar, un resultado no se reactiva y no se publican despachos/evidencias/eventos nuevos.

Temporal/respaldo, compatibilidad exacta por contenido/fingerprint, cotas de 4 MiB/2048 operaciones y autoguardado siguen sus garantías existentes. Seleccionar/revisar/cancelar no escribe; reintento guarda el estado pendiente sin repetir despachos. Demo user://dispatch_demo y pruebas únicas user://save_tests; no se tocan partidas de producción. [MAP_DISPATCH_SYSTEM.md](MAP_DISPATCH_SYSTEM.md) define API, invariantes y procedimientos.

## Comandos y resultados

PowerShell, desde cualquier carpeta:

```powershell
$godotExecutable = 'D:\Descargas\Exe\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe'
& $godotExecutable --headless --path 'D:\Ultima Señal' --import
& $godotExecutable --headless --path 'D:\Ultima Señal' --script res://tests/save/test_save_manager.gd
& $godotExecutable --headless --path 'D:\Ultima Señal' --script res://tests/save/test_save_validation.gd
& $godotExecutable --headless --path 'D:\Ultima Señal' --script res://tests/narrative/test_narrative_engine.gd
& $godotExecutable --headless --path 'D:\Ultima Señal' --script res://tests/narrative/test_narrative_validation.gd
& $godotExecutable --headless --path 'D:\Ultima Señal' --script res://tests/bootstrap_smoke.gd -- 720x1280
& $godotExecutable --headless --path 'D:\Ultima Señal' --script res://tests/navigation_smoke.gd -- 720x1280
& $godotExecutable --path 'D:\Ultima Señal' --script res://tests/navigation_smoke.gd -- 720x1280 'D:/Ultima Señal/docs/validation/prompt_06/720x1280'
```

Las otras resoluciones de regresión usan 1080x1920, 1080x2400 y 720x1600 como argumento de bootstrap/navigation. El ensayo de procesos separados se ejecuta dentro de test_save_manager; no exige copiar archivos manualmente ni usa memoria compartida con el proceso que carga.

| Suite | Resultado ejecutado |
| --- | --- |
| test_save_manager | PASS, 114 comprobaciones; incluye dos procesos separados y notificaciones de ciclo de vida simuladas |
| test_save_validation | PASS, 905 comprobaciones |
| test_narrative_engine | PASS, 151 comprobaciones |
| test_narrative_validation | PASS, 334 comprobaciones |
| Total de suites principales | 1504 comprobaciones, salida 0; los contadores de los workers no se suman otra vez |
| Bootstrap/navegación | PASS headless en cuatro tamaños; navegación gráfica PASS a 720 × 1280 con siete capturas inspeccionadas y 106 nodos estables |
| Importación/arranque | Importación y arranque directo headless/gráfico con salida 0 |

El detalle de los 20 grupos de aceptación, incidencias corregidas y limitaciones se registra en [PROGRESS.md](../PROGRESS.md). Los contadores corresponden a aserciones de las suites, no a ese número de escenarios independientes. La inspección gráfica y las notificaciones simuladas de escritorio no son pruebas de Android.

## Límites y siguiente integración

Sin APK, dispositivo real, corte de energía, llenado físico del disco ni prueba de rendimiento Android. Los errores de escritura/renombrado se inyectan en rutas aisladas, junto con un fallo real de carpeta obstruida; no se provoca daño al almacenamiento del usuario. No se promete durabilidad absoluta ni compatibilidad con versiones futuras desconocidas.

F5 sigue abriendo menú sin sesión o partida oficial. Llamadas permite preparar/recuperar/reiniciar demos de desarrollo, con el mismo SaveLifecycle/gestor compartido por Expedientes/Audio/Mapa. Demos en user://call_demo, user://investigation_demo, user://audio_analysis_demo y user://dispatch_demo, separadas de user://saves. Cargar no reescribe originales; reiniciar elimina solo archivos de ranura técnica, no carpetas/archivos ajenos. Continuar deshabilitado y Caso 001 sin integrar. **10 cerrado; no iniciar 11. 09B pospuesto no bloquea 11.**
