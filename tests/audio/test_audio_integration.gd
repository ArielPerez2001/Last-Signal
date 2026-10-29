extends "res://tests/navigation_smoke.gd"

const Calls = preload("res://scripts/systems/call_controller.gd")
const Catalog = preload("res://scripts/systems/audio_catalog_validator.gd")
var checks: int = 0
var _stage: String = "prepare"
var _probe: AudioEffectCapture
var _probe_bus: int = -1
var _sample_count: int = 0
var _peak: float = 0.0


func _run() -> void:
	create_timer(90).timeout.connect(func() -> void:
		_expect(false, "timeout at " + _stage)
		_finish()
	)
	if not await _prepare_main():
		_finish()
		return
	_validate_menu()
	var app = current_scene
	var console = app.console
	var calls = console.panels[&"calls"]
	var audio = console.panels[&"audio"]
	var archive = console.panels[&"evidence"]
	var directory: String = "user://save_tests/audio_ui_%d_%d" % [OS.get_process_id(), Time.get_ticks_usec()]
	calls.configure_development_storage(directory)
	await _click(app.main_menu.enter_button)
	await _click(console.navigation.buttons[&"audio"])
	_expect(audio.get_node("Empty").is_visible_in_tree() and not audio.get_node("Player").visible, "empty audio coherent")
	await _shot("empty")
	await _click(console.navigation.buttons[&"calls"])
	await _click(calls.get_node("Development/Actions/Audio"))
	directory = calls.controller.saves.get_paths().main.get_base_dir()
	_expect(directory.begins_with("user://save_tests/"), "new development action preserves isolated test storage")
	await _click(calls.answer_button)
	await _click(console.navigation.buttons[&"audio"])
	_expect(audio.manager.get_recordings().is_empty(), "answered call still needs narrative unlock")
	await _shot("locked")
	await _click(console.navigation.buttons[&"calls"])
	await _click(_choice(calls, "aud_unlock"))
	await _click(console.navigation.buttons[&"audio"])
	_expect(audio.manager.engine == calls.controller.engine and audio.manager.get_recordings().size() == 1, "narrative unlock shared live engine")
	await _shot("available")
	await _click(audio.get_node("Recordings").get_child(0))
	_expect(audio.playback.get_view().state == "STOPPED" and audio.playback.player.stream is AudioStreamWAV, "real WAV loaded without autoplay")
	_expect(audio.find_children("*", "AudioStreamPlayer", true, false).size() == 1 and audio.playback.player.max_polyphony == 1, "one physical player and one voice")
	_setup_probe(audio.playback.player)
	var endings: Array[String] = []
	audio.playback.finished.connect(func(mode: String) -> void: endings.append(mode))
	await _shot("player")
	await _click(audio.get_node("Player/Transport/Play"))
	await create_timer(0.35).timeout
	_expect(audio.playback.get_view().position > 0.1, "physical playback position advances")
	var position: float = audio.playback.get_view().position
	await _click(audio.get_node("Player/Transport/Play"))
	_expect(audio.playback.get_view().position >= position - 0.03, "rapid play does not restart or duplicate playback")
	_sample_probe()
	await _click(audio.get_node("Player/Transport/Stop"))
	_expect(audio.playback.get_view().position == 0 and not audio.playback.player.playing, "stop resets full recording")
	await _seek_slider(audio.get_node("Player/Progress"), 0.5, false)
	_expect(absf(audio.playback.get_view().position - 6) < 0.8, "mouse slider seek")
	await _seek_slider(audio.get_node("Player/Progress"), 0.25, true)
	_expect(absf(audio.playback.get_view().position - 3) < 0.8, "touch slider seek")
	await _click(_metadata(audio.get_node("Player/Filters"), "filter_id", "ambiente"))
	_expect(absf(audio.playback.get_view().position - 3) < 0.8, "filter keeps temporal position")
	await _click(_metadata(audio.get_node("Player/Segments"), "segment_id", "aud_s02"))
	_expect(audio.playback.get_view().segment_id == "aud_s02" and audio.playback.get_view().state == "PLAYING", "segment starts at defined interval")
	await _click(audio.get_node("Player/Register"))
	_expect(audio.last_result.code == "INSUFFICIENT", "selection or filter alone cannot discover")
	await _click(audio.get_node("Player/Transport/Pause"))
	position = audio.playback.get_view().position
	await create_timer(0.2).timeout
	_expect(audio.playback.get_view().state == "PAUSED" and is_equal_approx(position, audio.playback.get_view().position), "pause freezes position")
	await _shot("paused")
	await _click(audio.get_node("Player/Transport/Play"))
	await create_timer(0.2).timeout
	_expect(audio.playback.get_view().state == "PLAYING" and audio.playback.get_view().position > position + 0.1, "resume continues paused stream")
	await _click(audio.get_node("Player/Transport/Pause"))
	position = audio.playback.get_view().position
	await _click(_metadata(audio.get_node("Player/Filters"), "filter_id", "voces"))
	_expect(audio.playback.get_view().state == "PAUSED" and absf(audio.playback.get_view().position - position) < 0.05, "filter preserves pause and position")
	await _click(_metadata(audio.get_node("Player/Filters"), "filter_id", "ambiente"))
	audio.playback.seek(7.8)
	await _click(audio.get_node("Player/Transport/Play"))
	await create_timer(0.3).timeout
	_expect(audio.manager.register_observation().code == "INSUFFICIENT", "seek to segment end never qualifies unexamined audio")
	await _click(audio.get_node("Player/Transport/Replay"))
	await create_timer(0.2).timeout
	await _shot("segment")
	await _click(console.navigation.buttons[&"calls"])
	position = audio.playback.get_view().position
	await create_timer(0.2).timeout
	_expect(audio.playback.get_view().state == "PAUSED" and is_equal_approx(position, audio.playback.get_view().position), "17 tab departure pauses and keeps position")
	await _click(console.navigation.buttons[&"audio"])
	_expect(audio.playback.get_view().state == "PAUSED", "return never auto resumes")
	await _click(audio.get_node("Player/Transport/Replay"))
	_stage = "physical environment segment"
	await create_timer(4.4).timeout
	_sample_probe()
	_expect(audio.playback.get_view().state == "ENDED" and absf(audio.playback.get_view().position - 8) < 0.05, "segment stops at its end, not whole track")
	_expect(not audio.manager.get_observations().is_empty() and audio.manager.get_observations()[0].ready, "real playback qualifies observation")
	await _reveal(audio.get_node("Player/Register"))
	await _shot("qualified")
	var before: Dictionary = calls.controller.engine.get_state_snapshot()
	var history: Array = calls.controller.engine.get_conversation_history()
	await _click(audio.get_node("Player/Register"))
	_expect(audio.last_result.code == "VALID" and archive.evidence.get_detail("aud_pulses").ok, "real registration changes EvidenceManager state")
	_expect(calls.controller.engine.get_conversation_history() == history and calls.controller.engine.get_state_snapshot().visits == before.visits, "discovery creates no spoken line or node visit")
	await _shot("registered")
	before = calls.controller.engine.get_state_snapshot()
	var writes: int = calls.controller.saves.get_status().data.writes
	await _click(audio.get_node("Player/Register"))
	_expect(audio.last_result.code == "ALREADY_DISCOVERED" and calls.controller.engine.get_state_snapshot() == before and calls.controller.saves.get_status().data.writes == writes, "repeat grants no effects or writes")
	await _click(console.navigation.buttons[&"evidence"])
	_expect(archive.cards.has("aud_reference") and archive.cards.has("aud_pulses"), "13 real archive shows audio evidence")
	await _shot("evidence")
	await _click(archive.cards["aud_reference"].get_node("Content/Actions/Select"))
	await _click(archive.cards["aud_pulses"].get_node("Content/Actions/Select"))
	await _click(archive.get_node("Relate"))
	_expect(archive.result.code == "VALID", "14 real deduction accepts audio clue")
	await _click(console.navigation.buttons[&"audio"])
	await _click(_metadata(audio.get_node("Player/Filters"), "filter_id", "voces"))
	await _click(_metadata(audio.get_node("Player/Segments"), "segment_id", "aud_s03"))
	_stage = "physical marker segment"
	await create_timer(4.4).timeout
	_sample_probe()
	await _tap(audio.get_node("Player/Register"))
	_expect(audio.last_result.code == "VALID" and archive.evidence.get_detail("aud_marker").ok, "touch registers optional observation after playback")
	await _shot("optional")
	await _click(audio.get_node("Player/Transport/Replay"))
	await create_timer(0.15).timeout
	audio.playback.notification(Node.NOTIFICATION_APPLICATION_PAUSED)
	_expect(audio.playback.get_view().state == "PAUSED", "application pause stops sounding without losing context")
	before = calls.controller.engine.get_state_snapshot()
	history = calls.controller.engine.get_conversation_history()
	_expect(calls.controller.saves.validate_save().data.document.save_version == 3, "15 confirmed format 3 checkpoint")
	await _click(console.navigation.buttons[&"calls"])
	calls.configure_development_storage(directory, null, Calls.AUDIO_PATH)
	var notices: Array[String] = []
	calls.controller.engine.evidence_registered.connect(func(_id: String) -> void: notices.append("evidence"))
	calls.controller.engine.event_requested.connect(func(_event: Dictionary) -> void: notices.append("event"))
	await _click(calls.restore_button)
	await _click(console.navigation.buttons[&"audio"])
	_expect(calls.controller.engine.get_state_snapshot() == before and notices.is_empty() and calls.controller.engine.get_conversation_history() == history, "16 restored exact state without live effects")
	_expect(audio.manager.get_recordings()[0].confirmed == 2 and archive.deductions.get_confirmed().size() == 1 and audio.playback.get_view().state == "EMPTY", "restored analyses and deduction, no autoplay")
	await _shot("restored")
	await _click(audio.get_node("Recordings").get_child(0))
	audio.playback.player.bus = AudioServer.get_bus_name(_probe_bus)
	await _click(audio.get_node("Player/Transport/Full"))
	audio.playback.seek(11.6)
	await create_timer(0.9).timeout
	_expect(audio.playback.get_view().state == "ENDED" and audio.playback.get_view().segment_id.is_empty() and audio.playback.get_view().position == 12, "full recording completion distinct from segment")
	_expect(endings.has("segment") and endings.count("recording") == 1, "completion signal identifies segment versus full recording once")
	await _shot("ended")
	before = calls.controller.engine.get_state_snapshot()
	position = audio.playback.get_view().position
	_expect(not audio.manager.play_segment("missing").ok and audio.playback.get_view().position == position, "08 nonexistent segment does not change timeline")
	_expect(not audio.manager.set_filter("missing").ok and audio.playback.get_view().position == position, "06 unknown filter preserves other playback")
	var broken: Dictionary = calls.controller.engine.get_audio_catalog().recordings[0].duplicate(true)
	for variant: Dictionary in broken.variants:
		variant.audio_path = "res://assets/audio/demo/absent_test.wav"
	_expect(not audio.playback.load_recording(broken).ok and audio.playback.get_view().state == "ERROR", "missing physical stream controlled")
	_expect(calls.controller.engine.get_state_snapshot() == before, "physical errors do not corrupt investigation")
	var driver: String = AudioServer.get_driver_name()
	if driver != "Dummy":
		_expect(_sample_count > 0 and _peak > 0.001, "output bus contains actual non-silent PCM")
	print("AUDIO_PROBE driver=", driver, " device=", AudioServer.output_device, " frames=", _sample_count, " peak=", _peak, " human_listening=not_verified")
	if failures.is_empty():
		print("PASS audio_integration checks=", checks, " window=", root.size, " display=", DisplayServer.get_name())
	_finish()


func _setup_probe(player: AudioStreamPlayer) -> void:
	AudioServer.add_bus()
	_probe_bus = AudioServer.bus_count - 1
	AudioServer.set_bus_name(_probe_bus, "Audio09AProbe")
	_probe = AudioEffectCapture.new()
	_probe.buffer_length = 0.5
	AudioServer.add_bus_effect(_probe_bus, _probe)
	player.bus = AudioServer.get_bus_name(_probe_bus)


func _sample_probe() -> void:
	var buffer: PackedVector2Array = _probe.get_buffer(_probe.get_frames_available())
	_sample_count += buffer.size()
	for frame: Vector2 in buffer:
		_peak = maxf(_peak, maxf(absf(frame.x), absf(frame.y)))
	_probe.clear_buffer()


func _choice(panel, id: String) -> Button:
	for button: Button in panel.options.get_children():
		if button.choice_id == id:
			return button
	return null


func _metadata(container: Node, key: String, value: String) -> Button:
	for button: Button in container.get_children():
		if button.get_meta(key, "") == value:
			return button
	return null


func _reveal(control: Control) -> void:
	var parent: Node = control.get_parent()
	while parent != null:
		if parent is ScrollContainer:
			parent.ensure_control_visible(control)
		parent = parent.get_parent()
	await _settle()


func _seek_slider(slider: HSlider, ratio: float, touch: bool) -> void:
	await _reveal(slider)
	var rect: Rect2 = slider.get_global_rect()
	var position: Vector2 = Vector2(rect.position.x + rect.size.x * ratio, rect.get_center().y)
	for pressed: bool in [true, false]:
		if touch:
			var event: InputEventScreenTouch = InputEventScreenTouch.new()
			event.position = position
			event.pressed = pressed
			root.push_input(event, true)
		else:
			var event: InputEventMouseButton = InputEventMouseButton.new()
			event.position = position
			event.button_index = MOUSE_BUTTON_LEFT
			event.pressed = pressed
			root.push_input(event, true)
	await _settle()


func _tap(button: Button) -> void:
	await _reveal(button)
	for pressed: bool in [true, false]:
		var event: InputEventScreenTouch = InputEventScreenTouch.new()
		event.position = button.get_global_rect().get_center()
		event.pressed = pressed
		root.push_input(event, true)
	await _settle()


func _shot(name: String) -> void:
	_stage = name
	_validate_visible_controls()
	_expect(root.get_visible_rect().encloses(current_scene.console.navigation.get_global_rect()), "navigation remains accessible")
	await _snapshot(name)


func _expect(condition: bool, message: String) -> void:
	checks += 1
	super._expect(condition, message)


func _finish() -> void:
	if _probe_bus >= 0:
		if current_scene != null:
			current_scene.console.panels[&"audio"].playback.player.bus = &"Master"
		AudioServer.remove_bus(_probe_bus)
		_probe_bus = -1
	if failures.is_empty():
		quit(0)
	else:
		for failure: String in failures:
			push_error("FAIL " + failure)
		quit(1)
