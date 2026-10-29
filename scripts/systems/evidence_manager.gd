extends RefCounted

signal evidence_discovered(evidence_id: String)

const CATEGORIES: Dictionary = {"testimony": "Testimonios", "document": "Documentos", "record": "Registros", "audio": "Audio", "anomaly": "Anomalías"}
const IMPORTANCE: Array[String] = ["essential", "optional", "contextual"]
var _engine: RefCounted


func _init(engine: RefCounted) -> void:
	_engine = engine
	_engine.evidence_registered.connect(_on_discovered)


func get_discovered(category: String = "") -> Array:
	var result: Array = []
	var state: Dictionary = _engine.get_state_snapshot()
	for record: Dictionary in _engine.get_investigation_catalog().get("evidence", []):
		if record.id in state.get("evidence", []) and (category.is_empty() or record.category == category):
			result.append(_project(record))
	result.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return a.order < b.order if a.order != b.order else a.id < b.id)
	return result


func get_detail(evidence_id: String) -> Dictionary:
	for record: Dictionary in get_discovered():
		if record.id == evidence_id:
			return {"ok": true, "code": "DISCOVERED", "message": "Evidencia disponible.", "data": record.duplicate(true)}
	return {"ok": false, "code": "UNAVAILABLE", "message": "La evidencia no está disponible.", "data": {}}


func get_categories() -> Array:
	var result: Array = []
	var seen: Dictionary = {}
	for record: Dictionary in get_discovered():
		seen[record.category] = true
	for key: String in CATEGORIES:
		if seen.has(key):
			result.append({"id": key, "title": CATEGORIES[key]})
	return result


func discover_from_action(action_id: String, expected_revision: int = -1) -> Dictionary:
	return _engine.process_investigation_action(action_id, expected_revision)


func get_available_actions() -> Array:
	return _engine.get_investigation_actions()


func discover_from_audio(rule_id: String, playback_proof: Dictionary, expected_revision: int = -1) -> Dictionary:
	return _engine.register_audio_observation(rule_id, playback_proof, expected_revision)


static func process_dispatch_event(narrative: RefCounted, command: Dictionary, expected_revision: int = -1) -> Dictionary:
	# The engine owns the atomic resource transition and evidence effects.
	return narrative.process_dispatch(command, expected_revision)


func _project(record: Dictionary) -> Dictionary:
	var path: String = record.get("related_asset", "")
	var available: bool = not path.is_empty() and ResourceLoader.exists(path, "Texture2D")
	return {"id": record.id, "title": record.title, "description": record.description, "category": record.category, "category_label": CATEGORIES[record.category], "source": record.source, "order": int(record.get("order", 0)), "related_asset": path if available else "", "asset_available": available}


func _on_discovered(evidence_id: String) -> void:
	evidence_discovered.emit(evidence_id)


func dispose() -> void:
	if _engine.evidence_registered.is_connected(_on_discovered):
		_engine.evidence_registered.disconnect(_on_discovered)
