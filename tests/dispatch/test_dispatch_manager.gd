extends "res://tests/save/save_test_support.gd"

const Dispatch = preload("res://scripts/systems/dispatch_manager.gd")
const Map = preload("res://scripts/systems/map_manager.gd")
const Evidence = preload("res://scripts/systems/evidence_manager.gd")
const PATH: String = "res://data/maps/dispatch_demo.json"


func _run() -> void:
	test_directory = _new_directory("dispatch")
	var engine = _setup()
	var manager = Dispatch.new(engine)
	var evidence = Evidence.new(engine)
	var before: Dictionary = engine.get_state_snapshot()
	for pair: Array in [["missing", "dsp_med"], ["patrol_01", "dsp_port"], ["patrol_01", "dsp_med"], ["ambulance_01", "dsp_alarm"]]:
		_check(not manager.dispatch_unit(pair[0], pair[1]).ok and engine.get_state_snapshot() == before, "09/21 invalid request leaves state intact")
	_check(manager.can_dispatch("patrol_01", "dsp_alarm").ok and engine.get_state_snapshot() == before, "preview pure")
	_check(manager.dispatch_unit("patrol_01", "dsp_alarm", before.revision - 1).code == "STALE" and engine.get_state_snapshot() == before, "stale confirmation rejected atomically")
	var history: Array = engine.get_conversation_history()
	var events: Array[String] = []
	var reentrant: Array[String] = []
	var observer: Callable = func(_snapshot: Dictionary) -> void: reentrant.append(manager.dispatch_unit("ambulance_01", "dsp_med").code)
	engine.state_changed.connect(observer)
	engine.event_requested.connect(func(event: Dictionary) -> void: events.append(event.event_id))
	_check(manager.dispatch_unit("patrol_01", "dsp_alarm").ok, "07 compatible strategic false alarm assignment is valid")
	engine.state_changed.disconnect(observer)
	_check(reentrant == ["BUSY"], "reentrant operational mutation blocked")
	_check(manager.get_unit_status("patrol_01").data.status == "ASSIGNED" and manager.get_incident("dsp_alarm").data.status == "ASSIGNED", "assignment links incident and unit")
	_check(events == ["dsp_sent"] and engine.get_conversation_history() == history and engine.get_state_snapshot().visits == before.visits, "11 event without dialogue reentry")
	before = engine.get_state_snapshot()
	_check(manager.dispatch_unit("patrol_01", "dsp_alarm").code == "ALREADY_PROCESSED" and engine.get_state_snapshot() == before, "10 double assignment idempotent")
	_check(engine.select_choice("dsp_new_port"), "24 assignment unlocks next real call response")
	before = engine.get_state_snapshot()
	_check(manager.dispatch_unit("patrol_01", "dsp_port").code == "UNIT_BUSY" and engine.get_state_snapshot() == before, "08 occupied patrol cannot serve second incident")
	_check(not manager.release_unit("patrol_01", "dsp_port", "dsp_alarm_release").ok and engine.get_state_snapshot() == before, "14 release cannot target another incident")
	_check(not manager.release_unit("patrol_01", "dsp_alarm", "dsp_alarm_arrive").ok, "release requires an authorized release-stage event")
	_check(not manager.process_event("dsp_alarm_resolve", "patrol_01", "dsp_alarm").ok, "cannot skip arrival")
	_check(manager.process_event("dsp_alarm_arrive", "patrol_01", "dsp_alarm").ok and engine.get_state_snapshot().variables.false_alarm, "narrative arrival explains false alarm")
	_check(manager.get_unit_status("patrol_01").data.status == "BUSY", "arrival makes unit busy")
	var saves = Saves.new(engine, test_directory)
	_check(saves.save_current_session().ok, "16 occupied assignment saved")
	var document: Dictionary = _document(saves.get_paths().main)
	_check(document.save_version == 4 and document.session.size() == 17, "version 4 without parallel state fields")
	var fresh = Narrative.new()
	_check(fresh.load_case(PATH), "fresh compatible case")
	var restored: Array[String] = []
	fresh.event_requested.connect(func(_event: Dictionary) -> void: restored.append("event"))
	fresh.evidence_registered.connect(func(_id: String) -> void: restored.append("evidence"))
	var fresh_saves = Saves.new(fresh, test_directory)
	_check(fresh_saves.load_saved_session().ok and fresh.get_state_snapshot() == engine.get_state_snapshot(), "17 restore exact snapshot")
	_check(Dispatch.new(fresh).get_unit_status("patrol_01").data.status == "BUSY" and restored.is_empty(), "18 restore does not release or redispatch")
	before = fresh.get_state_snapshot()
	for defect: String in ["unit", "incident", "assignment", "command", "version"]:
		var bad: Dictionary = document.duplicate(true)
		match defect:
			"unit": bad.session.transaction_log[1].dispatch.unit_id = "missing"
			"incident": bad.session.transaction_log[1].dispatch.incident_id = "missing"
			"assignment": bad.session.variables.patrol_01_assignment = "dsp_med"
			"command": bad.session.transaction_log[1].dispatch.kind = "release_all"
			"version": bad.save_version = 3
		_write(saves.get_paths().main, bad)
		_check(not fresh_saves.load_saved_session().ok and fresh.get_state_snapshot() == before, "23 incompatible persistence rejected: " + defect)
	_check(manager.process_event("dsp_alarm_resolve", "patrol_01", "dsp_alarm").ok and evidence.get_detail("dsp_alarm_report").ok, "12 result grants real evidence")
	_check(manager.get_incident("dsp_alarm").data.status == "CLOSED" and manager.get_unit_status("patrol_01").data.status == "BUSY", "15 closed incident does not implicitly release unit")
	before = engine.get_state_snapshot()
	_check(manager.process_event("dsp_alarm_resolve", "patrol_01", "dsp_alarm").code == "ALREADY_PROCESSED" and engine.get_state_snapshot() == before, "result cannot grant effects twice")
	_check(manager.release_unit("patrol_01", "dsp_alarm", "dsp_alarm_release").ok, "13 authorized release")
	_check(manager.get_unit_status("patrol_01").data.status == "AVAILABLE" and manager.get_unit_status("patrol_01").data.assigned_incident_id.is_empty(), "release clears only matching link")
	_check(manager.dispatch_unit("patrol_01", "dsp_port").ok, "unit reused after narrative release")
	for stage: String in ["arrive", "resolve", "release"]:
		_check(manager.process_event("dsp_port_" + stage, "patrol_01", "dsp_port").ok, "port cycle: " + stage)
	_check(engine.get_state_snapshot().variables.port_done and evidence.get_detail("dsp_port_report").ok, "port outcome updates story and evidence")
	_check(manager.dispatch_unit("ambulance_01", "dsp_med").ok, "ambulance compatible")
	for stage: String in ["arrive", "resolve", "release"]:
		_check(manager.process_event("dsp_med_" + stage, "ambulance_01", "dsp_med").ok, "medical cycle: " + stage)
	_check(_sequence() == _sequence(), "22 deterministic operations")
	var blocked = _setup()
	# Memory fixture: all current dialogue choices require false_alarm == false.
	# Arrival changes it, so the entire operational candidate must roll back.
	for option: Dictionary in blocked._nodes["dsp_hub"].options:
		option["enabled_when"] = {"op": "equals", "target": "false_alarm", "value": false}
	var blocked_manager = Dispatch.new(blocked)
	blocked_manager.dispatch_unit("patrol_01", "dsp_alarm")
	before = blocked.get_state_snapshot()
	_check(not blocked_manager.process_event("dsp_alarm_arrive", "patrol_01", "dsp_alarm").ok, "invalid resulting dialogue rejects operational event")
	_check(blocked.get_state_snapshot() == before, "rollback includes unit/incident states, variables, events and journals")
	_check(engine.restart_case() and manager.get_units(true).size() == 2 and manager.get_incidents().is_empty(), "20 new session clears assignments and known incidents")
	evidence.dispose()
	_finish("dispatch_manager")


func _setup():
	var engine = Narrative.new()
	_check(engine.load_case(PATH) and engine.start_case() and engine.select_choice("dsp_report"), "technical reported session starts")
	return engine


func _sequence() -> Dictionary:
	var engine = _setup()
	var manager = Dispatch.new(engine)
	manager.dispatch_unit("patrol_01", "dsp_alarm")
	for stage: String in ["arrive", "resolve", "release"]:
		manager.process_event("dsp_alarm_" + stage, "patrol_01", "dsp_alarm")
	return engine.get_state_snapshot()
