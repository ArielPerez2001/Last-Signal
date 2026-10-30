extends RefCounted

# Presentation only. Commands and their effects remain in existing services.
const Conditions = preload("res://scripts/narrative/condition_evaluator.gd")
var engine: RefCounted
var saves: RefCounted
var config: Dictionary = {}


func _init(narrative: RefCounted, save_manager: RefCounted) -> void:
	engine = narrative
	saves = save_manager
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string("res://data/cases/case_001/experience.json"))
	if parsed is Dictionary and parsed.get("version") == 1 and parsed.get("case_id") == "c001":
		config = parsed


func goal() -> Dictionary:
	if engine.get_case_id() != config.get("case_id"):
		return {}
	var state: Dictionary = engine.get_state_snapshot()
	if state.is_empty():
		return {}
	for item: Dictionary in config.get("goals", []):
		if Conditions.evaluate(item.when, state):
			return item.duplicate(true)
	return {}


func unlocked(tool: String) -> bool:
	if engine.get_case_id() != config.get("case_id"):
		return false
	var state: Dictionary = engine.get_state_snapshot()
	if state.is_empty():
		return false
	match tool:
		"archive", "record": return "c001_e02" in state.evidence
		"deduction": return "c001_e02" in state.evidence and state.variables.etapa not in ["A", "B"]
		"audio": return "c001_e02" in state.evidence and ("c001_q01" in state.executed_actions or "c001_n13" in state.visits)
		"dispatch": return "c001_q01" in state.executed_actions or "c001_e06" in state.evidence or "c001_n16" in state.visits
		"critical": return state.variables.etapa in ["E", "F"]
	return false


func actions() -> Array:
	if engine.get_case_id() != config.get("case_id"):
		return []
	var node: Dictionary = engine.get_current_node()
	var state: Dictionary = engine.get_state_snapshot()
	var choices: Array = engine.get_available_choices()
	var actions: Array = []
	if node.get("id") == "c001_n10":
		for item: Dictionary in config.get("hub_actions", []):
			if Conditions.evaluate(item.when, state):
				if item.kind == "choice":
					for choice: Dictionary in choices:
						if choice.id == item.choice and choice.enabled:
							actions.append(_choice(choice))
				else:
					actions.append(item.duplicate(true))
		return actions
	for choice: Dictionary in choices:
		if choice.enabled and choice.id not in ["c001_n01_o02", "c001_n24_o01", "c001_n07_o02"]:
			actions.append(_choice(choice))
	return actions


func _choice(choice: Dictionary) -> Dictionary:
	return {"id": choice.id, "kind": "choice", "choice": choice.id, "label": config.get("labels", {}).get(choice.id, choice.text), "revision": choice.revision}


func sequence(choice_id: String) -> Array:
	return config.get("sequences", {}).get(choice_id, [choice_id]).duplicate()


func text() -> String:
	var node: Dictionary = engine.get_current_node()
	return config.get("summaries", {}).get(node.get("id", ""), node.get("text", ""))


func tutorial(mode: String) -> String:
	if mode in saves.get_tutorials_seen():
		return ""
	return config.get("tutorials", {}).get(mode, "")


func current_lesson() -> String:
	var node: String = engine.get_current_node().get("id", "")
	if node == "c001_n01": return "answer"
	if node == "c001_n03": return "dialogue"
	if node in ["c001_n05", "c001_n06", "c001_n07", "c001_n08"]: return "record"
	if node in ["c001_n24", "c001_n25", "c001_n26"]: return "critical"
	return ""
