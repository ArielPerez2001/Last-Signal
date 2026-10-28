extends RefCounted

const Conditions = preload("res://scripts/narrative/condition_evaluator.gd")
var _engine: RefCounted


func _init(engine: RefCounted = null) -> void:
	_engine = engine


func preview(evidence_ids: Array) -> Dictionary:
	if _engine == null:
		return result(false, "INVALID", "No hay una investigación activa.")
	return evaluate(_engine.get_investigation_catalog(), _engine.get_state_snapshot(), evidence_ids)


func relate(evidence_ids: Array, expected_revision: int = -1) -> Dictionary:
	if _engine == null:
		return result(false, "INVALID", "No hay una investigación activa.")
	return _engine.confirm_deduction(evidence_ids, expected_revision)


func get_confirmed() -> Array:
	var result: Array = []
	if _engine == null:
		return result
	var state: Dictionary = _engine.get_state_snapshot()
	var catalog: Dictionary = _engine.get_investigation_catalog()
	for id: String in state.get("executed_actions", []):
		for definition: Dictionary in catalog.get("deductions", []):
			if definition.id == id:
				result.append(project(definition))
	return result


static func evaluate(catalog: Dictionary, state: Dictionary, evidence_ids: Array) -> Dictionary:
	if state.is_empty() or catalog.is_empty():
		return result(false, "INVALID", "No hay una investigación activa.")
	var unique: Dictionary = {}
	var declared: Array = []
	for record: Dictionary in catalog.evidence:
		declared.append(record.id)
	for id: Variant in evidence_ids:
		if not id is String or unique.has(id) or id not in declared or id not in state.evidence:
			return result(false, "INVALID", "Seleccione evidencias distintas que ya estén disponibles.")
		unique[id] = true
	if evidence_ids.size() < 2 or evidence_ids.size() > 3:
		return result(false, "INSUFFICIENT", "Seleccione las evidencias que desea relacionar.")
	var selected: Array = evidence_ids.duplicate()
	selected.sort()
	for definition: Dictionary in catalog.deductions:
		var required: Array = definition.required_evidence.duplicate()
		required.sort()
		if selected != required:
			continue
		if definition.id in state.executed_actions:
			return result(true, "ALREADY_DISCOVERED", "Esta conclusión ya está registrada.", project(definition))
		if state.finished or not Conditions.evaluate(definition.get("additional_conditions", {"op": "always"}), state):
			return result(false, "LOCKED", "La información disponible todavía es insuficiente o el expediente está cerrado.")
		return result(true, "VALID", definition.narrative_feedback, project(definition, false))
	return result(false, "INSUFFICIENT", "Estas evidencias todavía no permiten establecer una relación concluyente.")


static func project(definition: Dictionary, confirmed: bool = true) -> Dictionary:
	return {"id": definition.id, "title": definition.title, "description": definition.description, "required_evidence": definition.required_evidence.duplicate(), "narrative_feedback": definition.narrative_feedback, "confirmed": confirmed}


static func result(ok: bool, code: String, message: String, data: Dictionary = {}) -> Dictionary:
	return {"ok": ok, "code": code, "message": message, "data": data.duplicate(true)}
