extends RefCounted

signal operation_completed(result: Dictionary)

const StateValidator = preload("res://scripts/narrative/narrative_state_validator.gd")
const SAVE_VERSION: int = 1
const INVESTIGATION_SAVE_VERSION: int = 2
const AUDIO_SAVE_VERSION: int = 3
const DISPATCH_SAVE_VERSION: int = 4
const GAME_ID: String = "ultima_senal"
const DEFAULT_DIRECTORY: String = "user://saves"
const MAX_FILE_BYTES: int = 4 * 1024 * 1024
const DOCUMENT_FIELDS: Array[String] = ["save_version", "game_id", "case_id", "content_version", "narrative_schema_version", "content_fingerprint", "saved_at", "session"]
const SLOT_FILES: Array[String] = ["slot_01.json", "slot_01.tmp", "slot_01.bak", "slot_01.bak.tmp"]

# Main-thread service. Shared locks cover distinct managers using the same directory.
static var _directory_locks: Dictionary = {}
var _engine: RefCounted
var _directory: String
var _busy: bool = false
var _autosave_enabled: bool = false
var _autosave_queued: bool = false
var _dirty: bool = false
var _persisted_snapshot: Dictionary = {}
var _last_result: Dictionary = {}
var _write_count: int = 0


func _init(engine: RefCounted = null, directory: String = DEFAULT_DIRECTORY) -> void:
	_engine = engine
	_directory = directory
	if not directory.begins_with("user://") or directory == "user://" or directory != directory.simplify_path() or directory.contains("\\") or directory.ends_with("/"):
		_directory = ""


func get_last_result() -> Dictionary:
	return _last_result.duplicate(true)


func get_status() -> Dictionary:
	return _result(true, "status", "Estado del gestor.", {"dirty": _needs_save(), "busy": _busy, "writes": _write_count, "autosave_enabled": _autosave_enabled})


func get_paths() -> Dictionary:
	if _directory.is_empty():
		return {}
	return {"main": _path("slot_01.json"), "temporary": _path("slot_01.tmp"), "backup": _path("slot_01.bak"), "backup_temporary": _path("slot_01.bak.tmp")}


func has_save() -> Dictionary:
	if _directory.is_empty():
		return _result(false, "invalid_directory", "La carpeta debe ser una ruta canónica dentro de user://.")
	return _result(true, "save_presence", "Existencia de archivos de la ranura.", {"exists": FileAccess.file_exists(_path("slot_01.json")), "backup_exists": FileAccess.file_exists(_path("slot_01.bak"))})


func get_save_metadata() -> Dictionary:
	var presence: Dictionary = has_save()
	if not presence.ok:
		return presence
	var selected: Dictionary = validate_save()
	var data: Dictionary = presence.data.duplicate(true)
	data.valid = selected.ok
	data.recoverable = selected.ok
	data.recovered_from_backup = selected.get("data", {}).get("recovered_from_backup", false)
	if selected.ok:
		data.merge(_metadata(selected.data.document), true)
	data.diagnostics = selected.data.get("diagnostics", []).duplicate(true)
	return _result(true, "save_metadata", "Estado de la ranura; consulte valid y recoverable.", data)


func validate_save(backup_only: bool = false) -> Dictionary:
	if _directory.is_empty() or _engine == null:
		return _result(false, "not_configured", "Se requiere un motor con contenido y una carpeta válida.")
	var diagnostics: Array = []
	if not backup_only:
		var main: Dictionary = _read_document(_path("slot_01.json"))
		if main.ok:
			return _result(true, "valid_save", "Guardado principal válido.", {"document": main.data.document, "recovered_from_backup": false, "diagnostics": []})
		diagnostics.append(_diagnostic("slot_01.json", main))
	var backup: Dictionary = _read_document(_path("slot_01.bak"))
	if backup.ok:
		return _result(true, "backup_available", "Respaldo válido disponible; los archivos no se han modificado.", {"document": backup.data.document, "recovered_from_backup": true, "diagnostics": diagnostics})
	diagnostics.append(_diagnostic("slot_01.bak", backup))
	var missing: bool = true
	for diagnostic: Dictionary in diagnostics:
		missing = missing and diagnostic.code == "missing_save"
	return _result(false, "missing_save" if missing else "unrecoverable_save", "No existe un guardado recuperable." if missing else "No se pudo validar el principal ni el respaldo; se conservan los archivos.", {"diagnostics": diagnostics})


func save_current_session() -> Dictionary:
	if _directory.is_empty():
		return _result(false, "invalid_directory", "La carpeta de guardado no es válida.")
	if not _acquire():
		return _result(false, "busy", "Ya hay una operación sobre esta ranura.")
	var result: Dictionary = _save()
	return _complete(result)


func _save() -> Dictionary:
	if _engine == null or _engine.is_busy():
		return _result(false, "engine_busy", "El motor debe estar disponible en un punto estable.")
	var snapshot: Dictionary = _engine.get_state_snapshot()
	if snapshot.is_empty():
		return _result(false, "no_session", "No hay una sesión iniciada para guardar.")
	_dirty = true
	var metadata: Dictionary = _engine.get_case_metadata()
	var document: Dictionary = {
		"save_version": int(metadata.narrative_schema_version), "game_id": GAME_ID,
		"case_id": metadata.case_id, "content_version": metadata.content_version,
		"narrative_schema_version": metadata.narrative_schema_version,
		"content_fingerprint": metadata.content_fingerprint,
		"saved_at": Time.get_datetime_string_from_system(true) + "Z", "session": snapshot,
	}
	var validation: Dictionary = _validate_document(document)
	if not validation.ok:
		return validation
	var ancestor: String = _directory
	while ancestor != "user://":
		if FileAccess.file_exists(ancestor):
			return _result(false, "directory_error", "Un archivo impide crear la carpeta de guardado.")
		ancestor = ancestor.get_base_dir()
	var mkdir_error: Error = DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(_directory))
	if mkdir_error != OK:
		return _io_failure("directory_error", "No se pudo preparar la carpeta", mkdir_error)
	var staged: Dictionary = _write_and_verify(_path("slot_01.tmp"), document)
	if not staged.ok:
		return staged
	var previous: Dictionary = _read_document(_path("slot_01.json"))
	var backup: Dictionary = _read_document(_path("slot_01.bak"))
	# An incompatible or damaged existing primary needs an explicit decision if
	# no compatible backup exists. A failed load never authorizes replacement.
	if not previous.ok and previous.code != "missing_save" and not backup.ok:
		return _result(false, "replacement_required", "El principal no es válido y no hay respaldo compatible. Conserve o elimine explícitamente la ranura antes de reemplazarla.", {"primary_error": previous.code, "backup_error": backup.code})
	if previous.ok:
		var staged_backup: Dictionary = _write_and_verify(_path("slot_01.bak.tmp"), previous.data.document)
		if not staged_backup.ok:
			return staged_backup
		var backup_error: Error = _rename_file(_path("slot_01.bak.tmp"), _path("slot_01.bak"))
		if backup_error != OK:
			return _io_failure("backup_replace_error", "No se pudo confirmar el respaldo; el principal no se reemplazó", backup_error)
		var checked_backup: Dictionary = _read_document(_path("slot_01.bak"))
		if not checked_backup.ok or checked_backup.data.document != previous.data.document:
			return _result(false, "backup_verify_error", "No se confirmó el respaldo; el principal no se reemplazó.")
	var replace_error: Error = _rename_file(_path("slot_01.tmp"), _path("slot_01.json"))
	if replace_error != OK:
		return _io_failure("replace_error", "No se pudo confirmar el principal; se conserva el respaldo disponible", replace_error)
	var confirmed: Dictionary = _read_document(_path("slot_01.json"))
	if not confirmed.ok or confirmed.data.document != validation.data.document:
		return _result(false, "commit_verify_error", "El principal no pasó la verificación final; consulte el respaldo.")
	_persisted_snapshot = snapshot.duplicate(true)
	_dirty = false
	_write_count += 1
	return _result(true, "saved", "Partida guardada y verificada.", _metadata(document))


func load_saved_session() -> Dictionary:
	return _load(false)


func restore_backup() -> Dictionary:
	return _load(true)


func _load(backup_only: bool) -> Dictionary:
	if _directory.is_empty():
		return _result(false, "invalid_directory", "La carpeta de guardado no es válida.")
	if not _acquire():
		return _result(false, "busy", "Ya hay una operación sobre esta ranura.")
	var validation: Dictionary = validate_save(backup_only)
	if validation.ok:
		if _engine.is_busy() or not _engine.restore_state_snapshot(validation.data.document.session):
			validation = _result(false, "restore_failed", "No se reemplazó la sesión activa.")
		else:
			_persisted_snapshot = _engine.get_state_snapshot()
			_dirty = false
			validation = _result(true, "restored_backup" if validation.data.recovered_from_backup else "loaded", "Sesión restaurada desde el respaldo; archivos originales conservados." if validation.data.recovered_from_backup else "Sesión restaurada.", {"metadata": _metadata(validation.data.document), "recovered_from_backup": validation.data.recovered_from_backup, "diagnostics": validation.data.diagnostics})
	return _complete(validation)


func delete_save(include_backup: bool = false) -> Dictionary:
	if _directory.is_empty():
		return _result(false, "invalid_directory", "La carpeta de guardado no es válida.")
	if not _acquire():
		return _result(false, "busy", "Ya hay una operación sobre esta ranura.")
	var targets: Array[String] = ["slot_01.json", "slot_01.tmp"]
	if include_backup:
		targets.assign(SLOT_FILES)
	var deleted: Array[String] = []
	for filename: String in targets:
		if not FileAccess.file_exists(_path(filename)):
			continue
		var error: Error = DirAccess.remove_absolute(_path(filename))
		if error != OK:
			return _complete(_result(false, "delete_error", "Borrado parcial; no se eliminaron otros archivos.", {"deleted": deleted, "failed_file": filename, "error": error_string(error)}))
		deleted.append(filename)
	_persisted_snapshot = {}
	_dirty = _engine != null and not _engine.get_state_snapshot().is_empty()
	# Explicit deletion disarms autosave so it cannot recreate the slot by itself.
	set_autosave_enabled(false)
	return _complete(_result(true, "deleted", "Archivos solicitados eliminados; sesión en memoria conservada.", {"deleted": deleted, "backup_preserved": not include_backup}))


func set_autosave_enabled(enabled: bool) -> Dictionary:
	if _engine == null:
		return _result(false, "not_configured", "Se requiere un motor narrativo.")
	var state_callback: Callable = Callable(self, "_on_state_changed")
	var restore_callback: Callable = Callable(self, "_on_restored")
	var content_callback: Callable = Callable(self, "_on_case_loaded")
	if enabled and not _autosave_enabled:
		_engine.state_changed.connect(state_callback)
		_engine.session_restored.connect(restore_callback)
		_engine.case_loaded.connect(content_callback)
	elif not enabled and _autosave_enabled:
		_engine.state_changed.disconnect(state_callback)
		_engine.session_restored.disconnect(restore_callback)
		_engine.case_loaded.disconnect(content_callback)
	_autosave_enabled = enabled
	if enabled:
		_dirty = _engine.get_state_snapshot() != _persisted_snapshot
	return _result(true, "autosave_enabled" if enabled else "autosave_disabled", "Política de autoguardado actualizada.")


func request_autosave() -> Dictionary:
	if not _autosave_enabled:
		return _result(false, "autosave_disabled", "El coordinador no está activado.")
	if _engine == null or _engine.get_state_snapshot().is_empty():
		return _result(false, "no_session", "No hay sesión para autoguardar.")
	_dirty = _needs_save()
	if not _dirty:
		return _result(true, "unchanged", "No hay cambios pendientes.")
	if not _autosave_queued:
		_autosave_queued = true
		call_deferred("_flush_autosave")
	return _result(true, "autosave_queued", "Autoguardado solicitado para el siguiente punto estable.")


func flush_pending_save() -> Dictionary:
	if _engine == null or _engine.get_state_snapshot().is_empty():
		return _result(true, "no_session", "No hay progreso que guardar.")
	_dirty = _needs_save()
	if not _dirty:
		return _result(true, "unchanged", "No hay cambios pendientes.")
	return save_current_session()


func _needs_save() -> bool:
	if _engine == null:
		return false
	var snapshot: Dictionary = _engine.get_state_snapshot()
	return not snapshot.is_empty() and (_dirty or snapshot != _persisted_snapshot)


func _on_state_changed(snapshot: Dictionary) -> void:
	_dirty = snapshot != _persisted_snapshot
	request_autosave()


func _on_restored(snapshot: Dictionary) -> void:
	if not _busy:
		_dirty = snapshot != _persisted_snapshot
		request_autosave()


func _on_case_loaded(_case_id: String) -> void:
	_persisted_snapshot = {}
	_dirty = false


func _flush_autosave() -> void:
	_autosave_queued = false
	if _autosave_enabled and _dirty:
		flush_pending_save()


func _validate_document(value: Variant) -> Dictionary:
	if not value is Dictionary or not StateValidator.json_safe(value, 0, [0]) or not StateValidator.has_fields(value, DOCUMENT_FIELDS):
		return _result(false, "invalid_save", "Formato incompleto, campos desconocidos o valores no JSON.")
	var loaded_schema: int = int(_engine.get_case_metadata().get("narrative_schema_version", 1)) if _engine != null else 1
	var expected_save_version: int = loaded_schema
	if not StateValidator.is_integer(value.save_version, expected_save_version, expected_save_version):
		return _result(false, "incompatible_save_version", "Versión de guardado no compatible.")
	for field: String in ["game_id", "case_id", "content_version", "content_fingerprint", "saved_at"]:
		if not value[field] is String:
			return _result(false, "invalid_metadata", "Se esperaba texto en " + field)
	if not StateValidator.is_integer(value.narrative_schema_version, 1, 4):
		return _result(false, "incompatible_content", "Esquema narrativo no compatible.")
	if value.game_id != GAME_ID:
		return _result(false, "wrong_game", "El archivo no pertenece a Última Señal.")
	var metadata: Dictionary = _engine.get_case_metadata() if _engine != null else {}
	if metadata.is_empty():
		return _result(false, "case_not_loaded", "Cargue primero el contenido narrativo asociado.")
	for field: String in ["case_id", "content_version", "content_fingerprint", "narrative_schema_version"]:
		if value[field] != metadata[field]:
			return _result(false, "incompatible_content", "Caso o contenido incompatible: " + field)
	if not _valid_timestamp(value.saved_at):
		return _result(false, "invalid_metadata", "Esquema narrativo o fecha UTC inválida.")
	if not value.session is Dictionary:
		return _result(false, "invalid_snapshot", "Falta un objeto de sesión válido.")
	var state: Dictionary = _engine.validate_state_snapshot(value.session)
	if not state.ok:
		return _result(false, state.code, state.message)
	var document: Dictionary = value.duplicate(true)
	document.save_version = int(document.save_version)
	document.narrative_schema_version = int(document.narrative_schema_version)
	document.session = state.data
	return _result(true, "valid_save", "Guardado validado.", {"document": document})


func _valid_timestamp(value: String) -> bool:
	var expression: RegEx = RegEx.new()
	expression.compile("^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}Z$")
	if expression.search(value) == null:
		return false
	var year: int = int(value.substr(0, 4))
	var month: int = int(value.substr(5, 2))
	var day: int = int(value.substr(8, 2))
	if year < 1 or month < 1 or month > 12:
		return false
	var days: Array[int] = [31, 29 if year % 4 == 0 and (year % 100 != 0 or year % 400 == 0) else 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
	return day >= 1 and day <= days[month - 1] and int(value.substr(11, 2)) < 24 and int(value.substr(14, 2)) < 60 and int(value.substr(17, 2)) < 60


func _read_document(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return _result(false, "missing_save", "Archivo de guardado inexistente.")
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	if file == null:
		return _io_failure("read_error", "No se pudo abrir el guardado", FileAccess.get_open_error())
	if file.get_length() > MAX_FILE_BYTES:
		file.close()
		return _result(false, "save_limit", "El archivo supera 4 MiB.")
	var content: String = file.get_as_text()
	var read_error: Error = file.get_error()
	file.close()
	if read_error not in [OK, ERR_FILE_EOF]:
		return _io_failure("read_error", "No se pudo leer el guardado", read_error)
	var parser: JSON = JSON.new()
	if parser.parse(content) != OK:
		return _result(false, "invalid_json", "JSON inválido en línea %d: %s" % [parser.get_error_line(), parser.get_error_message()])
	return _validate_document(parser.data)


func _write_and_verify(path: String, document: Dictionary) -> Dictionary:
	var text: String = JSON.stringify(document, "\t", true, true)
	var bytes: PackedByteArray = text.to_utf8_buffer()
	if bytes.size() > MAX_FILE_BYTES:
		return _result(false, "save_limit", "El estado supera el límite de 4 MiB.")
	var error: Error = _write_text(path, text)
	if error != OK:
		return _io_failure("write_error", "No se pudo escribir o vaciar el temporal", error)
	var checked: Dictionary = _read_document(path)
	if not checked.ok or checked.data.document != document:
		return _result(false, "temporary_verify_error", "El temporal no coincide con la instantánea validada.")
	return _result(true, "staged", "Temporal escrito y validado.")


func _write_text(path: String, text: String) -> Error:
	var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return FileAccess.get_open_error()
	file.store_string(text)
	file.flush()
	var error: Error = file.get_error()
	if error == OK and file.get_position() != text.to_utf8_buffer().size():
		error = ERR_FILE_CANT_WRITE
	file.close()
	return error


func _rename_file(from: String, to: String) -> Error:
	return DirAccess.rename_absolute(from, to)


func _acquire() -> bool:
	if _busy or _directory.is_empty() or _directory_locks.has(_lock_key()):
		return false
	_busy = true
	_directory_locks[_lock_key()] = true
	return true


func _complete(result: Dictionary) -> Dictionary:
	_last_result = result.duplicate(true)
	operation_completed.emit(result.duplicate(true))
	_directory_locks.erase(_lock_key())
	_busy = false
	return result.duplicate(true)


func _path(filename: String) -> String:
	return _directory.path_join(filename)


func _lock_key() -> String:
	var key: String = ProjectSettings.globalize_path(_directory).simplify_path()
	return key.to_lower() if OS.has_feature("windows") else key


func _metadata(document: Dictionary) -> Dictionary:
	return {"save_version": int(document.save_version), "case_id": document.case_id, "content_version": document.content_version, "saved_at": document.saved_at, "finished": document.session.finished, "current_node": document.session.current_node, "ending_id": document.session.ending_id}


func _diagnostic(filename: String, result: Dictionary) -> Dictionary:
	return {"file": filename, "code": result.code, "message": result.message}


func _io_failure(code: String, message: String, error: Error) -> Dictionary:
	return _result(false, code, message + ": " + error_string(error), {"error": int(error)})


func _result(ok: bool, code: String, message: String, data: Dictionary = {}) -> Dictionary:
	return {"ok": ok, "code": code, "message": message, "data": data}
