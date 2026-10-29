extends RefCounted

signal changed
const Catalog = preload("res://scripts/systems/audio_catalog_validator.gd")
const Conditions = preload("res://scripts/narrative/condition_evaluator.gd")
const Evidence = preload("res://scripts/systems/evidence_manager.gd")
var engine: RefCounted
var playback: Node
var evidence: RefCounted
var _qualified: Dictionary = {}
var _revision: int = 0
var _catalog: Dictionary = {}


func _init(narrative: RefCounted, physical_player: Node) -> void:
	engine = narrative
	_catalog = engine.get_audio_catalog()
	playback = physical_player
	evidence = Evidence.new(engine)
	playback.progressed.connect(_on_progress)
	playback.changed.connect(_on_playback_changed)
	engine.state_changed.connect(_on_state)
	engine.case_loaded.connect(_on_reset)
	engine.session_restored.connect(_on_reset)


func get_recordings() -> Array:
	var result: Array = []
	for record: Dictionary in _catalog.get("recordings", []):
		if _available(record):
			result.append({"recording_id": record.recording_id, "title": record.title, "description": record.description, "duration": record.duration, "confirmed": _confirmed_count(record.recording_id)})
	return result


func get_recording(id: String) -> Dictionary:
	var record: Dictionary = _record(id)
	if record.is_empty():
		return _result(false, "UNAVAILABLE", "La grabación no está disponible.")
	var projected: Dictionary = {"recording_id": record.recording_id, "title": record.title, "description": record.description, "duration": record.duration, "segments": record.segments.duplicate(true), "waveform": record.get("waveform", []).duplicate(), "variants": []}
	projected.capture_information = []
	for info: Dictionary in record.get("capture_information", []):
		if Conditions.evaluate(info.condition, engine.get_state_snapshot()):
			projected.capture_information.append(info.text)
	for variant: Dictionary in record.variants:
		var available: bool = variant.get("available", true) and Catalog.resolve_stream(variant.audio_path) != null
		projected.variants.append({"filter_id": variant.filter_id, "label": variant.label, "available": available, "text_only": variant.get("available") == false and variant.audio_path == "", "reason": "" if available else "Grabación pendiente · transcripción disponible."})
	return _result(true, "AVAILABLE", "", projected)


func select_recording(id: String) -> Dictionary:
	var record: Dictionary = _record(id)
	if record.is_empty():
		return _result(false, "UNAVAILABLE", "La grabación no está disponible.")
	return playback.load_recording(record)


func set_filter(id: String) -> Dictionary:
	if _current().is_empty():
		return _result(false, "UNAVAILABLE", "Seleccione una grabación disponible.")
	return playback.set_filter(id)


func play_segment(id: String) -> Dictionary:
	if _current().is_empty():
		return _result(false, "UNAVAILABLE", "Seleccione una grabación disponible.")
	return playback.play_segment(id)


func get_accessible_information() -> String:
	var segment: Dictionary = Catalog.find_segment(_current(), playback.get_view().segment_id)
	return segment.get("accessible_information", {}).get(playback.get_view().filter_id, "Seleccione un intervalo para consultar su descripción sonora equivalente.")


func consult_selected() -> Dictionary:
	if _current().is_empty() or playback.get_view().segment_id.is_empty():
		return _result(false, "UNAVAILABLE", "Seleccione un fragmento y una variante.")
	for rule: Dictionary in _matching_rules():
		if rule.get("discovery_mode") == "consult":
			_qualified[rule.id] = {"recording_id": rule.recording_id, "segment_id": rule.segment_id, "filter_id": rule.filter_id, "listened_ms": ceili(rule.min_listen_seconds * 1000.0)}
			return register_observation(rule.id)
	return _result(true, "CONSULTED", get_accessible_information())


func get_observations() -> Array:
	var result: Array = []
	for rule: Dictionary in _matching_rules():
		var confirmed: bool = rule.id in engine.get_state_snapshot().get("executed_actions", [])
		var ready: bool = _qualified.has(rule.id) and _condition(rule) and not engine.is_case_finished()
		if not confirmed and not ready:
			continue
		# No clue names, hidden evidence, missing totals or solution hints.
		result.append({"id": rule.id, "registered": confirmed, "ready": ready, "title": "Observación registrada" if confirmed else ("Observación lista para registrar" if ready else "Examine el intervalo antes de registrar una observación")})
	return result


func register_observation(rule_id: String = "") -> Dictionary:
	if _current().is_empty():
		return _result(false, "UNAVAILABLE", "Seleccione una grabación disponible.")
	for rule: Dictionary in _matching_rules():
		if not rule_id.is_empty() and rule.id != rule_id:
			continue
		if rule.id in engine.get_state_snapshot().executed_actions:
			return _result(true, "ALREADY_DISCOVERED", "Esta observación ya está registrada en Expedientes.")
		if engine.is_case_finished() or not _condition(rule):
			return _result(false, "LOCKED", "La investigación no admite este descubrimiento ahora.")
		if not _qualified.has(rule.id):
			return _result(false, "INSUFFICIENT", "Escuche o examine la descripción equivalente durante el fragmento antes de registrar.")
		var report: Dictionary = evidence.discover_from_audio(rule.id, _qualified[rule.id], engine.get_state_snapshot().revision)
		if report.ok:
			report.message = "Observación registrada. La evidencia está disponible en Expedientes."
		return report
	return _result(false, "INSUFFICIENT", "Este intervalo y filtro no permiten registrar una observación concluyente. Puede explorar otras combinaciones.")


func _matching_rules() -> Array:
	var result: Array = []
	if _current().is_empty():
		return result
	var view: Dictionary = playback.get_view()
	for rule: Dictionary in _catalog.get("discovery_rules", []):
		if rule.recording_id == view.recording_id and rule.segment_id == view.segment_id and rule.filter_id == view.filter_id:
			result.append(rule)
	return result


func _on_progress(view: Dictionary) -> void:
	var updated: bool = false
	if _current().is_empty():
		return
	for rule: Dictionary in _matching_rules():
		if not _qualified.has(rule.id) and view.listened_seconds >= rule.min_listen_seconds:
			_qualified[rule.id] = {"recording_id": rule.recording_id, "segment_id": rule.segment_id, "filter_id": rule.filter_id, "listened_ms": ceili(rule.min_listen_seconds * 1000.0)}
			updated = true
	if updated:
		changed.emit()


func _available(record: Dictionary) -> bool:
	var state: Dictionary = engine.get_state_snapshot()
	return not state.is_empty() and Conditions.evaluate(record.unlocked_by, state)


func _record(id: String) -> Dictionary:
	for record: Dictionary in _catalog.get("recordings", []):
		if record.recording_id == id and _available(record):
			return record
	return {}


func _current() -> Dictionary:
	return _record(playback.get_view().recording_id)


func _condition(rule: Dictionary) -> bool:
	return Conditions.evaluate(rule.get("additional_conditions", {"op": "always"}), engine.get_state_snapshot())


func _confirmed_count(recording_id: String) -> int:
	var count: int = 0
	for rule: Dictionary in _catalog.get("discovery_rules", []):
		if rule.recording_id == recording_id and rule.id in engine.get_state_snapshot().get("executed_actions", []):
			count += 1
	return count


func _on_playback_changed(_view: Dictionary) -> void:
	changed.emit()


func _on_reset(_value: Variant) -> void:
	_catalog = engine.get_audio_catalog()
	_qualified.clear()
	_revision = 0
	playback.clear()
	changed.emit()


func _on_state(state: Dictionary) -> void:
	if state.revision < _revision:
		_on_reset(state)
	_revision = state.revision
	if not playback.get_view().recording_id.is_empty() and _current().is_empty():
		playback.clear()
	if state.finished:
		playback.pause()
	changed.emit()


func dispose() -> void:
	playback.pause()
	playback.progressed.disconnect(_on_progress)
	playback.changed.disconnect(_on_playback_changed)
	engine.state_changed.disconnect(_on_state)
	engine.case_loaded.disconnect(_on_reset)
	engine.session_restored.disconnect(_on_reset)
	evidence.dispose()


func _result(ok: bool, code: String, message: String, data: Dictionary = {}) -> Dictionary:
	return {"ok": ok, "code": code, "message": message, "data": data.duplicate(true)}
