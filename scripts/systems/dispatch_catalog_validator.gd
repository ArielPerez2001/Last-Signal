extends RefCounted

const Rules = preload("res://scripts/systems/dispatch_rules.gd")
var errors: Array[Dictionary] = []
var bindings: Array = []


func validate(input: Variant, case_data: Dictionary) -> Dictionary:
	errors.clear()
	bindings.clear()
	if not _fields(input, ["map_id", "title", "districts", "locations", "units", "incidents", "event_rules"]):
		return _report()
	if not _id(input.map_id) or not _text(input.title):
		_error("map", "Identidad del mapa inválida.")
	var districts: Dictionary = _collection(input.districts, "id", 6)
	var locations: Dictionary = _collection(input.locations, "id", 64)
	var units: Dictionary = _collection(input.units, "unit_id", 16)
	var incidents: Dictionary = _collection(input.incidents, "id", 64)
	var events: Dictionary = _collection(input.event_rules, "id", 256)
	if not errors.is_empty():
		return _report()
	for item: Dictionary in districts.values():
		if _fields(item, ["id", "name", "bounds"]):
			if not _text(item.name) or not _coordinates(item.bounds, 4) or item.bounds[2] <= 0 or item.bounds[3] <= 0 or item.bounds[0] + item.bounds[2] > 1 or item.bounds[1] + item.bounds[3] > 1:
				_error("district", "Nombre o límites del distrito inválidos.")
	for item: Dictionary in locations.values():
		if not _fields(item, ["id", "name", "district_id", "description", "position", "visible_when", "information"]):
			continue
		if not _text(item.name) or not _text(item.description) or not districts.has(item.district_id) or not _coordinates(item.position, 2) or not item.visible_when is Dictionary or not item.information is Array:
			_error("location", "Datos o referencias de ubicación inválidos.")
			continue
		for detail: Variant in item.information:
			if _fields(detail, ["condition", "text"]) and (not detail.condition is Dictionary or not _text(detail.text)):
				_error("location", "Información conocida inválida.")
	for item: Dictionary in incidents.values():
		if not _fields(item, ["id", "title", "description", "location_id", "incident_type", "priority", "initial_status", "status_variable", "required_unit_types", "unlock_conditions", "activate_conditions", "dispatch_event"]):
			continue
		if not _text(item.title) or not _text(item.description) or not _id(item.incident_type) or not locations.has(item.location_id) or item.priority not in ["LOW", "MEDIUM", "HIGH"] or item.initial_status not in ["REPORTED", "CLOSED"] or not item.unlock_conditions is Dictionary or not item.activate_conditions is Dictionary or item.dispatch_event not in case_data.get("event_catalog", []):
			_error("incident", "Datos, estado o referencias de incidente inválidos.")
		if not item.required_unit_types is Array or item.required_unit_types.is_empty():
			_error("incident", "Se requiere una lista de tipos compatibles.")
		else:
			var seen: Array = []
			for type: Variant in item.required_unit_types:
				if type not in Rules.UNIT_TYPES or type in seen:
					_error("incident", "Tipo de unidad desconocido o duplicado.")
				seen.append(type)
		_bind(item.status_variable, Rules.INCIDENT_STATES, item.initial_status, case_data)
	for item: Dictionary in units.values():
		if not _fields(item, ["unit_id", "display_name", "unit_type", "initial_status", "status_variable", "assignment_variable"]):
			continue
		if not _text(item.display_name) or item.unit_type not in Rules.UNIT_TYPES or item.initial_status not in ["AVAILABLE", "UNAVAILABLE"]:
			_error("unit", "Tipo o estado inicial de unidad inválido.")
		_bind(item.status_variable, Rules.UNIT_STATES, item.initial_status, case_data)
		_bind(item.assignment_variable, [""] + incidents.keys(), "", case_data)
	if not errors.is_empty():
		return _report()
	for rule: Dictionary in events.values():
		if not _fields(rule, ["id", "label", "result_text", "stage", "unit_id", "incident_id", "from_unit_status", "to_unit_status", "from_incident_status", "to_incident_status", "condition", "effects"]):
			continue
		if not _text(rule.label) or not _text(rule.result_text) or not units.has(rule.unit_id) or not incidents.has(rule.incident_id) or not rule.condition is Dictionary or not rule.effects is Array:
			_error("dispatch_event", "Evento, condición o referencias inválidos.")
			continue
		if units[rule.unit_id].unit_type not in incidents[rule.incident_id].get("required_unit_types", []):
			_error("dispatch_event", "Unidad incompatible en regla de evento.")
		var legal: bool = false
		match rule.stage:
			"arrive": legal = rule.from_unit_status == "ASSIGNED" and rule.to_unit_status == "BUSY" and rule.from_incident_status == "ASSIGNED" and rule.to_incident_status == "ASSIGNED"
			"resolve": legal = rule.from_unit_status == "BUSY" and rule.to_unit_status == "BUSY" and rule.from_incident_status == "ASSIGNED" and rule.to_incident_status in ["RESOLVED", "CLOSED"]
			"release": legal = rule.from_unit_status == "BUSY" and rule.to_unit_status == "AVAILABLE" and rule.from_incident_status in ["RESOLVED", "CLOSED"] and rule.to_incident_status == rule.from_incident_status
		if not legal:
			_error("dispatch_transition", "Transición de unidad/incidente no autorizada.")
	_no_protected_effects(case_data)
	return _report()


func _bind(name: Variant, allowed: Array, initial: Variant, case_data: Dictionary) -> void:
	if not name is String or name in bindings:
		_error("dispatch_binding", "Variable operativa repetida o inválida.")
		return
	bindings.append(name)
	var declaration: Variant = case_data.get("variables", {}).get(name)
	if not declaration is Dictionary or declaration.get("type") != "string" or not declaration.get("allowed_values") is Array:
		_error("dispatch_binding", "El estado operativo exige una variable enum declarada.")
		return
	for value: Variant in allowed:
		if value not in declaration.allowed_values:
			_error("dispatch_binding", "El enum no cubre los estados o incidentes permitidos.")
	if case_data.get("initial_state", {}).get("variables", {}).get(name) != initial:
		_error("dispatch_binding", "Asignación/estado inicial incoherente.")


func _no_protected_effects(value: Variant, depth: int = 0) -> void:
	if depth > 32:
		_error("dispatch_depth", "Contenido operativo demasiado profundo.")
		return
	if value is Dictionary:
		if value.get("op") in ["set", "add_clamped"] and value.get("target") in bindings:
			_error("dispatch_binding", "Los estados operativos solo cambian mediante transacciones de despacho.")
		for child: Variant in value.values():
			_no_protected_effects(child, depth + 1)
	elif value is Array:
		for child: Variant in value:
			_no_protected_effects(child, depth + 1)


func _collection(value: Variant, field: String, limit: int) -> Dictionary:
	var result: Dictionary = {}
	if not value is Array or value.size() > limit:
		_error("dispatch_catalog", "Colección inválida o demasiado grande.")
		return result
	for item: Variant in value:
		if not item is Dictionary or not _id(item.get(field)) or result.has(item.get(field)):
			_error("dispatch_id", "Identificador ausente, inválido o duplicado.")
		else:
			result[item[field]] = item
	return result


func _coordinates(value: Variant, count: int) -> bool:
	if not value is Array or value.size() != count:
		return false
	for coordinate: Variant in value:
		if typeof(coordinate) not in [TYPE_INT, TYPE_FLOAT] or not is_finite(float(coordinate)) or coordinate < 0 or coordinate > 1:
			return false
	return true


func _id(value: Variant) -> bool:
	return value is String and RegEx.create_from_string("^[a-z][a-z0-9_]*$").search(value) != null


func _text(value: Variant) -> bool:
	return value is String and not value.strip_edges().is_empty()


func _fields(value: Variant, expected: Array) -> bool:
	if not value is Dictionary or value.size() != expected.size():
		_error("dispatch_fields", "Campos operativos ausentes o desconocidos.")
		return false
	for field: String in expected:
		if not value.has(field):
			_error("dispatch_fields", "Campo operativo ausente: " + field)
			return false
	return true


func _error(code: String, message: String) -> void:
	errors.append({"source": "dispatch_catalog", "node_id": "", "property": "operations", "code": code, "message": message})


func _report() -> Dictionary:
	return {"ok": errors.is_empty(), "errors": errors.duplicate(true), "warnings": []}
