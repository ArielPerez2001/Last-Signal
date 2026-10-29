extends "res://tests/save/save_test_support.gd"

const Calls = preload("res://scripts/systems/call_controller.gd")
const Dispatch = preload("res://scripts/systems/dispatch_manager.gd")
const Guidance = preload("res://scripts/ui/case_guidance.gd")


func _hub():
	var calls = Calls.new(_new_directory("ux_context"))
	_check(calls.prepare_call(Calls.OFFICIAL_PATH).ok and calls.answer_call().ok, "official call starts")
	calls.saves.set_autosave_enabled(false)
	for id: String in ["c001_n01_o01", "c001_n03_o01", "c001_n04_o01", "c001_n05_o01", "c001_n06_o01", "c001_n07_o01", "c001_n08_o01"]:
		_check(calls.select_choice(id, calls.engine.get_state_snapshot().revision).ok, "reach hub " + id)
	return calls


func _run() -> void:
	for context: String in ["hub", "audio", "evidence"]:
		var calls = _hub()
		var engine = calls.engine
		var manager = Dispatch.new(engine)
		manager.contextual_reports = true
		var before: Dictionary = engine.get_state_snapshot()
		_check(Guidance.view(engine).section == &"evidence", "orientation names investigation without revealing combination")
		_check(engine.get_state_snapshot() == before, "guidance query pure")
		_check(manager.dispatch_unit("c001_r1", "c001_i02").ok, "one resource assigned")
		if context != "hub":
			_check(engine.select_choice("c001_n10_o03" if context == "audio" else "c001_n10_o07"), "enter another tool")
		before = engine.get_state_snapshot()
		_check(manager.get_available_events().any(func(item: Dictionary) -> bool: return item.id == "c001_u02"), "same report available from " + context)
		_check(engine.get_state_snapshot() == before, "report availability never navigates")
		var command: Dictionary = {"kind":"event","unit_id":"c001_r1","incident_id":"c001_i02","event_id":"c001_u02"}
		_check(not engine.process_contextual_dispatch(command, before.revision - 1).ok and engine.get_state_snapshot() == before, "stale intent rejected before navigation")
		_check(not manager.process_event("c001_u02", "c001_r1", "c001_i01").ok and engine.get_state_snapshot() == before, "wrong incident cannot trigger hidden navigation")
		# Force an unstable report destination in the isolated in-memory fixture.
		var original: Array = engine._nodes.c001_n20.options.duplicate(true)
		for option: Dictionary in engine._nodes.c001_n20.options:
			option.enabled_when = {"op":"equals","target":"resultado","value":"A"}
		_check(not manager.process_event("c001_u02","c001_r1","c001_i02").ok, "unstable report rejected")
		_check(engine.get_state_snapshot() == before, "rollback includes all context visits/actions/evidence")
		engine._nodes.c001_n20.options = original
		var updates: Array = []
		var evidence: Array = []
		engine.state_changed.connect(func(state: Dictionary) -> void: updates.append(state))
		engine.evidence_registered.connect(func(id: String) -> void: evidence.append(id))
		_check(manager.process_event("c001_u02","c001_r1","c001_i02", before.revision).ok, "explicit report completes from " + context)
		_check(updates.size() == 1 and evidence.size() == 3, "single publication, only three newly discovered sources")
		_check(engine.get_current_node().id == "c001_n20" and engine.get_state_snapshot().variables.r1_status == "BUSY", "approved report and resource state")
		_check(engine.validate_state_snapshot(engine.get_state_snapshot()).ok, "normal replay accepts contextual journal")
		var after: Dictionary = engine.get_state_snapshot()
		_check(manager.process_event("c001_u02","c001_r1","c001_i02").code == "ALREADY_PROCESSED" and engine.get_state_snapshot() == after, "report idempotent without context reentry")
		_check(calls.saves.save_current_session().ok, "contextual result saves")
		var restored = Calls.new(calls.saves.get_paths().main.get_base_dir())
		_check(restored.restore_call(Calls.OFFICIAL_PATH).ok and restored.engine.get_state_snapshot() == after, "restores exact contextual journal")
		_check(restored.get_view().history == engine.get_conversation_history(), "history includes report once")
		restored.dispose()
		calls.dispose()
	var critical = _hub()
	var operational = Dispatch.new(critical.engine)
	operational.contextual_reports = true
	_check(operational.dispatch_unit("c001_r1","c001_i01").ok, "prepare front report")
	_check(operational.process_event("c001_u01","c001_r1","c001_i01").ok, "front known")
	_check(critical.engine.select_choice("c001_n19_o01"), "return from front")
	_check(critical.engine.confirm_deduction(["c001_e01","c001_e02"]).ok, "Q01 ready")
	for id: String in ["c001_n10_o09","c001_n21_o01","c001_n22_o01","c001_n23_o01","c001_n24_o02"]:
		_check(critical.engine.select_choice(id), "prepare critical instruction " + id)
	var prepared: Dictionary = critical.engine.get_state_snapshot()
	_check(not operational.process_event("c001_m05","c001_r1","c001_i01").ok, "context navigation cannot cancel a prepared plan")
	_check(critical.engine.get_state_snapshot() == prepared, "plan and emotions preserved")
	_check(critical.engine.select_choice("c001_n25_o02"), "player explicitly corrects plan")
	_check(operational.process_event("c001_m05","c001_r1","c001_i01").ok, "reposition available after explicit correction")
	_check(critical.engine.get_state_snapshot().variables.plan == "ninguno", "context never selects another plan")
	_check(critical.engine.validate_state_snapshot(critical.engine.get_state_snapshot()).ok, "critical correction replay valid")
	critical.dispose()
	_finish("case_guidance")
