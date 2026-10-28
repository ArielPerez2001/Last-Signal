extends SceneTree

const Validator = preload("res://scripts/narrative/narrative_validator.gd")
const Loader = preload("res://scripts/narrative/narrative_loader.gd")
const CASE_PATH: String = "res://data/cases/test_narrative.json"

var base: Dictionary
var failures: Array[String] = []
var checks: int = 0


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	base = Loader.load_file(CASE_PATH).data
	_check(Validator.new().validate(base, CASE_PATH).ok, "valid case accepted")
	for root_value: Variant in [null, [], "invalid", 7, true]:
		_invalid(root_value, "invalid root")
	var mutations: Array = [
		[["schema_version"], 2], [["schema_version"], "1"], [["schema_version"], true],
		[["case_id"], ""], [["content_version"], 1], [["title"], []], [["initial_node"], "missing_node"],
		[["nodes"], {}], [["nodes"], []], [["nodes", 0], null], [["nodes", 0, "id"], "INVALID"],
		[["nodes", 0, "type"], "audio"], [["nodes", 0, "speaker_id"], "unknown_person"],
		[["nodes", 0, "text"], {}], [["nodes", 0, "options"], []], [["nodes", 0, "options"], "wrong"],
		[["nodes", 0, "options", 0], 4], [["nodes", 0, "options", 0, "id"], 1],
		[["nodes", 0, "options", 0, "next"], "missing_node"], [["nodes", 0, "options", 0, "text"], false],
		[["nodes", 0, "options", 0, "effects"], {}], [["nodes", 0, "options", 0, "effects", 0], "wrong"],
		[["nodes", 0, "options", 0, "effects", 0, "op"], "execute"],
		[["nodes", 0, "options", 0, "effects", 0, "target"], "undeclared"],
		[["nodes", 0, "options", 0, "effects", 0, "value"], "1"],
		[["nodes", 0, "options", 0, "effects", 1, "value"], 1],
		[["nodes", 0, "options", 0, "effects", 2, "event_id"], "unknown_event"],
		[["nodes", 0, "options", 0, "effects", 2, "once_key"], false],
		[["nodes", 0, "options", 0, "effects", 2, "payload"], []],
		[["nodes", 0, "options", 0, "effects", 2, "payload"], {"unsafe": NAN}],
		[["nodes", 0, "options", 0, "effects", 2, "payload"], {"unsafe": Callable()}],
		[["nodes", 1, "entry_effects", 0, "target"], "inventory"],
		[["nodes", 1, "entry_effects", 0, "value"], "unknown_evidence"],
		[["nodes", 1, "options", 1, "enabled_when"], []],
		[["nodes", 1, "options", 1, "enabled_when"], {"op": "eval"}],
		[["nodes", 1, "options", 1, "enabled_when"], {"op": "all", "conditions": []}],
		[["nodes", 1, "options", 1, "enabled_when"], {"op": "not", "condition": null}],
		[["nodes", 1, "options", 1, "enabled_when"], {"op": "equals", "target": "missing", "value": 1}],
		[["nodes", 1, "options", 1, "enabled_when"], {"op": "greater_or_equal", "target": "prepared", "value": true}],
		[["nodes", 1, "options", 1, "enabled_when"], {"op": "equals", "target": "signal", "value": "1"}],
		[["nodes", 1, "options", 1, "enabled_when"], {"op": "contains", "target": "evidence", "value": "unknown_evidence"}],
		[["nodes", 1, "options", 1, "enabled_when"], {"op": "contains", "target": "missing_collection", "value": "test_e01"}],
		[["nodes", 1, "options", 1, "enabled_when"], {"op": "contains", "target": "events", "value": "unknown_event"}],
		[["nodes", 1, "options", 1, "enabled_when"], {"op": "once_not_applied", "value": "unknown_once"}],
		[["nodes", 1, "options", 1, "disabled_reason"], ""],
		[["nodes", 3, "next"], "missing_node"], [["nodes", 3, "fallback_next"], 0],
		[["nodes", 4, "ending_id"], "unknown_ending"], [["endings"], []],
		[["characters"], null], [["characters", 0], []], [["characters", 0, "display_name"], ""],
		[["variables"], []], [["variables", "signal", "min"], 3], [["variables", "signal", "max"], "2"],
		[["variables", "signal", "type"], "Object"], [["initial_state"], []],
		[["initial_state", "variables"], []], [["initial_state", "variables", "signal"], "0"],
		[["initial_state", "variables", "signal"], -1], [["initial_state", "variables", "signal"], 0.5],
		[["initial_state", "variables", "signal"], INF], [["initial_state", "variables", "prepared"], "false"],
		[["initial_state", "evidence"], ["unknown_evidence"]], [["initial_state", "evidence"], "wrong"],
		[["evidence_catalog"], ["test_e01", "test_e01"]], [["event_catalog"], false],
	]
	for mutation: Array in mutations:
		_invalid(_replace(mutation[0], mutation[1]), str(mutation[0]))
	_test_duplicates_and_unknown_fields()
	_test_graph()
	_test_enums_and_numbers()
	_test_known_journals()
	_test_missing_fields_and_reuse()
	_test_field_type_variations()
	_finish()


func _test_duplicates_and_unknown_fields() -> void:
	var changed: Dictionary = base.duplicate(true)
	changed.nodes.append(changed.nodes[0].duplicate(true))
	_invalid(changed, "duplicate node")
	changed = base.duplicate(true)
	changed.nodes[0].options.append(changed.nodes[0].options[0].duplicate(true))
	_invalid(changed, "duplicate option in node")
	changed = base.duplicate(true)
	changed.nodes[1].options[0].id = changed.nodes[0].options[0].id
	_invalid(changed, "duplicate option across case")
	changed = base.duplicate(true)
	changed.characters.append(changed.characters[0].duplicate(true))
	_invalid(changed, "duplicate character")
	changed = base.duplicate(true)
	changed.nodes[0].options[0].effects[0].method = "quit"
	_invalid(changed, "method-shaped property rejected")
	changed = base.duplicate(true)
	changed.nodes[0].options[0].enabled_when = {"op": "always"}
	changed.nodes[0].options[0].disabled_reason = ""
	_check(Validator.new().validate(changed).ok, "approved always condition permits empty disabled reason")
	var condition: Dictionary = {"op": "always"}
	for depth: int in range(40):
		condition = {"op": "not", "condition": condition}
	changed.nodes[0].options[0].visible_when = condition
	_invalid(changed, "nested condition depth is bounded")


func _test_graph() -> void:
	var changed: Dictionary = base.duplicate(true)
	changed.nodes.append({"id": "unreachable_end", "type": "ending", "ending_id": "test_partial"})
	var result: Dictionary = Validator.new().validate(changed, "graph_fixture")
	_check(result.ok and _has_code(result.warnings, "unreachable_node"), "unreachable node produces noncritical warning")
	changed = Loader.load_file("res://tests/narrative/fixtures/automatic_cycle.json").data
	_check(Validator.new().validate(changed).ok, "conditional structural exit accepted without solving states")
	changed.nodes[1].erase("fallback_next")
	result = Validator.new().validate(changed, "closed_cycle_fixture")
	_check(not result.ok and _has_code(result.errors, "automatic_cycle"), "closed automatic loop rejected statically")
	changed = base.duplicate(true)
	changed.nodes[3].erase("next")
	_invalid(changed, "transition without required target")
	changed = base.duplicate(true)
	changed.nodes[0].options = [{"id": "self_loop", "text": "Loop", "next": "test_n01"}]
	_invalid(changed, "reachable dialogue without structural ending rejected")


func _test_enums_and_numbers() -> void:
	var changed: Dictionary = base.duplicate(true)
	changed.variables["mode"] = {"type": "string", "allowed_values": ["idle", "ready"]}
	changed.initial_state.variables["mode"] = "idle"
	changed.nodes[0].options[0].effects.append({"op": "set", "target": "mode", "value": "ready"})
	changed.nodes[0].options[0].visible_when = {"op": "not_equals", "target": "mode", "value": "ready"}
	var enum_report: Dictionary = Validator.new().validate(changed)
	_check(enum_report.ok, "enum variable, assignment and comparison accepted: " + JSON.stringify(enum_report.errors))
	changed.initial_state.variables.mode = "unknown"
	_invalid(changed, "enum value must be declared")
	changed.initial_state.variables.mode = "idle"
	changed.variables.mode.allowed_values = null
	_invalid(changed, "invalid enum declaration handled")
	changed = base.duplicate(true)
	changed.variables["evidence"] = {"type": "bool"}
	changed.initial_state.variables["evidence"] = true
	_invalid(changed, "reserved collection cannot be a variable")
	_check(Validator.is_integer(1.0) and not Validator.is_integer("1") and not Validator.is_integer(true), "integer semantics do not coerce strings or booleans")
	_check(not Validator.is_integer(9007199254740992) and not Validator.is_integer(NAN), "unsafe JSON numbers rejected")


func _test_known_journals() -> void:
	var changed: Dictionary = base.duplicate(true)
	changed.nodes[0].options[0].visible_when = {"op": "once_not_applied", "value": "test_adjust"}
	_check(Validator.new().validate(changed).ok, "option journal reference resolved after collecting all nodes")
	changed.nodes[0].options[0].visible_when = {"op": "contains", "target": "applied_once_keys", "value": "test_notify_once"}
	_check(Validator.new().validate(changed).ok, "effect once key recognized")
	changed.nodes[0].options[0].visible_when = {"op": "contains", "target": "applied_once_keys", "value": "test_adjust"}
	_invalid(changed, "option ID must use its action journal rather than once-key collection")
	changed.nodes[0].options[0].visible_when = {"op": "contains", "target": "executed_actions", "value": "unknown_action"}
	_invalid(changed, "unknown journal action rejected")
	changed = base.duplicate(true)
	changed.nodes[0].options[0].effects.append({"op": "mark_once", "value": "unit_key"})
	changed.nodes[0].options[0].visible_when = {"op": "once_not_applied", "value": "unit_key"}
	_check(Validator.new().validate(changed).ok, "explicit once markers recognized")


func _test_missing_fields_and_reuse() -> void:
	for required: String in ["schema_version", "case_id", "initial_node", "initial_state", "variables", "nodes", "title", "content_version", "characters", "evidence_catalog", "event_catalog", "endings"]:
		var changed: Dictionary = base.duplicate(true)
		changed.erase(required)
		_invalid(changed, "missing " + required)
	var validator = Validator.new()
	_check(validator.validate(base).ok, "validator valid first call")
	_check(not validator.validate([]).ok, "validator invalid second call")
	_check(validator.validate(base).ok, "validator diagnostics do not leak between calls")
	_check(not Loader.load_file("res://tests/narrative/fixtures/malformed.json").ok, "loader reports syntax error")
	_check(Loader.load_file("res://tests/narrative/fixtures/malformed.json").errors[0].message.contains("Línea"), "parse error includes line")


func _replace(path: Array, value: Variant) -> Dictionary:
	var changed: Dictionary = base.duplicate(true)
	var holder: Variant = changed
	for index: int in range(path.size() - 1):
		holder = holder[path[index]]
	holder[path[-1]] = value
	return changed


func _test_field_type_variations() -> void:
	var paths: Array = [
		["variables", "signal"], ["variables", "signal", "type"],
		["nodes", 0, "type"], ["nodes", 0, "speaker_id"],
		["nodes", 1, "options", 1, "enabled_when"],
		["nodes", 1, "options", 1, "enabled_when", "op"],
		["nodes", 0, "options", 0, "effects", 0, "target"],
		["nodes", 1, "entry_effects", 0, "target"],
		["nodes", 0, "options", 0, "effects", 2, "event_id"],
		["nodes", 0, "options", 0, "effects", 2, "payload"],
	]
	for path: Array in paths:
		for value: Variant in [null, false, 0, 1.5, [], {}, ""]:
			var report: Dictionary = Validator.new().validate(_replace(path, value), "type_fixture")
			_check(report.has("ok") and report.errors is Array and report.warnings is Array, "malformed field always returns structured diagnostics")


func _invalid(input: Variant, label: String) -> void:
	var result: Dictionary = Validator.new().validate(input, "validation_fixture")
	_check(not result.ok and not result.errors.is_empty(), "invalid content rejected: " + label)
	for error: Dictionary in result.errors:
		_check(error.source == "validation_fixture" and error.has("node_id") and not error.property.is_empty() and not error.message.is_empty(), "structured diagnostic context")


func _has_code(diagnostics: Array, code: String) -> bool:
	for diagnostic: Dictionary in diagnostics:
		if diagnostic.code == code:
			return true
	return false


func _check(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures.append(message)


func _finish() -> void:
	if failures.is_empty():
		print("PASS narrative_validation checks=", checks)
		quit(0)
	else:
		for failure: String in failures:
			push_error("FAIL " + failure)
		quit(1)
