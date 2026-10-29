extends "res://tests/save/save_test_support.gd"

const Analysis = preload("res://scripts/systems/audio_analysis_manager.gd")
const Evidence = preload("res://scripts/systems/evidence_manager.gd")
const Deductions = preload("res://scripts/systems/deduction_manager.gd")
const PATH: String = "res://data/audio/audio_analysis_demo.json"

# Logical tests inject a playback source. Actual AudioStreamPlayer, bus samples,
# timing, seeks and UI are exercised separately in test_audio_integration.
class FakePlayback extends Node:
	signal progressed(view: Dictionary)
	signal changed(view: Dictionary)
	var view: Dictionary = {"recording_id": "", "segment_id": "", "filter_id": "original", "state": "STOPPED", "listened_seconds": 0.0}
	func get_view() -> Dictionary:
		return view.duplicate(true)
	func clear() -> void:
		view.recording_id = ""
		view.segment_id = ""
		view.listened_seconds = 0.0
	func pause() -> Dictionary:
		return {"ok": true}
	func load_recording(record: Dictionary) -> Dictionary:
		view.recording_id = record.recording_id
		return {"ok": true}
	func set_filter(id: String) -> Dictionary:
		view.filter_id = id
		view.listened_seconds = 0.0
		return {"ok": true}
	func play_segment(id: String) -> Dictionary:
		view.segment_id = id
		view.listened_seconds = 0.0
		return {"ok": true}
	func examine(seconds: float) -> void:
		view.listened_seconds = seconds
		progressed.emit(get_view())


func _run() -> void:
	test_directory = _new_directory("audio_analysis")
	var engine = Narrative.new()
	_check(engine.load_case(PATH) and engine.start_case(), "schema 3 starts")
	var physical = FakePlayback.new()
	root.add_child(physical)
	var manager = Analysis.new(engine, physical)
	var evidence = Evidence.new(engine)
	_check(manager.get_recordings().is_empty(), "03 locked recording list empty")
	var before: Dictionary = engine.get_state_snapshot()
	_check(not manager.get_recording("aud_recording_01").ok and not manager.select_recording("aud_recording_01").ok, "locked recording cannot be inspected or loaded")
	_check(not manager.play_segment("aud_s02").ok and not manager.set_filter("ambiente").ok and not manager.register_observation("aud_rule_pulses").ok, "public player commands cannot bypass unlock")
	_check(engine.get_state_snapshot() == before and physical.get_view().recording_id.is_empty(), "locked API preserves logical and physical state")
	_check(engine.select_choice("aud_unlock"), "04/12 narrative choice unlocks recording")
	_check(manager.get_recordings().size() == 1, "recording becomes available from existing conditions")
	_check(manager.select_recording("aud_recording_01").ok, "recording selected")
	_check(not manager.get_recording("missing").ok and not manager.select_recording("missing").ok, "unknown recording indistinguishable from locked")
	_check(not manager.get_recording("aud_recording_01").data.variants[0].has("audio_path"), "player projection omits internal resource paths")
	_check(manager.register_observation().code == "INSUFFICIENT", "10 opening analyzer grants nothing")
	manager.set_filter("ambiente")
	_check(manager.register_observation().code == "INSUFFICIENT", "filter alone grants nothing")
	manager.play_segment("aud_s01")
	physical.examine(4.0)
	_check(manager.register_observation().code == "INSUFFICIENT", "wrong segment/filter combination harmless")
	manager.play_segment("aud_s02")
	_check(manager.get_accessible_information().contains("tres pulsos"), "equivalent textual clue available without hearing acuity")
	physical.examine(2.5)
	_check(manager.register_observation().code == "INSUFFICIENT", "insufficient examination cannot register")
	before = engine.get_state_snapshot()
	var history: Array = engine.get_conversation_history()
	var notices: Array[String] = []
	engine.evidence_registered.connect(func(id: String) -> void: notices.append(id))
	var events: Array[String] = []
	engine.event_requested.connect(func(event: Dictionary) -> void: events.append(event.event_id))
	physical.examine(3.1)
	_check(manager.get_observations()[0].ready, "09 actual playback report qualifies observation")
	_check(manager.register_observation().code == "VALID", "qualified observation committed through existing engine")
	_check(evidence.get_detail("aud_pulses").ok and evidence.get_detail("aud_pulses").data.source.contains("Ambiente"), "13 EvidenceManager exposes actual audio evidence and source")
	_check(engine.get_state_snapshot().current_node == before.current_node and engine.get_state_snapshot().visits == before.visits and engine.get_conversation_history() == history, "audio discovery does not repeat dialogue or visits")
	_check(notices == ["aud_pulses"] and events == ["aud_observation"], "single real discovery and event")
	before = engine.get_state_snapshot()
	_check(manager.register_observation().code == "ALREADY_DISCOVERED" and engine.get_state_snapshot() == before, "11 repeat is idempotent")
	_check(notices.size() == 1 and events.size() == 1, "no duplicated effect notifications")
	_check(engine.consume_event(engine.get_pending_events()[0].id), "event consumption interleaved with analysis")
	manager.set_filter("voces")
	manager.play_segment("aud_s03")
	physical.examine(3.3)
	_check(manager.register_observation().ok and evidence.get_detail("aud_marker").ok, "optional synthetic marker observation")
	_check(Deductions.new(engine).relate(["aud_pulses", "aud_reference"]).code == "VALID", "14 audio evidence participates in existing deduction")
	var saves = Saves.new(engine, test_directory)
	var saved: Dictionary = saves.save_current_session()
	_check(saved.ok, "15 save investigation to isolated disk")
	if not saved.ok:
		print("SAVE_FAILURE ", saved, " previous_failures=", failures)
		manager.dispose()
		evidence.dispose()
		physical.queue_free()
		_finish("audio_analysis")
		return
	var document: Dictionary = _document(saves.get_paths().main)
	_check(document.save_version == 3 and document.narrative_schema_version == 3 and document.session.size() == 17, "explicit format 3 without second persistent collection")
	_check(document.session.transaction_log[1].analysis.listened_ms == 3000, "minimal canonical proof persisted in existing journal")
	var fresh = Narrative.new()
	_check(fresh.load_case(PATH), "fresh engine loads exact content")
	var fresh_saves = Saves.new(fresh, test_directory)
	var restored_notices: Array[String] = []
	fresh.evidence_registered.connect(func(_id: String) -> void: restored_notices.append("evidence"))
	fresh.deduction_confirmed.connect(func(_id: String) -> void: restored_notices.append("deduction"))
	fresh.event_requested.connect(func(_event: Dictionary) -> void: restored_notices.append("event"))
	_check(fresh_saves.load_saved_session().ok and fresh.get_state_snapshot() == engine.get_state_snapshot(), "16 exact recovery with interleaved consumption")
	_check(restored_notices.is_empty() and Deductions.new(fresh).get_confirmed().size() == 1, "restore retains deductions without new events")
	var restored_player = FakePlayback.new()
	root.add_child(restored_player)
	var restored_manager = Analysis.new(fresh, restored_player)
	_check(restored_manager.get_recordings()[0].confirmed == 2 and restored_player.get_view().recording_id.is_empty(), "restored analysis derives from IDs, playback stopped")
	before = fresh.get_state_snapshot()
	for defect: String in ["short", "wrong_filter", "unknown_rule", "foreign_proof", "missing_proof", "legacy_version"]:
		var bad: Dictionary = document.duplicate(true)
		match defect:
			"short": bad.session.transaction_log[1].analysis.listened_ms = 1
			"wrong_filter": bad.session.transaction_log[1].analysis.filter_id = "original"
			"unknown_rule": bad.session.transaction_log[1].choice_id = "unknown_audio_rule"
			"foreign_proof": bad.session.transaction_log[0].analysis = bad.session.transaction_log[1].analysis.duplicate(true)
			"missing_proof": bad.session.transaction_log[1].erase("analysis")
			"legacy_version": bad.save_version = 2
		_write(saves.get_paths().main, bad)
		_check(not fresh_saves.load_saved_session().ok and fresh.get_state_snapshot() == before, "incompatible proof rejected safely: " + defect)
	_check(_deterministic_state() == _deterministic_state(), "18 identical sequence gives exact canonical snapshot")
	_check(engine.restart_case() and engine.select_choice("aud_unlock"), "new session reset")
	manager.select_recording("aud_recording_01")
	manager.set_filter("ambiente")
	manager.play_segment("aud_s02")
	_check(manager.register_observation().code == "INSUFFICIENT", "new session does not inherit old examination")
	manager.dispose()
	evidence.dispose()
	restored_manager.dispose()
	physical.queue_free()
	restored_player.queue_free()
	_finish("audio_analysis")


func _deterministic_state() -> Dictionary:
	var engine = Narrative.new()
	engine.load_case(PATH)
	engine.start_case()
	engine.select_choice("aud_unlock")
	var physical = FakePlayback.new()
	root.add_child(physical)
	var manager = Analysis.new(engine, physical)
	manager.select_recording("aud_recording_01")
	manager.set_filter("ambiente")
	manager.play_segment("aud_s02")
	physical.examine(3.9)
	_check(manager.register_observation().ok, "deterministic qualified observation")
	var state: Dictionary = engine.get_state_snapshot()
	manager.dispose()
	physical.queue_free()
	return state
