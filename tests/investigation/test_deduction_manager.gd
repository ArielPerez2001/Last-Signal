extends "res://tests/save/save_test_support.gd"

const Deductions = preload("res://scripts/systems/deduction_manager.gd")
const Evidence = preload("res://scripts/systems/evidence_manager.gd")
const Validator = preload("res://scripts/narrative/narrative_validator.gd")
const Loader = preload("res://scripts/narrative/narrative_loader.gd")
const INVESTIGATION_PATH: String = "res://data/cases/investigation_demo.json"


func _run() -> void:
	test_directory = _new_directory("deductions")
	var engine = _setup()
	var deductions = Deductions.new(engine)
	var evidence = Evidence.new(engine)
	var before: Dictionary = engine.get_state_snapshot()
	for selection: Array in [["inv_e01", "inv_e01"], ["inv_e01", "missing"], ["inv_e01", "inv_e04"], ["inv_e01", 1]]:
		_check(deductions.relate(selection).code == "INVALID", "08/24 invalid or undiscovered selection rejected")
		_check(engine.get_state_snapshot() == before, "rejection preserves session")
	_check(deductions.relate(["inv_e01"]).code == "INSUFFICIENT", "one clue insufficient without guessing solution")
	_check(deductions.relate(["inv_e01", "inv_e03"]).code == "INSUFFICIENT", "11 wrong combination harmless")
	_check(engine.get_state_snapshot() == before, "experimentation has no penalty")
	var transcript: Array = engine.get_conversation_history()
	var notices: Array[String] = []
	var events: Array[String] = []
	engine.deduction_confirmed.connect(func(id: String) -> void: notices.append(id))
	engine.event_requested.connect(func(event: Dictionary) -> void: events.append(event.event_id))
	_check(deductions.preview(["inv_e01", "inv_e02"]).code == "VALID", "07 valid selection preview")
	_check(engine.get_state_snapshot() == before and deductions.get_confirmed().is_empty(), "preview does not confirm or grant effects")
	var result: Dictionary = deductions.relate(["inv_e02", "inv_e01"], before.revision)
	_check(result.code == "VALID" and result.data.confirmed, "09/10 unordered relation confirmed")
	_check(engine.get_state_snapshot().variables.notes == 1, "controlled EffectProcessor effect applied")
	_check(engine.get_state_snapshot().current_node == before.current_node and engine.get_state_snapshot().visits == before.visits, "deduction does not reenter node")
	_check(engine.get_conversation_history() == transcript, "no invented spoken response for external action")
	_check(engine.get_available_choices().any(func(choice: Dictionary) -> bool: return choice.id == "inv_unlocked"), "14 deduction unlocks real narrative choice")
	before = engine.get_state_snapshot()
	_check(deductions.relate(["inv_e01", "inv_e02"]).code == "ALREADY_DISCOVERED", "12 repeated relation returns known conclusion")
	_check(engine.get_state_snapshot() == before and notices == ["inv_d01"] and events == ["inv_connection"], "no duplicate effect, event or confirmation")
	_check(evidence.discover_from_action("inv_read_transcript").ok and evidence.discover_from_action("inv_read_comparison").ok, "optional evidence setup")
	before = engine.get_state_snapshot()
	result = deductions.relate(["inv_e04", "inv_e05"])
	_check(result.code == "LOCKED" and result.data.is_empty(), "13 locked relation does not reveal hidden rule details")
	_check(engine.get_state_snapshot() == before, "locked relation has no consequences")
	_check(engine.select_choice("inv_review"), "condition satisfied by valid narrative action")
	_check(deductions.relate(["inv_e05", "inv_e04"]).code == "VALID", "optional conclusion confirmed")
	_check(deductions.get_confirmed().size() == 2 and engine.get_state_snapshot().variables.notes == 2, "two conclusions with single effects")
	var manager = Saves.new(engine, test_directory)
	before = engine.get_state_snapshot()
	_check(manager.save_current_session().ok, "16 investigation saved")
	var document: Dictionary = _document(manager.get_paths().main)
	_check(document.save_version == 2 and document.narrative_schema_version == 2, "explicit format and narrative versions 2")
	_check(document.session.size() == 17, "no second persistent evidence/deduction collection")
	var fresh = Narrative.new()
	_check(fresh.load_case(INVESTIGATION_PATH), "new instance loads case")
	var fresh_manager = Saves.new(fresh, test_directory)
	var restored_notices: Array[String] = []
	fresh.deduction_confirmed.connect(func(id: String) -> void: restored_notices.append(id))
	fresh.event_requested.connect(func(_event: Dictionary) -> void: restored_notices.append("event"))
	fresh.evidence_registered.connect(func(_id: String) -> void: restored_notices.append("evidence"))
	_check(fresh_manager.load_saved_session().ok, "17 new instance restores disk state")
	_check(fresh.get_state_snapshot() == before and restored_notices.is_empty(), "23 exact recovery without discovery or reward signals")
	_check(Deductions.new(fresh).get_confirmed() == deductions.get_confirmed(), "confirmed conclusions reconstructed from IDs")
	var bad: Dictionary = document.duplicate(true)
	bad.session.executed_actions.append("unknown_deduction")
	_write(manager.get_paths().main, bad)
	_check(not fresh_manager.load_saved_session().ok and fresh.get_state_snapshot() == before, "18 incompatible deduction reference rejected safely")
	bad = document.duplicate(true)
	bad.session.evidence.append("unknown_evidence")
	_write(manager.get_paths().main, bad)
	_check(not fresh_manager.load_saved_session().ok and fresh.get_state_snapshot() == before, "unknown evidence rejected safely")
	bad = document.duplicate(true)
	bad.save_version = 1
	_write(manager.get_paths().main, bad)
	_check(not fresh_manager.load_saved_session().ok and fresh.get_state_snapshot() == before, "format 1 cannot silently restore schema 2 investigation")
	_check(engine.select_choice("inv_unlocked") and engine.select_choice("inv_finish"), "complete favorable route")
	_check(deductions.relate(["inv_e01", "inv_e02"]).code == "ALREADY_DISCOVERED", "closed dossier allows existing conclusion consult")
	_check(not evidence.discover_from_action("inv_read_comparison").ok, "no acquisitions after ending")
	_check(engine.restart_case(), "19 explicit new session")
	_check(deductions.get_confirmed().is_empty() and evidence.get_discovered().is_empty(), "new session has no previous investigation")
	_check(_deterministic_state() == _deterministic_state(), "22 same actions produce same complete snapshot")
	_test_endings_and_revisions()
	_test_invalid_rules()
	var blocked = Narrative.new()
	_check(blocked.load_case("res://tests/investigation/fixtures/blocked_effect.json") and blocked.start_case(), "conditional stable fixture starts")
	before = blocked.get_state_snapshot()
	_check(not blocked.confirm_deduction(["clue_a", "clue_b"]).ok, "invalid resulting stable state rejected")
	_check(blocked.get_state_snapshot() == before and blocked.get_pending_events().is_empty(), "deduction rolls back variables, events, journals and confirmation")
	_check(Deductions.new().relate([]).code == "INVALID", "unconfigured manager controlled")
	evidence.dispose()
	_finish("deduction_manager")


func _setup():
	var engine = Narrative.new()
	_check(engine.load_case(INVESTIGATION_PATH) and engine.start_case(), "investigation starts")
	_check(engine.select_choice("inv_testimony") and engine.select_choice("inv_document") and engine.select_choice("inv_log"), "three decisions grant evidence")
	return engine


func _deterministic_state() -> Dictionary:
	var engine = _setup()
	_check(Deductions.new(engine).relate(["inv_e01", "inv_e02"]).ok, "deterministic deduction")
	return engine.get_state_snapshot()


func _test_endings_and_revisions() -> void:
	var engine = _setup()
	var before: Dictionary = engine.get_state_snapshot()
	_check(engine.confirm_deduction(["inv_e01", "inv_e02"], before.revision - 1).code == "STALE" and engine.get_state_snapshot() == before, "stale external revision leaves session intact")
	var reentrant: Array[String] = []
	var observer: Callable = func(_snapshot: Dictionary) -> void: reentrant.append(engine.confirm_deduction(["inv_e04", "inv_e05"]).code)
	engine.state_changed.connect(observer)
	_check(engine.confirm_deduction(["inv_e01", "inv_e02"], before.revision).ok, "external confirmation succeeds with current revision")
	engine.state_changed.disconnect(observer)
	_check(reentrant == ["BUSY"], "external mutation during notification is rejected")
	_check(engine.select_choice("inv_unlocked") and engine.select_choice("inv_finish") and engine.get_ending_id() == "inv_complete" and Deductions.new(engine).get_confirmed().size() == 1, "favorable ending does not require optional deduction")
	var partial = Narrative.new()
	_check(partial.load_case(INVESTIGATION_PATH) and partial.start_case() and partial.select_choice("inv_testimony") and partial.select_choice("inv_close"), "alternate route closes without complete evidence")
	_check(partial.get_ending_id() == "inv_partial" and partial.get_state_snapshot().evidence == ["inv_e01"] and Deductions.new(partial).get_confirmed().is_empty(), "partial ending preserves discovered evidence without inventing conclusions")


func _test_invalid_rules() -> void:
	var valid: Dictionary = Loader.load_file(INVESTIGATION_PATH).data
	var validator = Validator.new()
	for field: String in ["id", "title", "description", "required_evidence", "effects", "result_type", "narrative_feedback"]:
		var changed: Dictionary = valid.duplicate(true)
		changed.investigation.deductions[0].erase(field)
		_check(not validator.validate(changed).ok, "missing required rule field: " + field)
	for required: Variant in [["inv_e01", "inv_e01"], ["inv_e01", "missing"], [], ["inv_e01"], "wrong"]:
		var changed: Dictionary = valid.duplicate(true)
		changed.investigation.deductions[0].required_evidence = required
		_check(not validator.validate(changed).ok, "malformed rule combination rejected")
	var changed: Dictionary = valid.duplicate(true)
	changed.investigation.deductions[0].repeatable = true
	_check(not validator.validate(changed).ok, "unapproved repeated conclusions rejected")
	changed = valid.duplicate(true)
	changed.investigation.deductions[0].effects = [{"op": "execute_code", "value": "unsafe"}]
	_check(not validator.validate(changed).ok, "arbitrary effect execution rejected")
	changed = valid.duplicate(true)
	changed.investigation.actions[0].id = "inv_document"
	_check(not validator.validate(changed).ok, "actions cannot collide with dialogue option IDs")
	changed = valid.duplicate(true)
	changed.investigation.deductions[1].required_evidence = ["inv_e02", "inv_e01"]
	_check(not validator.validate(changed).ok, "ambiguous combinations rejected")
	changed = valid.duplicate(true)
	changed.investigation.deductions[0].required_evidence = ["inv_e01", "inv_e02", "inv_e03"]
	_check(validator.validate(changed).ok, "data contract allows future three-evidence rules")
