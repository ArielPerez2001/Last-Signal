extends "res://tests/navigation_smoke.gd"

const Calls = preload("res://scripts/systems/call_controller.gd")
const Failing = preload("res://tests/save/failing_save_manager.gd")
var checks: int = 0
var stage: String = "prepare"


func _run() -> void:
	create_timer(60).timeout.connect(func() -> void:
		_expect(false, "timeout at " + stage)
		_finish()
	)
	if not await _prepare_main():
		_finish()
		return
	_validate_menu()
	var app = current_scene
	var console = app.console
	var calls = console.panels[&"calls"]
	var panel = console.panels[&"map"]
	var archive = console.panels[&"evidence"]
	var directory: String = "user://save_tests/dispatch_ui_%d_%d" % [OS.get_process_id(), Time.get_ticks_usec()]
	calls.configure_development_storage(directory)
	await _click(app.main_menu.enter_button)
	await _click(console.navigation.buttons[&"map"])
	_expect(not panel.get_node("Canvas").visible and panel.get_node("Review").disabled, "empty map coherent")
	await _shot("empty")
	await _click(console.navigation.buttons[&"calls"])
	await _click(calls.get_node("Development/Actions/Dispatch"))
	directory = calls.controller.saves.get_paths().main.get_base_dir()
	_expect(directory.begins_with("user://save_tests/"), "development map slot isolated")
	await _click(calls.answer_button)
	await _click(_choice(calls, "dsp_report"))
	var before: Dictionary = calls.controller.engine.get_state_snapshot()
	var history: Array = calls.controller.engine.get_conversation_history()
	await _click(console.navigation.buttons[&"map"])
	_expect(panel.engine == calls.controller.engine and panel.map_manager.get_visible_locations().size() == 2 and panel.dispatch.get_units(true).size() == 2, "same engine with two units and only visible markers")
	_expect(panel.get_node("Canvas").get_child_count() == 2, "hidden port has no marker")
	await _shot("map")
	await _tap(_metadata(panel.get_node("Canvas"), "location_id", "dsp_urban"))
	_expect(panel.location_id == "dsp_urban" and calls.controller.engine.get_state_snapshot() == before, "touch marker selects read-only location")
	await _click(_metadata(panel.get_node("Incidents"), "incident_id", "dsp_alarm"))
	await _shot("location")
	await _click(_metadata(panel.get_node("Units"), "unit_id", "patrol_01"))
	await _click(panel.get_node("Review"))
	_expect(panel.get_node("Confirmation").visible and panel.get_node("Confirmation/Text").text.contains("dejará de estar disponible") and calls.controller.engine.get_state_snapshot() == before, "confirmation explains resource consequence without dispatch")
	console.content_scroll.ensure_control_visible(panel.get_node("Confirmation/Confirm"))
	await _settle()
	await _shot("confirmation")
	await _click(panel.get_node("Confirmation/Cancel"))
	_expect(calls.controller.engine.get_state_snapshot() == before, "cancel pure")
	await _click(panel.get_node("Review"))
	await _click(panel.get_node("Confirmation/Confirm"))
	_expect(panel.last_result.code == "VALID" and panel.dispatch.get_unit_status("patrol_01").data.status == "ASSIGNED", "confirmed real dispatch")
	_expect(calls.controller.engine.get_conversation_history() == history and calls.controller.engine.get_state_snapshot().visits == before.visits, "dispatch does not restart call or invent transcript")
	await _shot("assigned")
	before = calls.controller.engine.get_state_snapshot()
	panel._confirm()
	_expect(calls.controller.engine.get_state_snapshot() == before, "same confirmation callback cannot dispatch twice")
	await _click(console.navigation.buttons[&"calls"])
	_expect(_choice(calls, "dsp_new_port") != null, "new real call response after assignment")
	await _click(_choice(calls, "dsp_new_port"))
	await _click(console.navigation.buttons[&"map"])
	await _click(_metadata(panel.get_node("Events"), "event_id", "dsp_alarm_arrive"))
	_expect(panel.dispatch.get_unit_status("patrol_01").data.status == "BUSY" and panel.last_result.message.contains("sensor en modo de ensayo"), "false alarm explained through narrative arrival")
	await _shot("busy")
	await _click(_metadata(panel.get_node("Locations"), "location_id", "dsp_dock"))
	await _click(_metadata(panel.get_node("Incidents"), "incident_id", "dsp_port"))
	await _click(_metadata(panel.get_node("Units"), "unit_id", "patrol_01"))
	before = calls.controller.engine.get_state_snapshot()
	await _click(panel.get_node("Review"))
	_expect(panel.last_result.code == "UNIT_BUSY" and calls.controller.engine.get_state_snapshot() == before and not panel.get_node("Confirmation").visible, "occupied unit rejected without partial changes")
	await _shot("blocked")
	for id: StringName in [&"audio", &"evidence", &"calls", &"map"]:
		await _click(console.navigation.buttons[id])
	_expect(calls.controller.engine.get_state_snapshot() == before and panel.dispatch.get_unit_status("patrol_01").data.status == "BUSY", "19 navigation never advances or releases resources")
	_expect(calls.controller.saves.validate_save().data.document.save_version == 4, "16 format 4 checkpoint exists")
	await _click(console.navigation.buttons[&"calls"])
	calls.configure_development_storage(directory, null, Calls.DISPATCH_PATH)
	var notices: Array[String] = []
	calls.controller.engine.event_requested.connect(func(_event: Dictionary) -> void: notices.append("event"))
	calls.controller.engine.evidence_registered.connect(func(_id: String) -> void: notices.append("evidence"))
	await _click(calls.restore_button)
	await _click(console.navigation.buttons[&"map"])
	_expect(calls.controller.engine.get_state_snapshot() == before and notices.is_empty() and panel.dispatch.get_unit_status("patrol_01").data.status == "BUSY", "17/18 restore retains occupied assignment without effects")
	await _shot("restored")
	await _click(_metadata(panel.get_node("Events"), "event_id", "dsp_alarm_resolve"))
	_expect(archive.evidence.get_detail("dsp_alarm_report").ok and panel.dispatch.get_incident("dsp_alarm").data.status == "CLOSED", "resolution grants real evidence")
	await _shot("resolved")
	await _click(_metadata(panel.get_node("Events"), "event_id", "dsp_alarm_release"))
	_expect(panel.dispatch.get_unit_status("patrol_01").data.status == "AVAILABLE", "explicit authorized release")
	await _shot("released")
	await _click(_metadata(panel.get_node("Locations"), "location_id", "dsp_dock"))
	await _click(_metadata(panel.get_node("Incidents"), "incident_id", "dsp_port"))
	await _click(_metadata(panel.get_node("Units"), "unit_id", "patrol_01"))
	await _click(panel.get_node("Review"))
	await _click(panel.get_node("Confirmation/Confirm"))
	for part: String in ["arrive", "resolve", "release"]:
		await _click(_metadata(panel.get_node("Events"), "event_id", "dsp_port_" + part))
	await _click(console.navigation.buttons[&"evidence"])
	_expect(archive.cards.has("dsp_alarm_report") and archive.cards.has("dsp_port_report"), "operational reports are in common archive")
	await _shot("evidence")
	await _click(console.navigation.buttons[&"calls"])
	_expect(_choice(calls, "dsp_followup") != null, "24 result enables call condition")
	await _click(_choice(calls, "dsp_finish"))
	await _click(console.navigation.buttons[&"map"])
	_expect(panel.engine.is_case_finished() and panel.get_node("Review").disabled and panel.dispatch.get_available_events().is_empty(), "ended map read-only")
	await _shot("closed")
	await _click(console.navigation.buttons[&"calls"])
	await _click(calls.restart_button)
	await _click(console.navigation.buttons[&"map"])
	_expect(panel.map_manager.get_visible_locations().is_empty() and panel.pending.is_empty(), "new demo clears old presentation")
	await _click(console.navigation.buttons[&"calls"])
	calls.configure_development_storage(directory + "_failure", Failing, Calls.DISPATCH_PATH)
	calls.controller.saves.fail_write_suffix = "slot_01.tmp"
	await _click(calls.start_button)
	await _click(calls.answer_button)
	await _click(_choice(calls, "dsp_report"))
	await _click(console.navigation.buttons[&"map"])
	_expect(panel.get_node("Retry").visible and panel.get_node("SaveNotice").visible, "save failure visible on map")
	before = calls.controller.engine.get_state_snapshot()
	calls.controller.saves.fail_write_suffix = ""
	await _click(panel.get_node("Retry"))
	_expect(calls.controller.engine.get_state_snapshot() == before and not panel.get_node("Retry").visible, "retry writes same state without redispatch")
	_expect(app.main_menu.continue_button.disabled, "production continue unchanged")
	if failures.is_empty():
		print("PASS dispatch_integration checks=", checks, " window=", root.size, " display=", DisplayServer.get_name())
	_finish()


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


func _tap(button: Button) -> void:
	var parent: Node = button.get_parent()
	while parent != null:
		if parent is ScrollContainer:
			parent.ensure_control_visible(button)
		parent = parent.get_parent()
	await _settle()
	for pressed: bool in [true, false]:
		var event: InputEventScreenTouch = InputEventScreenTouch.new()
		event.position = button.get_global_rect().get_center()
		event.pressed = pressed
		root.push_input(event, true)
	await _settle()


func _shot(name: String) -> void:
	stage = name
	_validate_visible_controls()
	_expect(root.get_visible_rect().encloses(current_scene.console.navigation.get_global_rect()), "bottom navigation accessible")
	await _snapshot(name)


func _expect(condition: bool, message: String) -> void:
	checks += 1
	super._expect(condition, message)


func _finish() -> void:
	if failures.is_empty():
		quit(0)
	else:
		for failure: String in failures:
			push_error("FAIL " + failure)
		quit(1)
