extends SceneTree

const Narrative = preload("res://scripts/narrative/narrative_engine.gd")
const Evaluator = preload("res://scripts/narrative/condition_evaluator.gd")
const Processor = preload("res://scripts/narrative/effect_processor.gd")
const State = preload("res://scripts/narrative/narrative_session_state.gd")
const Loader = preload("res://scripts/narrative/narrative_loader.gd")
const CASE_PATH: String = "res://data/cases/test_narrative.json"

var failures: Array[String] = []
var checks: int = 0
var notifications: Array[String] = []
var evidence_notifications: Array[String] = []
var event_notifications: Array[Dictionary] = []
var ending_notifications: Array[String] = []
var reentrant_results: Array[bool] = []


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var engine = Narrative.new()
	_connect_signals(engine)
	_check(engine.get_current_node().is_empty(), "fresh engine has no node")
	_check(not engine.start_case(), "cannot start without content")
	_check(not engine.restart_case(), "cannot restart without content")
	_check(not engine.select_choice("missing"), "cannot choose without session")
	_check(not engine.consume_event("missing"), "cannot acknowledge without session")
	_check(engine.load_case(CASE_PATH), "01 valid load")
	_check(notifications == ["loaded"], "load signal before start")
	_check(engine.get_state_snapshot().is_empty(), "load does not start")
	_check(engine.start_case(), "03 start")
	if engine.get_state_snapshot().is_empty():
		_finish()
		return
	var initial: Dictionary = engine.get_state_snapshot()
	_check(engine.get_current_node().id == "test_n01", "initial node")
	_check(typeof(initial.variables.signal) == TYPE_INT, "JSON integers normalized")
	_check(not engine.start_case(), "duplicate start rejected")
	_check(engine.get_state_snapshot() == initial, "duplicate start has no effects")
	_check(engine.get_available_choices().size() == 2, "hidden choice excluded")
	_check(not engine.select_choice("test_hidden"), "10 hidden choice rejected directly")
	_check(not engine.select_choice("test_adjust"), "foreign-node choice rejected")
	_check(engine.get_state_snapshot() == initial, "invalid choices preserve state")
	_test_read_only(engine)
	_check(engine.select_choice("test_skip"), "04 valid choice")
	_check(engine.get_current_node().id == "test_n02", "choice follows destination")
	_check(_choice(engine, "test_continue").enabled == false, "05 conditional choice disabled")
	var before: Dictionary = engine.get_state_snapshot()
	_check(not engine.select_choice("test_continue"), "disabled choice rejected directly")
	_check(before == engine.get_state_snapshot(), "disabled choice leaves state intact")
	_check(evidence_notifications == ["test_e01"], "07 entry evidence signal exactly once")
	var revision: int = engine.get_state_snapshot().revision
	_check(engine.select_choice("test_adjust", revision), "06 effects on selection")
	_check(engine.get_state_snapshot().variables.signal == 1, "integer changed once")
	_check(engine.get_state_snapshot().variables.prepared == true, "boolean flag activated")
	_check(_choice(engine, "test_continue").enabled, "condition enabled after effects")
	before = engine.get_state_snapshot()
	_check(not engine.select_choice("test_adjust", revision), "stale double click rejected")
	_check(before == engine.get_state_snapshot(), "stale request preserves complete snapshot")
	for repetition: int in range(4):
		_check(engine.select_choice("test_adjust"), "legitimate reentry")
	_check(engine.get_state_snapshot().variables.signal == 2, "upper bound saturated")
	_check(engine.get_state_snapshot().evidence == ["test_e01"], "no duplicated evidence on reentry")
	_check(evidence_notifications.size() == 1, "no duplicate evidence signals")
	_check(event_notifications.size() == 1, "once_key prevents duplicate events")
	_check(engine.get_pending_events().size() == 1, "event remains pending without consumer")
	var pending_event: Dictionary = engine.get_pending_events()[0]
	pending_event.payload.purpose = "tampered"
	_check(engine.get_pending_events()[0].payload.purpose == "technical", "pending events are copies")
	_check(engine.consume_event(pending_event.id), "explicit event acknowledgment")
	_check(engine.get_pending_events().is_empty(), "consumed event not pending")
	_check(Evaluator.evaluate({"op": "contains", "target": "consumed_events", "value": "test_ready"}, engine.get_state_snapshot()), "event condition uses declared event kind")
	before = engine.get_state_snapshot()
	_check(not engine.consume_event(pending_event.id), "duplicate acknowledgment rejected")
	_check(before == engine.get_state_snapshot(), "duplicate ack does not change state")
	_test_read_only(engine)
	_check(engine.select_choice("test_continue"), "continue after preparation")
	_check(engine.get_current_node().id == "test_n03", "third intervention reached")
	var notification_start: int = notifications.size()
	_check(engine.select_choice("test_finish"), "08 automatic transition")
	_check(engine.is_case_finished(), "11 session finished")
	_check(engine.get_ending_id() == "test_success", "favorable technical ending")
	_check(engine.get_state_snapshot().visits.test_transition == 1, "automatic node visited once")
	_check(notifications.slice(notification_start) == ["state", "node", "choices", "finished"], "stable signal order on ending")
	_check(ending_notifications == ["test_success"], "completion emitted once")
	_check(engine.get_available_choices().is_empty(), "finished session has no choices")
	before = engine.get_state_snapshot()
	_check(not engine.select_choice("test_finish"), "post-ending choice rejected")
	_check(engine.get_state_snapshot() == before, "post-ending state unchanged")
	_check(engine.restart_case(), "12 restart")
	_check(engine.get_state_snapshot() == initial, "restart restores all state and execution journals")
	_check(engine.select_choice("test_skip") and engine.select_choice("test_leave") and engine.select_choice("test_finish"), "13 alternative route")
	_check(engine.get_ending_id() == "test_partial", "conditional transition fallback")
	_test_failed_loads(engine)
	_test_rollback_and_replacement(engine)
	_check(_run_deterministic_route() == _run_deterministic_route(), "15 identical inputs produce identical snapshots and events")
	_test_effect_policy()
	_test_conditions()
	_test_signal_isolation()
	_test_runtime_edges()
	_finish()


func _test_read_only(engine) -> void:
	var original: Dictionary = engine.get_state_snapshot()
	for repetition: int in range(20):
		engine.get_current_node()
		engine.get_available_choices()
		engine.get_state_snapshot()
		engine.get_pending_events()
		engine.get_diagnostics()
	_check(engine.get_state_snapshot() == original, "16 repeated queries have no effects")
	var snapshot: Dictionary = engine.get_state_snapshot()
	snapshot.variables.signal = 999
	snapshot.evidence.append("fake_evidence")
	var node: Dictionary = engine.get_current_node()
	node.id = "fake_node"
	var choices: Array = engine.get_available_choices()
	if not choices.is_empty():
		choices[0].id = "fake_choice"
	_check(engine.get_state_snapshot() == original, "mutating snapshots cannot mutate internal state")
	_check(engine.get_current_node().id != "fake_node", "node view is isolated")


func _test_failed_loads(engine) -> void:
	_check(engine.restart_case(), "active-session preservation setup")
	_check(engine.select_choice("test_prepare"), "active session has progress and pending events")
	var original: Dictionary = engine.get_state_snapshot()
	for path: String in [
		"res://tests/narrative/fixtures/malformed.json",
		"res://tests/narrative/fixtures/wrong_root.json",
		"res://tests/narrative/fixtures/incompatible_schema.json",
		"res://tests/narrative/fixtures/missing.json",
		"user://forbidden.json",
		"res://data/../data/cases/test_narrative.json",
	]:
		_check(not engine.load_case(path), "02 invalid load controlled: " + path)
		_check(engine.get_state_snapshot() == original, "17 invalid load preserves active session")
		var errors: Array = engine.get_diagnostics().errors
		_check(not errors.is_empty() and errors[0].source == path, "diagnostic includes attempted file")
	_check(engine.restart_case(), "previous valid content survives failed load")
	_check(engine.get_current_node().id == "test_n01", "previous entry still available")


func _test_rollback_and_replacement(engine) -> void:
	_check(engine.load_case("res://tests/narrative/fixtures/automatic_cycle.json"), "load different case")
	_check(engine.get_state_snapshot().is_empty(), "valid replacement clears old session")
	_check(engine.start_case(), "cycle fixture starts at stable dialogue")
	var original: Dictionary = engine.get_state_snapshot()
	var evidence_count: int = evidence_notifications.size()
	var event_count: int = event_notifications.size()
	_check(not engine.select_choice("cycle_start"), "09 automatic loop stopped by runtime limit")
	_check(engine.get_state_snapshot() == original, "failed transition rolls back effects and journals")
	_check(evidence_notifications.size() == evidence_count and event_notifications.size() == event_count, "rolled-back effects emit no external notifications")
	_check(engine.get_diagnostics().errors[0].node_id == "cycle_loop", "runtime error identifies failing node")
	_check(engine.select_choice("cycle_safe"), "valid session remains usable after rollback")
	_check(engine.get_ending_id() == "cycle_end", "safe exit after loop rejection")
	_check(engine.load_case(CASE_PATH) and engine.start_case(), "return to original case")
	_check(not engine.get_state_snapshot().variables.has("count"), "different-case variables do not leak")


func _run_deterministic_route() -> Dictionary:
	var engine = Narrative.new()
	_check(engine.load_case(CASE_PATH) and engine.start_case(), "determinism setup")
	for choice: String in ["test_prepare", "test_continue", "test_finish"]:
		_check(engine.select_choice(choice), "deterministic action " + choice)
	return engine.get_state_snapshot()


func _test_effect_policy() -> void:
	var case_data: Dictionary = Loader.load_file(CASE_PATH).data
	var state = State.new(case_data)
	var pending: Array[Dictionary] = []
	var effects: Array = [
		{"op": "add_clamped", "target": "signal", "value": 1, "once_key": "unit_once"},
		{"op": "mark_once", "value": "unit_marker"},
	]
	_check(Processor.apply(effects, state.data, case_data.variables, "entry_one", pending).is_empty(), "effect processor applies")
	Processor.apply(effects, state.data, case_data.variables, "entry_one", pending)
	Processor.apply(effects, state.data, case_data.variables, "entry_two", pending)
	_check(state.data.variables.signal == 1, "effect token and once_key suppress duplication")
	_check(state.data.applied_once_keys.count("unit_marker") == 1, "mark_once has set semantics")
	Processor.apply([{"op": "add_clamped", "target": "signal", "value": -99}], state.data, case_data.variables, "lower_bound", pending)
	_check(state.data.variables.signal == 0, "lower bound saturated")
	_check(not Evaluator.evaluate({"op": "once_not_applied", "value": "unit_marker"}, state.data), "once condition reads execution journal")


func _test_conditions() -> void:
	var state: Dictionary = {"variables": {"score": 2, "flag": true, "mode": "ready"}, "evidence": ["unit_e01"], "applied_once_keys": [], "executed_actions": [], "events": [], "consumed_events": []}
	var conditions: Array = [
		{"op": "equals", "target": "mode", "value": "ready"},
		{"op": "not_equals", "target": "flag", "value": false},
		{"op": "greater_or_equal", "target": "score", "value": 2},
		{"op": "less_or_equal", "target": "score", "value": 2},
		{"op": "at_least", "target": "score", "value": 1},
		{"op": "at_most", "target": "score", "value": 3},
		{"op": "contains", "target": "evidence", "value": "unit_e01"},
		{"op": "not_contains", "target": "evidence", "value": "unit_e02"},
		{"op": "once_not_applied", "value": "unit_action"},
	]
	for condition: Dictionary in conditions:
		_check(Evaluator.evaluate(condition, state), "condition " + condition.op)
	_check(Evaluator.evaluate({"op": "all", "conditions": conditions}, state), "AND composition")
	_check(Evaluator.evaluate({"op": "any", "conditions": [{"op": "equals", "target": "score", "value": 0}, conditions[0]]}, state), "OR composition")
	_check(Evaluator.evaluate({"op": "not", "condition": {"op": "equals", "target": "flag", "value": false}}, state), "NOT composition")


func _test_signal_isolation() -> void:
	var engine = Narrative.new()
	engine.load_case(CASE_PATH)
	engine.state_changed.connect(func(_snapshot: Dictionary) -> void:
		if reentrant_results.is_empty():
			reentrant_results.append(engine.select_choice("test_skip"))
	)
	engine.event_requested.connect(func(event: Dictionary) -> void: event.payload.purpose = "subscriber_mutation")
	_check(engine.start_case(), "start with signal subscriber")
	_check(reentrant_results == [false], "mutating API blocked during notifications")
	_check(engine.get_current_node().id == "test_n01", "callback cannot skip the initial node")
	_check(engine.select_choice("test_prepare"), "normal choice after callback")
	_check(engine.get_pending_events()[0].payload.purpose == "technical", "subscriber receives detached payload")
	var error_results: Array[bool] = []
	engine.narrative_error.connect(func(_errors: Array) -> void: error_results.append(engine.select_choice("test_continue")))
	var original: Dictionary = engine.get_state_snapshot()
	_check(not engine.select_choice("missing"), "error notification is controlled")
	_check(error_results == [false], "error callback cannot mutate or recursively emit errors")
	_check(engine.get_state_snapshot() == original, "error callback preserves stable state")
	engine.state_changed.disconnect(engine.state_changed.get_connections()[0].callable)
	engine.event_requested.disconnect(engine.event_requested.get_connections()[0].callable)
	engine.narrative_error.disconnect(engine.narrative_error.get_connections()[0].callable)


func _connect_signals(engine) -> void:
	engine.case_loaded.connect(func(_case_id: String) -> void: notifications.append("loaded"))
	engine.node_changed.connect(func(_node: Dictionary) -> void: notifications.append("node"))
	engine.choices_changed.connect(func(_choices: Array) -> void: notifications.append("choices"))
	engine.state_changed.connect(func(_snapshot: Dictionary) -> void: notifications.append("state"))
	engine.evidence_registered.connect(func(evidence_id: String) -> void: evidence_notifications.append(evidence_id))
	engine.event_requested.connect(func(event: Dictionary) -> void: event_notifications.append(event))
	engine.case_finished.connect(func(ending_id: String) -> void:
		ending_notifications.append(ending_id)
		notifications.append("finished")
	)


func _test_runtime_edges() -> void:
	var engine = Narrative.new()
	_check(engine.load_case("res://tests/narrative/fixtures/edge_cases.json") and engine.start_case(), "edge fixture starts")
	_check(engine.get_state_snapshot().variables.count == 1, "entry once effect applied")
	_check(engine.select_choice("edge_once"), "execute action guarded by its stable ID")
	_check(engine.get_state_snapshot().variables.mode == "ready", "string enum assignment at runtime")
	var original: Dictionary = engine.get_state_snapshot()
	_check(not engine.select_choice("edge_once"), "once action is hidden after legitimate reentry")
	_check(engine.select_choice("edge_mark"), "explicit once marker")
	_check(not _choice(engine, "edge_mark").enabled, "marker disables dependent option")
	_check(engine.get_state_snapshot().variables.count == 2, "entry effect not repeated on reentry")
	original = engine.get_state_snapshot()
	_check(not engine.select_choice("edge_dead"), "no eligible dialogue options yields controlled failure")
	_check(engine.get_state_snapshot() == original, "dead-end entry rolls back choice assignment")
	_check(not engine.select_choice("edge_guard"), "false transition without fallback controlled")
	_check(engine.get_state_snapshot() == original, "failed guard leaves stable cursor intact")
	_check(engine.select_choice("edge_finish"), "ending with entry event")
	var ending_id: String = engine.get_ending_id()
	_check(engine.consume_event(engine.get_pending_events()[0].id), "event may be acknowledged after ending")
	_check(engine.get_ending_id() == ending_id and engine.is_case_finished(), "acknowledgment does not reopen ending")
	_check(engine.load_case("res://tests/narrative/fixtures/blocked_start.json"), "structurally valid blocked-start fixture loads")
	_check(not engine.start_case(), "blocked initial transition controlled")
	_check(engine.get_state_snapshot().is_empty(), "failed start commits no partial session")
	_check(engine.get_diagnostics().errors[0].node_id == "blocked_transition", "failed initial node identified")


func _choice(engine, choice_id: String) -> Dictionary:
	for choice: Dictionary in engine.get_available_choices():
		if choice.id == choice_id:
			return choice
	return {}


func _check(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures.append(message)


func _finish() -> void:
	if failures.is_empty():
		print("PASS narrative_engine checks=", checks)
		quit(0)
	else:
		for failure: String in failures:
			push_error("FAIL " + failure)
		quit(1)
