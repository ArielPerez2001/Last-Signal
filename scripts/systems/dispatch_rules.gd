extends RefCounted

const Conditions = preload("res://scripts/narrative/condition_evaluator.gd")
const UNIT_STATES: Array = ["AVAILABLE", "ASSIGNED", "BUSY", "UNAVAILABLE"]
const INCIDENT_STATES: Array = ["REPORTED", "ASSIGNED", "RESOLVED", "CLOSED"]
const UNIT_TYPES: Array = ["PATROL", "AMBULANCE", "RESCUE"]


static func is_closed(catalog: Dictionary, state: Dictionary) -> bool:
	return not state.is_empty() and (state.finished or (catalog.has("closed_when") and Conditions.evaluate(catalog.closed_when, state)))


static func find(items: Array, field: String, id: String) -> Dictionary:
	for item: Dictionary in items:
		if item.get(field) == id:
			return item
	return {}


static func location(catalog: Dictionary, state: Dictionary, id: String) -> Dictionary:
	var item: Dictionary = find(catalog.get("locations", []), "id", id)
	return item if not state.is_empty() and not item.is_empty() and Conditions.evaluate(item.visible_when, state) else {}


static func incident(catalog: Dictionary, state: Dictionary, id: String) -> Dictionary:
	var item: Dictionary = find(catalog.get("incidents", []), "id", id)
	if state.is_empty() or item.is_empty() or location(catalog, state, item.location_id).is_empty() or not Conditions.evaluate(item.unlock_conditions, state):
		return {}
	var result: Dictionary = item.duplicate(true)
	result["status"] = state.variables[item.status_variable]
	if result.status == "REPORTED" and Conditions.evaluate(item.activate_conditions, state):
		result.status = "ACTIVE"
	if catalog.has("closed_when") and is_closed(catalog, state):
		result.status = "CLOSED"
	return result


static func unit(catalog: Dictionary, state: Dictionary, id: String) -> Dictionary:
	var item: Dictionary = find(catalog.get("units", []), "unit_id", id)
	if state.is_empty() or item.is_empty():
		return {}
	var result: Dictionary = item.duplicate(true)
	result["status"] = state.variables[item.status_variable]
	result["assigned_incident_id"] = state.variables[item.assignment_variable]
	if catalog.has("closed_when") and is_closed(catalog, state):
		result.status = "CLOSED"
	return result


static func assignment_id(unit_id: String, incident_id: String) -> String:
	return "assign_" + unit_id + "_to_" + incident_id


static func evaluate(catalog: Dictionary, state: Dictionary, command: Dictionary) -> Dictionary:
	if state.is_empty() or catalog.is_empty() or is_closed(catalog, state):
		return report(false, "LOCKED", "No hay una sesión operativa que admita cambios.")
	var kind: Variant = command.get("kind")
	var fields: Array = ["kind", "unit_id", "incident_id"]
	if kind == "event":
		fields.append("event_id")
	if kind not in ["assign", "event"] or command.size() != fields.size():
		return report(false, "INVALID", "Solicitud operativa inválida.")
	for field: String in fields:
		if not command.get(field) is String:
			return report(false, "INVALID", "Referencias operativas inválidas.")
	var target: Dictionary = incident(catalog, state, command.incident_id)
	var resource: Dictionary = unit(catalog, state, command.unit_id)
	if target.is_empty() or resource.is_empty():
		return report(false, "UNAVAILABLE", "El incidente o la unidad no están disponibles.")
	var id: String = assignment_id(command.unit_id, command.incident_id)
	var effects: Array = []
	var message: String = "Asignación confirmada. La unidad deja de estar disponible."
	if kind == "assign":
		if id in state.executed_actions:
			return report(true, "ALREADY_PROCESSED", "Esta asignación ya fue registrada.")
		if target.status != "ACTIVE":
			return report(false, "INACTIVE", "El incidente no admite una asignación nueva.")
		if resource.status != "AVAILABLE" or not resource.assigned_incident_id.is_empty():
			return report(false, "UNIT_BUSY", "La unidad está ocupada o fuera de servicio.")
		if resource.unit_type not in target.required_unit_types:
			return report(false, "INCOMPATIBLE", "El incidente requiere otro tipo de unidad.")
		effects = [_set_effect(resource.status_variable, "ASSIGNED"), _set_effect(resource.assignment_variable, target.id), _set_effect(target.status_variable, "ASSIGNED"), {"op": "emit_event", "event_id": target.dispatch_event}]
	else:
		var rule: Dictionary = find(catalog.get("event_rules", []), "id", command.event_id)
		if rule.is_empty() or rule.unit_id != resource.unit_id or rule.incident_id != target.id:
			return report(false, "INVALID_EVENT", "El parte no corresponde a esta unidad e incidente.")
		id = rule.id
		if id in state.executed_actions:
			return report(true, "ALREADY_PROCESSED", "El parte ya fue procesado; puede consultar sus resultados.")
		if rule.has("from_node") and rule.from_node != state.current_node:
			return report(false, "INVALID_EVENT", "Reciba el parte desde la consulta de despacho de la llamada.")
		if resource.assigned_incident_id != target.id or resource.status != rule.from_unit_status or target.status != rule.from_incident_status or not Conditions.evaluate(rule.condition, state):
			return report(false, "INVALID_EVENT", "Primero complete la fase operativa anterior.")
		effects = [_set_effect(resource.status_variable, rule.to_unit_status), _set_effect(target.status_variable, rule.to_incident_status)]
		if rule.stage == "release":
			effects.append(_set_effect(resource.assignment_variable, ""))
		if rule.stage == "reposition":
			var destination: Dictionary = incident(catalog, state, rule.target_incident_id)
			if destination.is_empty() or destination.status != "ACTIVE" or resource.unit_type not in destination.required_unit_types:
				return report(false, "INVALID_EVENT", "El nuevo destino no admite la reubicación.")
			effects.append(_set_effect(resource.assignment_variable, destination.id))
			effects.append(_set_effect(destination.status_variable, "ASSIGNED"))
			effects.append({"op": "emit_event", "event_id": destination.dispatch_event})
		effects.append_array(rule.effects.duplicate(true))
		message = rule.result_text
	var definition: Dictionary = {"id": id, "effects": effects}
	if kind == "event":
		var rule: Dictionary = find(catalog.event_rules, "id", command.event_id)
		if rule.has("next"):
			definition.next = rule.next
	return report(true, "VALID", message, definition)


static func _set_effect(target: String, value: String) -> Dictionary:
	return {"op": "set", "target": target, "value": value}


static func report(ok: bool, code: String, message: String, data: Dictionary = {}) -> Dictionary:
	return {"ok": ok, "code": code, "message": message, "data": data.duplicate(true)}
