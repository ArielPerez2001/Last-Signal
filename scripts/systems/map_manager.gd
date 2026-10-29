extends RefCounted

const Rules = preload("res://scripts/systems/dispatch_rules.gd")
const Conditions = preload("res://scripts/narrative/condition_evaluator.gd")
var engine: RefCounted


func _init(narrative: RefCounted) -> void:
	engine = narrative


func get_map() -> Dictionary:
	var catalog: Dictionary = engine.get_dispatch_catalog()
	if catalog.is_empty() or engine.get_state_snapshot().is_empty():
		return {}
	var view: Dictionary = {"map_id": catalog.map_id, "title": catalog.title, "districts": catalog.districts.duplicate(true)}
	if catalog.has("layout_kind"):
		view.layout_kind = catalog.layout_kind
	return view


func get_visible_locations() -> Array:
	var result: Array = []
	for item: Dictionary in engine.get_dispatch_catalog().get("locations", []):
		var view: Dictionary = get_location(item.id)
		if view.ok:
			result.append(view.data)
	return result


func get_location(id: String) -> Dictionary:
	var state: Dictionary = engine.get_state_snapshot()
	var catalog: Dictionary = engine.get_dispatch_catalog()
	var item: Dictionary = Rules.location(catalog, state, id)
	if item.is_empty():
		return Rules.report(false, "UNAVAILABLE", "La ubicación no está disponible.")
	var information: Array = []
	for detail: Dictionary in item.information:
		if Conditions.evaluate(detail.condition, state):
			information.append(detail.text)
	var incidents: Array = []
	var active: bool = false
	for definition: Dictionary in catalog.incidents:
		var incident: Dictionary = Rules.incident(catalog, state, definition.id)
		if definition.location_id == id and not incident.is_empty():
			incidents.append(definition.id)
			active = active or incident.status in ["ACTIVE", "ASSIGNED"]
	return Rules.report(true, "KNOWN", "", {"id": item.id, "name": item.name, "district_id": item.district_id, "district_name": Rules.find(catalog.districts, "id", item.district_id).name, "description": item.description, "position": item.position.duplicate(), "information": information, "incident_ids": incidents, "has_active_incident": active})
