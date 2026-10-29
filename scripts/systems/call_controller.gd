extends RefCounted

signal presentation_changed(view: Dictionary)
signal communication_ended(ending_id: String)

const Narrative = preload("res://scripts/narrative/narrative_engine.gd")
const Saves = preload("res://scripts/systems/save_manager.gd")
enum CallState { IDLE, INCOMING, CONNECTED, ENDED, ERROR }
const DEMO_PATH: String = "res://data/cases/ui_call_demo.json"
const DEMO_DIRECTORY: String = "user://call_demo"
const INVESTIGATION_PATH: String = "res://data/cases/investigation_demo.json"
const INVESTIGATION_DIRECTORY: String = "user://investigation_demo"
const AUDIO_PATH: String = "res://data/audio/audio_analysis_demo.json"
const AUDIO_DIRECTORY: String = "user://audio_analysis_demo"
const DISPATCH_PATH: String = "res://data/maps/dispatch_demo.json"
const DISPATCH_DIRECTORY: String = "user://dispatch_demo"

var engine = Narrative.new()
var saves: RefCounted
var state: CallState = CallState.IDLE
var _busy: bool = false
var _source: String = ""
var _message: String = "Sin comunicación activa."
var _history: Array = []
var _storage_valid: bool = false
var _refresh_queued: bool = false
var _last_error: Dictionary = {}
var _notifying: bool = false
var _disposed: bool = false


func _init(directory: String = DEMO_DIRECTORY, save_script: Script = null) -> void:
	_storage_valid = directory in [DEMO_DIRECTORY, INVESTIGATION_DIRECTORY, AUDIO_DIRECTORY, DISPATCH_DIRECTORY] or (directory.begins_with("user://save_tests/") and directory == directory.simplify_path() and not directory.contains("\\"))
	saves = (save_script if save_script != null else Saves).new(engine, directory if _storage_valid else "")
	saves.operation_completed.connect(_on_save_result)
	engine.node_changed.connect(_on_engine_changed)
	engine.choices_changed.connect(_on_engine_changed)
	engine.session_restored.connect(_on_engine_changed)


func prepare_call(path: String = DEMO_PATH) -> Dictionary:
	if _locked():
		return _result(false, "busy", "Espere a que termine la operación actual.")
	if state in [CallState.INCOMING, CallState.CONNECTED, CallState.ENDED]:
		return _reject("call_exists", "Ya existe una comunicación. Reinicie explícitamente la demostración para comenzar otra.")
	if not _storage_valid:
		state = CallState.ERROR
		return _reject("invalid_demo_storage", "La demostración requiere un espacio de guardado aislado.")
	_busy = true
	if not engine.load_case(path):
		state = CallState.ERROR
		_busy = false
		return _engine_failure("Error al cargar la comunicación de prueba.")
	_source = path
	_history = []
	state = CallState.INCOMING
	_message = "Llamada entrante · demostración técnica, fuera de la campaña."
	_last_error = {}
	_busy = false
	_publish()
	return _result(true, "incoming", _message)


func answer_call() -> Dictionary:
	if _locked():
		return _result(false, "busy", "Espere a que termine la operación actual.")
	if state != CallState.INCOMING:
		return _reject("not_incoming", "No hay una llamada entrante que responder.")
	_busy = true
	saves.set_autosave_enabled(true)
	if not engine.start_case():
		state = CallState.ERROR
		_busy = false
		return _engine_failure("No se pudo conectar la comunicación.")
	_last_error = {}
	_refresh()
	_busy = false
	_publish()
	return _result(true, "connected", "Comunicación conectada.")


func select_choice(choice_id: String, expected_revision: int) -> Dictionary:
	if _locked():
		return _result(false, "busy", "Espere a que termine la operación actual.")
	if state != CallState.CONNECTED:
		return _reject("not_connected", "La comunicación no admite respuestas en este momento.")
	_busy = true
	if not engine.select_choice(choice_id, expected_revision):
		_busy = false
		return _engine_failure("La respuesta ya no está disponible. Revise las opciones actuales.")
	_last_error = {}
	_refresh()
	_busy = false
	_publish()
	return _result(true, "choice_confirmed", "Respuesta confirmada.")


func restore_call(path: String = DEMO_PATH) -> Dictionary:
	if _locked() or not _storage_valid:
		return _reject("busy", "No se puede recuperar la llamada ahora.")
	# Load a known case only when no session exists. Failed restoration preserves
	# both an existing live session and its visible transcript.
	if _source.is_empty():
		if not engine.load_case(path):
			state = CallState.ERROR
			return _engine_failure("No se pudo cargar el contenido de la prueba.")
		_source = path
	_busy = true
	var was_autosave_enabled: bool = saves.get_status().data.autosave_enabled
	saves.set_autosave_enabled(false)
	var result: Dictionary = saves.load_saved_session()
	if result.ok:
		_last_error = {}
		_refresh()
		_message = "Comunicación recuperada desde el respaldo." if result.code == "restored_backup" else "Comunicación recuperada."
	elif engine.get_state_snapshot().is_empty():
		state = CallState.ERROR
	_busy = false
	if not result.ok:
		saves.set_autosave_enabled(was_autosave_enabled)
		return _reject(result.code, result.message, result.data)
	saves.set_autosave_enabled(true)
	_publish()
	return result


func restart_demo() -> Dictionary:
	if _locked():
		return _result(false, "busy", "Espere a que termine la operación actual.")
	if _source.is_empty():
		return _reject("no_demo", "Primero prepare una demostración.")
	_busy = true
	var deleted: Dictionary = saves.delete_save(true)
	if not deleted.ok:
		_busy = false
		return _reject(deleted.code, deleted.message, deleted.data)
	if not engine.load_case(_source):
		state = CallState.ERROR
		_busy = false
		return _engine_failure("No se pudo reiniciar la prueba.")
	_history = []
	_last_error = {}
	state = CallState.INCOMING
	_message = "Prueba reiniciada · llamada entrante."
	_busy = false
	_publish()
	return _result(true, "restarted", _message)


func retry_save() -> Dictionary:
	if _locked():
		return _result(false, "busy", "Espere a que termine la operación actual.")
	return saves.flush_pending_save()


func get_view() -> Dictionary:
	var node: Dictionary = engine.get_current_node()
	return {"state": CallState.keys()[state], "busy": _busy, "caller": node.get("speaker_name", "Número desconocido"), "case_id": engine.get_case_metadata().get("case_id", ""), "message": _message, "history": _history.duplicate(true), "choices": engine.get_available_choices() if state == CallState.CONNECTED else [], "ending_id": engine.get_ending_id(), "error": _last_error.duplicate(true)}


func _refresh() -> void:
	if engine.get_state_snapshot().is_empty():
		return
	var previously_ended: bool = state == CallState.ENDED
	state = CallState.ENDED if engine.is_case_finished() else CallState.CONNECTED
	_history = engine.get_conversation_history()
	_message = "Comunicación finalizada · resultado de prueba: " + engine.get_ending_id() if state == CallState.ENDED else "Comunicación activa · seleccione una respuesta."
	if state == CallState.ENDED and not previously_ended:
		communication_ended.emit(engine.get_ending_id())


func _on_engine_changed(_value: Variant) -> void:
	if _busy or _refresh_queued:
		return
	_refresh_queued = true
	call_deferred("_refresh_external")


func _refresh_external() -> void:
	_refresh_queued = false
	if not _busy and not _disposed:
		_refresh()
		_publish()


func _on_save_result(result: Dictionary) -> void:
	if not result.ok:
		_last_error = result.duplicate(true)
		_log_diagnostic(_last_error)
		_message = "No se pudo guardar. El progreso sigue en memoria; puede reintentar."
	elif result.code == "saved" and not _last_error.is_empty():
		_last_error = {}
		_message = "Progreso guardado."
	if not _busy:
		_publish()


func _engine_failure(message: String) -> Dictionary:
	return _reject("narrative_error", message, engine.get_diagnostics())


func _reject(code: String, message: String, details: Dictionary = {}) -> Dictionary:
	_last_error = _result(false, code, message, details)
	_log_diagnostic(_last_error)
	_message = message
	_publish()
	return _last_error.duplicate(true)


func _publish() -> void:
	if _notifying:
		return
	_notifying = true
	presentation_changed.emit(get_view())
	_notifying = false


func _locked() -> bool:
	return _disposed or _busy or _notifying or engine.is_busy()


func dispose() -> void:
	if _disposed:
		return
	_disposed = true
	saves.set_autosave_enabled(false)
	saves.operation_completed.disconnect(_on_save_result)
	engine.node_changed.disconnect(_on_engine_changed)
	engine.choices_changed.disconnect(_on_engine_changed)
	engine.session_restored.disconnect(_on_engine_changed)
	for connection: Dictionary in presentation_changed.get_connections():
		presentation_changed.disconnect(connection.callable)
	for connection: Dictionary in communication_ended.get_connections():
		communication_ended.disconnect(connection.callable)


func _result(ok: bool, code: String, message: String, data: Dictionary = {}) -> Dictionary:
	return {"ok": ok, "code": code, "message": message, "data": data.duplicate(true)}


func _log_diagnostic(result: Dictionary) -> void:
	if OS.is_debug_build():
		print("CALL_DIAGNOSTIC ", JSON.stringify(result, "", true, true))
