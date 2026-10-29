extends RefCounted

# Presentation profile. It never changes state, evaluates endings or selects
# evidence combinations. All actions still go through the existing services.
static func active(engine: RefCounted) -> bool:
	return engine != null and engine.get_case_id() == "c001"


static func view(engine: RefCounted) -> Dictionary:
	var state: Dictionary = engine.get_state_snapshot()
	if not active(engine) or state.is_empty():
		return {}
	var v: Dictionary = state.variables
	if v.resultado != "pendiente":
		return _goal("Atención cerrada", "Lee el desenlace y consulta las fuentes conservadas.", &"calls")
	if v.etapa == "B":
		return _goal("Comprueba el registro del hotel", "Consulta la ficha municipal antes de sacar conclusiones.", &"calls")
	if v.etapa == "A":
		return _goal("Atiende la llamada", "Escucha a la interlocutora y comprueba los datos que proporciona.", &"calls")
	if v.etapa == "D":
		return _goal("Contrasta las fechas", "Retoma la conversación con Clara.", &"calls")
	if v.etapa == "E":
		return _goal("Prepara tu instrucción", "Puedes revisar las pruebas antes de transmitirla.", &"calls")
	if "c001_q01" not in state.executed_actions:
		return _goal("Contrasta el testimonio", "Compara lo que afirma Clara con el registro del hotel.", &"evidence", "Revisar expediente")
	if "c001_e06" not in state.evidence:
		return _goal("Comprueba el estado del hotel", "Solicita una inspección exterior y recibe su parte.", &"map", "Abrir mapa")
	return _goal("Retoma la conversación", "Ya puedes contrastar la fecha con Clara.", &"calls", "Volver a la llamada")


static func _goal(title: String, detail: String, section: StringName, action: String = "") -> Dictionary:
	return {"title": title, "detail": detail, "section": section, "action": action}


static func return_choice(engine: RefCounted) -> Dictionary:
	if not active(engine) or engine.get_current_node().get("panel_id", "").is_empty():
		return {}
	var choices: Array = engine.get_available_choices()
	return choices[0] if choices.size() == 1 and choices[0].enabled else {}


static func primary_choice(engine: RefCounted, choice: Dictionary) -> bool:
	if engine.get_current_node().get("id") != "c001_n10":
		return true
	if choice.id in ["c001_n10_o01", "c001_n10_o02", "c001_n10_o10"]:
		return true
	if choice.id == "c001_n10_o09":
		return choice.enabled
	if choice.id == "c001_n10_o08":
		var v: Dictionary = engine.get_state_snapshot().variables
		return v.confianza < 1 or v.estres > 1
	return false


static func choice_label(engine: RefCounted, choice: Dictionary) -> String:
	if engine.get_current_node().get("panel_id", "") != "" and choice.text == "Volver al expediente":
		return "Retomar la investigación"
	return choice.text
