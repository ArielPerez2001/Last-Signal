extends "res://tests/save/save_test_support.gd"

const Calls = preload("res://scripts/systems/call_controller.gd")
const FailingSaves = preload("res://tests/save/failing_save_manager.gd")


func _run() -> void:
	test_directory = _new_directory("calls")
	var calls = Calls.new(test_directory)
	_check(calls.get_view().state == "IDLE", "01 initial IDLE")
	_check(not calls.answer_call().ok and not calls.select_choice("demo_confirm", 1).ok, "cannot answer or choose without incoming call")
	_check(calls.engine.get_state_snapshot().is_empty(), "invalid controls do not start engine")
	_check(calls.prepare_call().ok, "02 incoming call prepared")
	_check(calls.get_view().state == "INCOMING" and calls.get_view().caller == "Número desconocido", "incoming state and unknown caller")
	_check(calls.get_view().history.is_empty() and not calls.saves.has_save().data.exists, "preparation does not present dialogue or save")
	_check(not calls.prepare_call().ok, "second incoming call rejected")
	_check(not calls.select_choice("demo_confirm", 1).ok, "no choices before answering")
	_check(calls.answer_call().ok, "03 answer connects")
	_check(calls.get_view().state == "CONNECTED" and calls.get_view().history.size() == 1, "first node presented once")
	var original: Dictionary = calls.engine.get_state_snapshot()
	_check(not calls.answer_call().ok, "duplicate answer rejected")
	_check(calls.engine.get_state_snapshot() == original, "duplicate answer cannot reapply entry effects")
	_check(calls.get_view().choices.size() == 2, "hidden option absent")
	_check(not calls.select_choice("demo_hidden", original.revision).ok, "hidden choice rejected directly")
	_check(calls.get_view().history.size() == 1, "05 rejected choice not recorded")
	_check(_select(calls, "demo_wait"), "04 valid alternative")
	_check(not _choice(calls, "demo_ready").enabled, "07 condition shown disabled")
	original = calls.engine.get_state_snapshot()
	var history: Array = calls.get_view().history
	_check(not calls.select_choice("demo_ready", original.revision).ok, "disabled choice rejected")
	_check(calls.engine.get_state_snapshot() == original and calls.get_view().history == history, "rejection preserves all state and transcript")
	_check(_select(calls, "demo_adjust"), "condition becomes true through valid route")
	_check(_choice(calls, "demo_ready").enabled, "condition reflected from engine")
	var after_adjust: Dictionary = calls.engine.get_state_snapshot()
	_check(not calls.select_choice("demo_adjust", original.revision).ok, "06 same old revision rejected after self-loop")
	_check(calls.engine.get_state_snapshot() == after_adjust, "double tap cannot increment signal twice")
	_check(calls.get_view().history.size() == 5, "08 ordered node-choice-node transcript")
	_check(calls.get_view().history[1].choice_id == "demo_wait" and calls.get_view().history[3].choice_id == "demo_adjust", "only confirmed choices appear")
	var event_count: Array[int] = [0]
	calls.engine.event_requested.connect(func(_event: Dictionary) -> void: event_count[0] += 1)
	var endings: Array[String] = []
	calls.communication_ended.connect(func(id: String) -> void: endings.append(id))
	_check(_select(calls, "demo_ready"), "confirmed communication advances")
	var before_ack: Array = calls.engine.get_conversation_history()
	_check(calls.engine.consume_event(calls.engine.get_pending_events()[0].id), "interleaved event acknowledgment")
	_check(calls.engine.get_conversation_history() == before_ack, "acknowledgment does not invent a spoken line")
	_check(_select(calls, "demo_finish"), "three meaningful choices reach ending through automatic transition")
	_check(calls.get_view().state == "ENDED" and calls.get_view().ending_id == "demo_complete", "10 ended state")
	_check(calls.get_view().choices.is_empty() and not _select(calls, "demo_finish"), "ended call rejects options")
	_check(endings == ["demo_complete"] and event_count[0] == 1, "ending/event delivered once")
	_check(calls.get_view().history.size() == 9, "automatic transition does not invent a dialogue line")
	original = calls.engine.get_state_snapshot()
	history = calls.get_view().history
	for repetition: int in range(5):
		_check(calls.engine.get_conversation_history() == history, "transcript queries deterministic and pure")
	_check(calls.engine.get_state_snapshot() == original and event_count[0] == 1, "history reconstruction does not mutate live session or emit events")
	var detached: Array = calls.engine.get_conversation_history()
	detached[0].text = "tampered"
	_check(calls.get_view().history == history, "history copies detached")
	await process_frame
	await process_frame
	_check(calls.saves.validate_save().ok, "12 autosave persists confirmed result")
	var restored = Calls.new(test_directory)
	_check(restored.restore_call().ok, "13 restore new controller")
	_check(restored.get_view().state == "ENDED" and restored.get_view().history == history, "14 finished call restores exact history")
	_check(restored.engine.get_state_snapshot() == original, "restore does not apply effects twice")
	_check(calls.restart_demo().ok, "11 explicit reset")
	_check(calls.get_view().state == "INCOMING" and calls.get_view().history.is_empty(), "reset clears messages")
	_check(calls.engine.get_state_snapshot().is_empty() and not calls.saves.has_save().data.exists, "reset clears demo checkpoints and narrative state")
	_check(calls.answer_call().ok and _select(calls, "demo_wait") and _select(calls, "demo_move") and _select(calls, "demo_finish"), "alternative route")
	_check(calls.get_view().ending_id == "demo_partial", "second ending real")
	calls.dispose()
	restored.dispose()
	await _test_failures()
	await process_frame
	_finish("call_controller")


func _test_failures() -> void:
	var invalid = Calls.new("user://saves")
	_check(not invalid.prepare_call().ok and invalid.get_view().state == "ERROR", "15 production storage forbidden to demo")
	var missing = Calls.new(_new_directory("call_missing"))
	_check(not missing.prepare_call("res://data/cases/missing_call_demo.json").ok, "missing content controlled")
	_check(missing.get_view().state == "ERROR" and missing.get_view().history.is_empty(), "load error has no fabricated dialogue")
	_check(missing.prepare_call().ok and missing.answer_call().ok, "recover from content error")
	var before: Dictionary = missing.engine.get_state_snapshot()
	var history: Array = missing.get_view().history
	_check(not missing.restore_call().ok, "missing checkpoint while active")
	_check(missing.engine.get_state_snapshot() == before and missing.get_view().history == history, "failed restore preserves active presentation")
	_check(missing.saves.get_status().data.autosave_enabled, "failed restore keeps prior autosave policy")
	var reentrant: Array[Dictionary] = []
	missing.presentation_changed.connect(func(_view: Dictionary) -> void: reentrant.append(missing.answer_call()))
	_check(_select(missing, "demo_confirm"), "valid call after failed restore")
	_check(not reentrant.is_empty() and reentrant[0].code == "busy", "presentation callbacks cannot mutate recursively")
	missing.dispose()
	var failing = Calls.new(_new_directory("call_write_failure"), FailingSaves)
	failing.saves.fail_write_suffix = "slot_01.tmp"
	_check(failing.prepare_call().ok and failing.answer_call().ok, "failure demo starts")
	await process_frame
	await process_frame
	_check(failing.get_view().state == "CONNECTED" and failing.get_view().error.code == "write_error", "failed save reported without disconnecting")
	before = failing.engine.get_state_snapshot()
	failing.saves.fail_write_suffix = ""
	_check(failing.retry_save().ok, "retry save explicit")
	_check(failing.engine.get_state_snapshot() == before and failing.get_view().error.is_empty(), "retry clears error without replaying decision")
	failing.dispose()
	invalid.dispose()


func _select(calls, id: String) -> bool:
	return calls.select_choice(id, calls.engine.get_state_snapshot().get("revision", 0)).ok


func _choice(calls, id: String) -> Dictionary:
	for choice: Dictionary in calls.get_view().choices:
		if choice.id == id:
			return choice
	return {}
