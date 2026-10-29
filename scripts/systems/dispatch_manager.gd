extends RefCounted

const Rules = preload("res://scripts/systems/dispatch_rules.gd")
const Evidence = preload("res://scripts/systems/evidence_manager.gd")
var engine: RefCounted


func _init(narrative: RefCounted) -> void:
	engine = narrative


func get_incident(id: String) -> Dictionary:
	var item: Dictionary = Rules.incident(engine.get_dispatch_catalog(), engine.get_state_snapshot(), id)
	if item.is_empty():
		return Rules.report(false, "UNAVAILABLE", "El incidente no está disponible.")
	return Rules.report(true, "KNOWN", "", {"id": item.id, "title": item.title, "description": item.description, "location_id": item.location_id, "incident_type": item.incident_type, "priority": item.priority, "status": item.status, "required_unit_types": item.required_unit_types.duplicate()})


func get_incidents(active_only: bool = false) -> Array:
	var result: Array = []
	for definition: Dictionary in engine.get_dispatch_catalog().get("incidents", []):
		var item: Dictionary = get_incident(definition.id)
		if item.ok and (not active_only or item.data.status == "ACTIVE"):
			result.append(item.data)
	return result


func get_unit_status(id: String) -> Dictionary:
	var item: Dictionary = Rules.unit(engine.get_dispatch_catalog(), engine.get_state_snapshot(), id)
	if item.is_empty():
		return Rules.report(false, "UNAVAILABLE", "La unidad no está disponible.")
	return Rules.report(true, "KNOWN", "", {"unit_id": item.unit_id, "unit_type": item.unit_type, "display_name": item.display_name, "status": item.status, "assigned_incident_id": item.assigned_incident_id})


func get_units(available_only: bool = false) -> Array:
	var result: Array = []
	for definition: Dictionary in engine.get_dispatch_catalog().get("units", []):
		var item: Dictionary = get_unit_status(definition.unit_id)
		if item.ok and (not available_only or item.data.status == "AVAILABLE"):
			result.append(item.data)
	return result


func can_dispatch(unit_id: String, incident_id: String) -> Dictionary:
	var result: Dictionary = Rules.evaluate(engine.get_dispatch_catalog(), engine.get_state_snapshot(), {"kind": "assign", "unit_id": unit_id, "incident_id": incident_id})
	result.data = {} # Internal generated effects are never player projection.
	return result


func dispatch_unit(unit_id: String, incident_id: String, revision: int = -1) -> Dictionary:
	return engine.process_dispatch({"kind": "assign", "unit_id": unit_id, "incident_id": incident_id}, revision)


func process_event(event_id: String, unit_id: String, incident_id: String, revision: int = -1) -> Dictionary:
	return Evidence.process_dispatch_event(engine, {"kind": "event", "unit_id": unit_id, "incident_id": incident_id, "event_id": event_id}, revision)


func release_unit(unit_id: String, incident_id: String, event_id: String) -> Dictionary:
	var rule: Dictionary = Rules.find(engine.get_dispatch_catalog().get("event_rules", []), "id", event_id)
	if rule.get("stage") != "release":
		return Rules.report(false, "INVALID_EVENT", "La liberación requiere un parte autorizado.")
	return process_event(event_id, unit_id, incident_id)


func get_available_events() -> Array:
	var result: Array = []
	var catalog: Dictionary = engine.get_dispatch_catalog()
	var state: Dictionary = engine.get_state_snapshot()
	for rule: Dictionary in catalog.get("event_rules", []):
		var command: Dictionary = {"kind": "event", "unit_id": rule.unit_id, "incident_id": rule.incident_id, "event_id": rule.id}
		var checked: Dictionary = Rules.evaluate(catalog, state, command)
		if checked.ok and checked.code == "VALID":
			result.append({"id": rule.id, "label": rule.label, "unit_id": rule.unit_id, "incident_id": rule.incident_id, "revision": state.revision})
	return result


func get_dispatch_state_snapshot() -> Dictionary:
	return {"incidents": get_incidents(), "units": get_units(), "processed": engine.get_state_snapshot().get("executed_actions", []).duplicate()}
