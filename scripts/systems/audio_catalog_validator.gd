extends RefCounted

const FILTERS: Dictionary = {"original": "Original", "ambiente": "Ambiente", "voces": "Voces"}
const DURATION_TOLERANCE: float = 0.08
var errors: Array[Dictionary] = []
var warnings: Array[Dictionary] = []


func validate(input: Variant, case_id: String, evidence_ids: Array, event_ids: Array) -> Dictionary:
	errors.clear()
	warnings.clear()
	if not input is Dictionary:
		_error("audio_catalog", "El catálogo debe ser un objeto.")
		return _report()
	if not _fields(input, ["recordings", "discovery_rules"]):
		return _report()
	if not input.get("recordings") is Array or not input.get("discovery_rules") is Array:
		_error("audio_catalog", "Se requieren listas de grabaciones y reglas.")
		return _report()
	if input.recordings.size() > 16 or input.discovery_rules.size() > 128:
		_error("audio_catalog", "El catálogo excede los límites de esta versión.")
		return _report()
	var recordings: Dictionary = {}
	for record: Variant in input.recordings:
		if not record is Dictionary:
			_error("audio_recording", "Cada grabación debe ser un objeto.")
			continue
		if not _fields(record, ["recording_id", "title", "description", "case_id", "unlocked_by", "duration", "variants", "segments", "waveform", "capture_information"]):
			continue
		if not _id(record.get("recording_id")) or recordings.has(record.get("recording_id")):
			_error("audio_id", "ID de grabación inválido o duplicado.")
			continue
		recordings[record.recording_id] = record
		for field: String in ["title", "description", "case_id"]:
			if not _text(record.get(field)):
				_error("audio_text", "Texto requerido: " + field)
		if record.get("case_id") != case_id or not record.get("unlocked_by") is Dictionary:
			_error("audio_case", "Caso o condición de desbloqueo inválidos.")
		if not number(record.get("duration")) or record.duration <= 0 or record.duration > 120:
			_error("audio_duration", "Duración requerida entre 0 y 120 segundos.")
			continue
		_validate_variants(record)
		_validate_segments(record)
		if not record.get("capture_information", []) is Array:
			_error("audio_capture", "Se requiere una lista de datos de captura.")
		else:
			for info: Variant in record.get("capture_information", []):
				if not info is Dictionary or not _fields(info, ["condition", "text"]) or not info.get("condition") is Dictionary or not _text(info.get("text")):
					_error("audio_capture", "Dato de captura inválido.")
		var waveform: Variant = record.get("waveform", [])
		if not waveform is Array or waveform.size() > 256:
			_error("audio_waveform", "La onda admite como máximo 256 amplitudes precalculadas.")
		else:
			for value: Variant in waveform:
				if not number(value) or value < 0 or value > 1:
					_error("audio_waveform", "Amplitud fuera de 0–1.")
	if not errors.is_empty():
		return _report()
	var ids: Dictionary = {}
	var combinations: Dictionary = {}
	for rule: Variant in input.discovery_rules:
		if not rule is Dictionary:
			_error("audio_rule", "Cada regla debe ser un objeto.")
			continue
		if not _fields(rule, ["id", "recording_id", "evidence_id", "segment_id", "filter_id", "min_listen_seconds", "additional_conditions", "once_only", "event_id", "discovery_mode"]):
			continue
		if not _id(rule.get("id")) or ids.has(rule.get("id")):
			_error("audio_rule", "ID de regla inválido o duplicado.")
			continue
		ids[rule.id] = true
		if not rule.get("recording_id") is String or not recordings.has(rule.recording_id) or not rule.get("evidence_id") is String or rule.evidence_id not in evidence_ids:
			_error("audio_rule", "Grabación o evidencia de regla inexistente.")
			continue
		var record: Dictionary = recordings[rule.recording_id]
		var segment: Dictionary = find_segment(record, rule.get("segment_id", ""))
		if segment.is_empty() or not rule.get("filter_id") is String or not FILTERS.has(rule.filter_id) or find_variant(record, rule.filter_id).is_empty():
			_error("audio_rule", "Segmento o filtro de regla inexistente.")
			continue
		if rule.has("discovery_mode") and rule.discovery_mode != "consult":
			_error("audio_rule", "Modalidad de descubrimiento desconocida.")
		var minimum: float = 0.0 if rule.get("discovery_mode") == "consult" else 0.5
		if not number(rule.get("min_listen_seconds")) or rule.min_listen_seconds < minimum or rule.min_listen_seconds > segment.end_time - segment.start_time:
			_error("audio_rule", "Tiempo de examen requerido fuera del intervalo.")
		if rule.get("once_only") != true or not rule.get("once_only") is bool or not rule.get("additional_conditions", {}) is Dictionary:
			_error("audio_rule", "Las reglas deben ser únicas y tener condiciones declarativas.")
		if rule.has("event_id") and (not rule.event_id is String or rule.event_id not in event_ids):
			_error("audio_rule", "Evento de observación no declarado.")
		var key: String = rule.recording_id + ":" + rule.segment_id + ":" + rule.filter_id
		if combinations.has(key):
			_error("audio_rule", "Dos reglas no pueden compartir grabación, segmento y filtro.")
		combinations[key] = true
	return _report()


func _validate_variants(record: Dictionary) -> void:
	if not record.get("variants") is Array or record.variants.is_empty() or record.variants.size() > 3:
		_error("audio_variant", "Se requieren entre una y tres variantes.")
		return
	var seen: Dictionary = {}
	for variant: Variant in record.variants:
		if not variant is Dictionary:
			_error("audio_variant", "Cada variante debe ser un objeto.")
			continue
		if not _fields(variant, ["filter_id", "label", "audio_path", "available"]):
			continue
		if not variant.get("filter_id") is String or not FILTERS.has(variant.filter_id) or seen.has(variant.filter_id):
			_error("audio_variant", "Filtro desconocido o duplicado.")
			continue
		seen[variant.filter_id] = true
		var pending_text: bool = variant.get("available") == false and variant.get("audio_path") == ""
		if not _text(variant.get("label")) or not variant.get("available", true) is bool or (not pending_text and not valid_path(variant.get("audio_path"))):
			_error("audio_variant", "Etiqueta, disponibilidad o ruta de audio inválidas.")
			continue
		var stream: AudioStream = resolve_stream(variant.audio_path)
		if stream == null and not pending_text:
			warnings.append(_issue("missing_audio_variant", "Variante ausente; se deshabilita sin sustituirla.", "variants"))
		elif stream != null and (not is_finite(stream.get_length()) or stream.get_length() <= 0 or absf(stream.get_length() - record.duration) > DURATION_TOLERANCE):
			_error("audio_duration", "La variante no coincide con la duración declarada (tolerancia 80 ms).")
	if not seen.has("original"):
		_error("audio_variant", "Debe declararse el filtro Original.")


func _validate_segments(record: Dictionary) -> void:
	if not record.get("variants") is Array:
		return
	if not record.get("segments") is Array or record.segments.size() > 64:
		_error("audio_segment", "segments debe ser una lista de hasta 64 intervalos.")
		return
	var seen: Dictionary = {}
	for segment: Variant in record.segments:
		if not segment is Dictionary:
			_error("audio_segment", "Cada segmento debe ser un objeto.")
			continue
		if not _fields(segment, ["segment_id", "start_time", "end_time", "title", "accessible_information"]):
			continue
		if not _id(segment.get("segment_id")) or seen.has(segment.get("segment_id")):
			_error("audio_segment", "ID de segmento inválido o duplicado.")
			continue
		seen[segment.segment_id] = true
		if not _text(segment.get("title")) or not number(segment.get("start_time")) or not number(segment.get("end_time")):
			_error("audio_segment", "Título o tiempos inválidos.")
		elif segment.start_time < 0 or segment.start_time >= segment.end_time or segment.end_time > record.duration:
			_error("audio_segment", "Intervalo fuera de la grabación.")
		var accessible: Variant = segment.get("accessible_information")
		if not accessible is Dictionary:
			_error("audio_accessibility", "Se requiere información textual por filtro.")
		else:
			for variant: Variant in record.get("variants", []):
				if variant is Dictionary and variant.get("filter_id") is String and not _text(accessible.get(variant.filter_id)):
					_error("audio_accessibility", "Falta texto equivalente de una variante.")
			for key: Variant in accessible:
				if not key is String or not FILTERS.has(key):
					_error("audio_accessibility", "Filtro textual desconocido.")


static func find_segment(record: Dictionary, id: Variant) -> Dictionary:
	if not record.get("segments", []) is Array:
		return {}
	for item: Variant in record.get("segments", []):
		if item is Dictionary and item.get("segment_id") == id:
			return item
	return {}


static func find_variant(record: Dictionary, id: Variant) -> Dictionary:
	if not record.get("variants", []) is Array:
		return {}
	for item: Variant in record.get("variants", []):
		if item is Dictionary and item.get("filter_id") == id:
			return item
	return {}


static func valid_path(path: Variant) -> bool:
	return path is String and path.begins_with("res://") and path == path.simplify_path() and not path.contains("\\") and path.get_extension().to_lower() in ["wav", "ogg", "mp3"]


static func resolve_stream(path: String) -> AudioStream:
	if not valid_path(path) or not ResourceLoader.exists(path, "AudioStream"):
		return null
	return load(path) as AudioStream


static func number(value: Variant) -> bool:
	return typeof(value) in [TYPE_INT, TYPE_FLOAT] and is_finite(float(value))


func _id(value: Variant) -> bool:
	return value is String and RegEx.create_from_string("^[a-z][a-z0-9_]*$").search(value) != null


func _text(value: Variant) -> bool:
	return value is String and not value.strip_edges().is_empty()


func _fields(value: Dictionary, allowed: Array) -> bool:
	var valid: bool = true
	for key: Variant in value:
		if key not in allowed:
			_error("audio_field", "Campo de audio desconocido: " + str(key))
			valid = false
	return valid


func _error(code: String, message: String) -> void:
	errors.append(_issue(code, message, "audio_analysis"))


func _issue(code: String, message: String, property: String) -> Dictionary:
	return {"source": "audio_catalog", "node_id": "", "property": property, "code": code, "message": message}


func _report() -> Dictionary:
	return {"ok": errors.is_empty(), "errors": errors.duplicate(true), "warnings": warnings.duplicate(true)}
