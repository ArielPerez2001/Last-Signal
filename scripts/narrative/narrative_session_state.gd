extends RefCounted

var data: Dictionary = {}


func _init(case_data: Dictionary = {}) -> void:
	if case_data.is_empty():
		return
	var values: Dictionary = case_data.initial_state.variables.duplicate(true)
	for variable_name: String in case_data.variables:
		if case_data.variables[variable_name].type == "int":
			values[variable_name] = int(values[variable_name])
	data = {
		"schema_version": int(case_data.schema_version),
		"content_version": case_data.content_version,
		"case_id": case_data.case_id,
		"current_node": "",
		"variables": values,
		"evidence": case_data.initial_state.evidence.duplicate(),
		"events": [],
		"consumed_events": [],
		"executed_actions": [],
		"applied_once_keys": [],
		"applied_effects": [],
		"visits": {},
		"visit_serial": 0,
		"transaction_log": [],
		"revision": 0,
		"finished": false,
		"ending_id": "",
	}


func snapshot() -> Dictionary:
	return data.duplicate(true)


func copy():
	var copied_state = get_script().new()
	copied_state.data = snapshot()
	return copied_state
