extends "res://tests/save/save_test_support.gd"


func _run() -> void:
	test_directory = _new_directory("validation")
	var engine = _engine()
	_check(engine.select_choice("test_prepare"), "validation state has effects and an event")
	var manager = Saves.new(engine, test_directory)
	_check(manager.save_current_session().ok, "valid document setup")
	var path: String = manager.get_paths().main
	var valid: Dictionary = _document(path)
	var original: Dictionary = engine.get_state_snapshot()
	var notices: Array[String] = []
	engine.session_restored.connect(func(_snapshot: Dictionary) -> void: notices.append("restored"))
	for variant: Variant in [null, true, [], "text", 1]:
		_write(path, variant)
		_assert_rejected(manager, engine, original, "invalid document root")
	_write(path, "{")
	_check(manager.validate_save().data.diagnostics[0].code == "invalid_json", "07 corrupt JSON contextual result")
	_assert_rejected(manager, engine, original, "corrupt JSON")
	for field: String in valid:
		var changed: Dictionary = valid.duplicate(true)
		changed.erase(field)
		_write(path, changed)
		_assert_rejected(manager, engine, original, "missing required field: " + field)
	for field: String in ["save_version", "game_id", "case_id", "content_version", "narrative_schema_version", "content_fingerprint", "saved_at", "session"]:
		for bad: Variant in [null, [], {}, true, 1.5]:
			var changed: Dictionary = valid.duplicate(true)
			changed[field] = bad
			_write(path, changed)
			_assert_rejected(manager, engine, original, "wrong envelope type: " + field)
	for pair: Array in [["save_version", 2], ["save_version", 0], ["game_id", "other_game"], ["case_id", "other_case"], ["content_version", "2.0"], ["content_fingerprint", "changed"], ["narrative_schema_version", 2], ["saved_at", "2026-02-30T24:00:00Z"]]:
		var changed: Dictionary = valid.duplicate(true)
		changed[pair[0]] = pair[1]
		_write(path, changed)
		_assert_rejected(manager, engine, original, "09 incompatible or invalid metadata: " + str(pair[0]))
	for field: String in valid.session:
		var changed: Dictionary = valid.duplicate(true)
		changed.session.erase(field)
		_write(path, changed)
		_assert_rejected(manager, engine, original, "missing snapshot field: " + field)
	for field: String in ["current_node", "variables", "evidence", "events", "consumed_events", "executed_actions", "applied_once_keys", "applied_effects", "visits", "visit_serial", "transaction_log", "revision", "finished", "ending_id"]:
		for bad: Variant in [null, "wrong", true, [], {}]:
			var changed: Dictionary = valid.duplicate(true)
			changed.session[field] = bad
			# Empty arrays are legitimate only when they equal the original field.
			if typeof(bad) == typeof(valid.session[field]) and bad == valid.session[field]:
				continue
			_write(path, changed)
			_assert_rejected(manager, engine, original, "15 wrong snapshot value: " + field)
	var mutations: Array[Dictionary] = []
	for value: Variant in ["1", true, 0.5, -1, 3, 9007199254740992]:
		var changed: Dictionary = valid.duplicate(true)
		changed.session.variables.signal = value
		mutations.append(changed)
	for value: Variant in ["true", 1, null]:
		var changed: Dictionary = valid.duplicate(true)
		changed.session.variables.prepared = value
		mutations.append(changed)
	var bad_node: Dictionary = valid.duplicate(true)
	bad_node.session.current_node = "unknown_node"
	mutations.append(bad_node)
	var automatic_cursor: Dictionary = valid.duplicate(true)
	automatic_cursor.session.current_node = "test_transition"
	mutations.append(automatic_cursor)
	var unknown_evidence: Dictionary = valid.duplicate(true)
	unknown_evidence.session.evidence = ["unknown_evidence"]
	mutations.append(unknown_evidence)
	var duplicate_evidence: Dictionary = valid.duplicate(true)
	duplicate_evidence.session.evidence.append("test_e01")
	mutations.append(duplicate_evidence)
	var missing_effect: Dictionary = valid.duplicate(true)
	missing_effect.session.applied_effects.clear()
	mutations.append(missing_effect)
	var missing_once: Dictionary = valid.duplicate(true)
	missing_once.session.applied_once_keys.clear()
	mutations.append(missing_once)
	var missing_action: Dictionary = valid.duplicate(true)
	missing_action.session.executed_actions.clear()
	mutations.append(missing_action)
	var fake_event: Dictionary = valid.duplicate(true)
	fake_event.session.events[0].payload.purpose = "corrupted"
	mutations.append(fake_event)
	var fake_consumed: Dictionary = valid.duplicate(true)
	fake_consumed.session.consumed_events = ["unknown_instance"]
	mutations.append(fake_consumed)
	var fake_transaction: Dictionary = valid.duplicate(true)
	fake_transaction.session.transaction_log[0].choice_id = "test_continue"
	mutations.append(fake_transaction)
	var fake_revision: Dictionary = valid.duplicate(true)
	fake_revision.session.transaction_log[0].revision = 2
	mutations.append(fake_revision)
	var fake_visit: Dictionary = valid.duplicate(true)
	fake_visit.session.visits.test_n02 = 2
	mutations.append(fake_visit)
	var extra_field: Dictionary = valid.duplicate(true)
	extra_field.session["deductions"] = []
	mutations.append(extra_field)
	for changed: Dictionary in mutations:
		_write(path, changed)
		_assert_rejected(manager, engine, original, "10/15/20 inconsistent state rejected")
	_check(notices.is_empty(), "failed restorations publish no restored notification")
	_write(path, valid)
	_check(manager.load_saved_session().ok, "valid load still succeeds after bad files")
	_check(engine.get_state_snapshot() == original, "valid typed restoration exact")
	_check(notices == ["restored"], "exactly one dedicated restoration notification")
	_test_direct_restore(engine, valid.session)
	_test_interleaved_history()
	_test_enums_and_version()
	_test_limits(engine, manager, path, valid)
	_finish("save_validation")


func _assert_rejected(manager, engine, original: Dictionary, message: String) -> void:
	var bytes: String = FileAccess.get_file_as_string(manager.get_paths().main)
	_check(not manager.load_saved_session().ok, message)
	_check(engine.get_state_snapshot() == original, "20 rejected restoration preserves complete active session")
	_check(FileAccess.get_file_as_string(manager.get_paths().main) == bytes, "invalid original is not deleted or overwritten")


func _test_direct_restore(engine, valid: Dictionary) -> void:
	var original: Dictionary = engine.get_state_snapshot()
	var malformed: Dictionary = valid.duplicate(true)
	malformed.variables.signal = 1.1
	_check(not engine.restore_state_snapshot(malformed), "direct engine import validates state")
	_check(engine.get_state_snapshot() == original, "direct import failure is transactional")
	var event_count: Array[int] = [0]
	engine.event_requested.connect(func(_event: Dictionary) -> void: event_count[0] += 1)
	var reentrant: Array[bool] = []
	engine.session_restored.connect(func(_snapshot: Dictionary) -> void: reentrant.append(engine.select_choice("test_continue")))
	_check(engine.restore_state_snapshot(valid), "direct import valid state")
	_check(reentrant == [false] and event_count[0] == 0, "restore callbacks cannot advance or re-emit events")
	_check(engine.get_pending_events().size() == 1, "pending event survives for explicit future consumer")
	_check(engine.get_state_snapshot() == original, "direct import keeps exact snapshot")
	var reference = RefCounted.new()
	malformed = valid.duplicate(true)
	malformed.variables.signal = reference
	_check(not engine.restore_state_snapshot(malformed), "Godot objects rejected before serialization")
	var circular: Array = []
	circular.append(circular)
	malformed = valid.duplicate(true)
	malformed.events = circular
	_check(not engine.restore_state_snapshot(malformed), "circular data refused without stringify or duplicate")
	circular.clear()
	engine.event_requested.disconnect(engine.event_requested.get_connections()[0].callable)
	engine.session_restored.disconnect(engine.session_restored.get_connections()[-1].callable)


func _test_interleaved_history() -> void:
	var engine = _engine()
	_check(engine.select_choice("test_prepare"), "interleaved choice one")
	_check(engine.consume_event(engine.get_pending_events()[0].id), "ack between choices")
	_check(engine.select_choice("test_adjust") and engine.select_choice("test_continue"), "choices after consumed event")
	var snapshot: Dictionary = engine.get_state_snapshot()
	_check(engine.validate_state_snapshot(snapshot).ok, "history reconstructs acknowledgment revision gaps")
	var manager = Saves.new(engine, _new_directory("interleaved"))
	_check(manager.save_current_session().ok and manager.load_saved_session().ok, "interleaved history round trip")
	_check(engine.get_state_snapshot() == snapshot, "interleaved state exact")
	_check(engine.select_choice("test_finish"), "ending after restore")
	_check(engine.validate_state_snapshot(engine.get_state_snapshot()).ok, "finished history validates")


func _test_enums_and_version() -> void:
	var engine = Narrative.new()
	_check(engine.load_case("res://tests/narrative/fixtures/edge_cases.json") and engine.start_case(), "enum case setup")
	_check(engine.select_choice("edge_once") and engine.select_choice("edge_mark"), "enum and once choices")
	var manager = Saves.new(engine, _new_directory("enum"))
	_check(manager.save_current_session().ok and manager.load_saved_session().ok, "enum and once round trip")
	var before: Dictionary = engine.get_state_snapshot()
	var snapshot: Dictionary = before.duplicate(true)
	snapshot.variables.mode = "unknown"
	_check(not engine.restore_state_snapshot(snapshot), "invalid enum rejected")
	_check(engine.get_state_snapshot() == before, "enum failure preserves state")
	_check(engine.select_choice("edge_finish"), "ending with entry event")
	_check(engine.consume_event(engine.get_pending_events()[0].id), "ack after ending")
	_check(manager.save_current_session().ok and manager.load_saved_session().ok, "post-ending acknowledgment round trip")
	_check(engine.get_pending_events().is_empty() and engine.is_case_finished(), "post-ending event remains consumed")
	_check(engine.load_case(CASE_PATH) and engine.start_case(), "switch to different content")
	before = engine.get_state_snapshot()
	_check(not manager.load_saved_session().ok, "wrong currently loaded case refused")
	_check(engine.get_state_snapshot() == before, "wrong-case failure does not replace active content")
	_check(not manager.save_current_session().ok, "incompatible slot requires explicit replacement")


func _test_limits(engine, manager, path: String, valid: Dictionary) -> void:
	_write(path, " ".repeat(Saves.MAX_FILE_BYTES + 1))
	_check(manager.validate_save().data.diagnostics[0].code == "save_limit", "oversized file rejected before parse")
	_write(path, valid)
	var malformed: Dictionary = valid.session.duplicate(true)
	malformed.revision = 1e100
	_check(not engine.restore_state_snapshot(malformed), "unsafe numeric range refused")
	malformed = valid.session.duplicate(true)
	malformed.variables.signal = NAN
	_check(not engine.restore_state_snapshot(malformed), "nonfinite number refused")
	malformed = valid.session.duplicate(true)
	malformed["extra"] = 1
	_check(not engine.restore_state_snapshot(malformed), "unknown state extension requires new schema")
