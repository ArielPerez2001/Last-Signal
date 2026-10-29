extends RefCounted

const MAX_OPERATIONS: int = 2048
const MAX_JSON_ITEMS: int = 250000
const MAX_INTEGER: int = 9007199254740991
const FIELDS: Array[String] = [
	"schema_version", "content_version", "case_id", "current_node", "variables",
	"evidence", "events", "consumed_events", "executed_actions", "applied_once_keys",
	"applied_effects", "visits", "visit_serial", "transaction_log", "revision", "finished", "ending_id",
]


static func failure(code: String, message: String) -> Dictionary:
	return {"ok": false, "code": code, "message": message, "data": {}}


static func json_safe(value: Variant, depth: int = 0, budget: Array = [0]) -> bool:
	# A depth bound also rejects circular containers before duplicate/stringify.
	budget[0] += 1
	if depth > 32 or budget[0] > MAX_JSON_ITEMS:
		return false
	match typeof(value):
		TYPE_NIL, TYPE_BOOL, TYPE_STRING:
			return true
		TYPE_INT, TYPE_FLOAT:
			return is_finite(float(value)) and absf(float(value)) <= MAX_INTEGER
		TYPE_ARRAY:
			for child: Variant in value:
				if not json_safe(child, depth + 1, budget):
					return false
			return true
		TYPE_DICTIONARY:
			for key: Variant in value:
				if typeof(key) != TYPE_STRING or not json_safe(value[key], depth + 1, budget):
					return false
			return true
	return false


static func is_integer(value: Variant, minimum: int = 0, maximum: int = MAX_INTEGER) -> bool:
	return typeof(value) in [TYPE_INT, TYPE_FLOAT] and is_finite(float(value)) and float(value) == floor(float(value)) and value >= minimum and value <= maximum


static func has_fields(value: Dictionary, fields: Array) -> bool:
	if value.size() != fields.size():
		return false
	for field: String in fields:
		if not value.has(field):
			return false
	return true


static func validate(snapshot: Dictionary, case_data: Dictionary) -> Dictionary:
	if case_data.is_empty():
		return failure("case_not_loaded", "Primero debe cargar el contenido narrativo compatible.")
	if not json_safe(snapshot, 0, [0]) or not has_fields(snapshot, FIELDS):
		return failure("invalid_snapshot", "El estado contiene campos ausentes, desconocidos o valores no representables en JSON.")
	for field: String in ["case_id", "content_version", "current_node", "ending_id"]:
		if not snapshot[field] is String:
			return failure("invalid_snapshot", "Se esperaba texto en " + field)
	if not is_integer(snapshot.schema_version, 1, 4) or int(snapshot.schema_version) != int(case_data.schema_version) or snapshot.case_id != case_data.case_id or snapshot.content_version != case_data.content_version:
		return failure("incompatible_content", "El caso, su versión o el esquema narrativo no coinciden.")
	if not snapshot.finished is bool or not snapshot.variables is Dictionary or not snapshot.visits is Dictionary:
		return failure("invalid_snapshot", "Tipos incorrectos en variables, visitas o finalización.")
	if not is_integer(snapshot.revision, 1, MAX_OPERATIONS + 1) or not is_integer(snapshot.visit_serial, 1, (MAX_OPERATIONS + 1) * 65):
		return failure("invalid_snapshot", "Revisión o contador de visitas inválido o fuera del límite admitido.")
	for field: String in ["evidence", "events", "consumed_events", "executed_actions", "applied_once_keys", "applied_effects", "transaction_log"]:
		if not snapshot[field] is Array:
			return failure("invalid_snapshot", "Se esperaba una lista en " + field)
	for field: String in ["evidence", "consumed_events", "executed_actions", "applied_once_keys", "applied_effects"]:
		var seen: Dictionary = {}
		for item: Variant in snapshot[field]:
			if not item is String or seen.has(item):
				return failure("invalid_snapshot", "ID inválido o duplicado en " + field)
			seen[item] = true
	if snapshot.transaction_log.size() + snapshot.consumed_events.size() > MAX_OPERATIONS:
		return failure("save_limit", "La sesión supera el límite de operaciones del formato 1.")
	var normalized: Dictionary = snapshot.duplicate(true)
	for field: String in ["schema_version", "revision", "visit_serial"]:
		normalized[field] = int(normalized[field])
	if not has_fields(normalized.variables, case_data.variables.keys()):
		return failure("invalid_variables", "Las variables no coinciden con las declaradas en el caso.")
	for key: String in case_data.variables:
		var definition: Dictionary = case_data.variables[key]
		var value: Variant = normalized.variables[key]
		match definition.type:
			"int":
				if not is_integer(value, int(definition.min), int(definition.max)):
					return failure("invalid_variables", "Entero o rango inválido: " + key)
				normalized.variables[key] = int(value)
			"bool":
				if not value is bool:
					return failure("invalid_variables", "Indicador booleano inválido: " + key)
			"string":
				if not value is String or (definition.has("allowed_values") and value not in definition.allowed_values):
					return failure("invalid_variables", "Texto o enumeración inválida: " + key)
	for key: String in normalized.visits:
		if not is_integer(normalized.visits[key], 1):
			return failure("invalid_snapshot", "Contador de visita inválido: " + key)
		normalized.visits[key] = int(normalized.visits[key])
	for entry: Variant in normalized.transaction_log:
		if not entry is Dictionary:
			return failure("invalid_history", "Transacción incompleta o desconocida.")
		var fields: Array = ["node_id", "choice_id", "revision"]
		if int(case_data.schema_version) >= 3 and entry.has("analysis"):
			fields.append("analysis")
			if not entry.analysis is Dictionary:
				return failure("invalid_history", "Comprobante de análisis inválido.")
			if not has_fields(entry.analysis, ["recording_id", "segment_id", "filter_id", "listened_ms"]) or not is_integer(entry.analysis.get("listened_ms"), 0, 120000):
				return failure("invalid_history", "Campos o tiempo de examen inválidos.")
			for field: String in ["recording_id", "segment_id", "filter_id"]:
				if not entry.analysis[field] is String:
					return failure("invalid_history", "Referencia de análisis inválida.")
			entry.analysis.listened_ms = int(entry.analysis.listened_ms)
		if int(case_data.schema_version) == 4 and entry.has("dispatch"):
			fields.append("dispatch")
			if not entry.dispatch is Dictionary:
				return failure("invalid_history", "Solicitud operativa inválida.")
		if not has_fields(entry, fields):
			return failure("invalid_history", "Transacción incompleta o desconocida.")
		if not entry.node_id is String or not entry.choice_id is String or not is_integer(entry.revision, 1, MAX_OPERATIONS):
			return failure("invalid_history", "Tipos incorrectos en el registro de transacciones.")
		entry.revision = int(entry.revision)
	for event: Variant in normalized.events:
		if not event is Dictionary or not has_fields(event, ["id", "event_id", "payload"]) or not event.id is String or not event.event_id is String or not event.payload is Dictionary:
			return failure("invalid_events", "Instancia de evento inválida.")
	return {"ok": true, "code": "valid_snapshot", "message": "Estructura de estado válida.", "data": normalized}
