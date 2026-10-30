extends RefCounted

const Conditions = preload("res://scripts/narrative/condition_evaluator.gd")
var _engine: RefCounted
static var _reasoning_catalog: Dictionary = {}


func get_reasoning(id: String) -> Dictionary:
	if _engine == null or _engine.get_case_id() != "c001" or _engine.get_state_snapshot().is_empty():
		return result(false, "UNAVAILABLE", "No hay una pregunta contextual disponible.")
	if _reasoning_catalog.is_empty():
		var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string("res://data/cases/case_001/experience.json"))
		if not parsed is Dictionary:
			return result(false, "INVALID", "No se pudo cargar la pregunta.")
		_reasoning_catalog = parsed
	var state: Dictionary = _engine.get_state_snapshot()
	for definition: Dictionary in _engine.get_investigation_catalog().get("deductions", []):
		if definition.id != id:
			continue
		var sources: Array = []
		for record: Dictionary in _engine.get_investigation_catalog().evidence:
			if record.id in definition.required_evidence and record.id in state.evidence:
				sources.append({"id": record.id, "title": record.title, "description": record.description, "source": record.source})
		var confirmed: bool = id in state.executed_actions
		var ready: bool = sources.size() == definition.required_evidence.size() and Conditions.evaluate(definition.additional_conditions, state) and not _engine.is_investigation_closed()
		for question: Dictionary in _reasoning_catalog.get("reasoning", []):
			if question.id == id:
				var answers: Array = []
				if ready and not confirmed:
					for answer: Dictionary in question.answers:
						answers.append({"id": answer.id, "text": answer.text})
				return result(true, "CONFIRMED" if confirmed else ("READY" if ready else "INCOMPLETE"), definition.narrative_feedback if confirmed else ("" if ready else "Aún falta contrastar fuentes. Puedes seguir hablando, consultar el plano o recibir la inspección, según lo que ya conoces."), {"id": id, "title": definition.title, "question": question.question, "sources": sources, "answers": answers, "revision": state.revision})
	return result(false, "UNAVAILABLE", "Pregunta no disponible.")


func reason(id: String, answer_id: String, revision: int) -> Dictionary:
	var view: Dictionary = get_reasoning(id)
	if not view.ok:
		return view
	if revision != _engine.get_state_snapshot().revision:
		return result(false, "STALE", "La pregunta corresponde a un estado anterior. Revisa las fuentes actuales.")
	if view.code == "CONFIRMED":
		return result(true, "ALREADY_DISCOVERED", view.message)
	if view.code != "READY":
		return result(false, "INSUFFICIENT", view.message)
	for question: Dictionary in _reasoning_catalog.reasoning:
		if question.id != id:
			continue
		for answer: Dictionary in question.answers:
			if answer.id != answer_id:
				continue
			if not answer.get("correct", false):
				return result(false, "UNSUPPORTED", answer.feedback)
			for definition: Dictionary in _engine.get_investigation_catalog().deductions:
				if definition.id == id:
					return relate_hypothesis(id, definition.required_evidence, revision)
	return result(false, "INVALID", "Respuesta no disponible.")


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


func get_hypotheses() -> Array:
	var hypotheses: Array = []
	if _engine == null or _engine.get_state_snapshot().is_empty():
		return hypotheses
	for definition: Dictionary in _engine.get_investigation_catalog().get("deductions", []):
		if Conditions.evaluate(definition.get("additional_conditions", {"op": "always"}), _engine.get_state_snapshot()):
			hypotheses.append({"id": definition.id, "title": definition.title})
	return hypotheses


func relate_hypothesis(id: String, evidence_ids: Array, revision: int = -1) -> Dictionary:
	if _engine == null or _engine.get_state_snapshot().is_empty():
		return result(false, "INVALID", "No hay una investigación activa.")
	if id.is_empty():
		return result(false, "INSUFFICIENT", "Seleccione una hipótesis antes de comprobar pruebas")
	for definition: Dictionary in _engine.get_investigation_catalog().get("deductions", []):
		if definition.id != id:
			continue
		var state: Dictionary = _engine.get_state_snapshot()
		if not Conditions.evaluate(definition.get("additional_conditions", {"op": "always"}), state):
			return result(false, "LOCKED", "Esta hipótesis no admite nuevas comprobaciones ahora.")
		if evidence_ids.is_empty():
			return result(false, "INSUFFICIENT", "Seleccione las evidencias que sostienen esta hipótesis")
		var unique: Array = []
		for evidence_id: Variant in evidence_ids:
			if evidence_id not in state.evidence or evidence_id in unique:
				return result(false, "INVALID", "Todavía no consta en el expediente")
			unique.append(evidence_id)
			if evidence_id not in definition.required_evidence:
				return result(false, "INSUFFICIENT", "Estas pruebas no sostienen juntas la hipótesis elegida. Compare qué afirma cada fuente")
		if unique.size() != definition.required_evidence.size():
			return result(false, "INSUFFICIENT", "La relación es plausible, pero falta contrastarla con otra fuente")
		return relate(evidence_ids, revision)
	return result(false, "INVALID", "Hipótesis no disponible.")


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
