extends "res://tests/navigation_smoke.gd"

const FailingSaves = preload("res://tests/save/failing_save_manager.gd")
var checks: int = 0
var test_directory: String


func _run() -> void:
	if not await _prepare_main():
		_finish()
		return
	_validate_menu()
	var app = current_scene
	var console = app.console
	var panel = console.panels[&"calls"]
	test_directory = "user://save_tests/call_ui_%d_%d" % [OS.get_process_id(), Time.get_ticks_usec()]
	panel.configure_development_storage(test_directory)
	_expect(panel.controller.get_view().state == "IDLE", "initial calls view idle")
	await _click(app.main_menu.enter_button)
	await _snapshot("idle")
	await _click(panel.start_button)
	_expect(panel.controller.get_view().state == "INCOMING", "incoming through GUI")
	_expect(panel.answer_button.is_visible_in_tree(), "answer visible")
	await _snapshot("incoming")
	await _click(panel.answer_button)
	_expect(panel.controller.get_view().state == "CONNECTED", "answer through GUI")
	_expect(panel.get_node("History/Entries").get_child_count() == 1, "first transcript line rendered")
	_validate_calls_layout(panel, console)
	await _snapshot("connected")
	var revision: int = panel.controller.engine.get_state_snapshot().revision
	await _double_click(_option(panel, "demo_wait"))
	_expect(panel.controller.engine.get_state_snapshot().revision == revision + 1, "double pointer activation commits exactly one choice")
	_expect(panel.controller.get_view().history.size() == 3, "only one selected response recorded")
	var after_first_tap: int = panel.controller.engine.get_state_snapshot().revision
	await _gesture_repeat(_option(panel, "demo_adjust"), false)
	_expect(panel.controller.engine.get_state_snapshot().revision == after_first_tap, "classified double click cannot accidentally choose the next node response")
	_expect(_option(panel, "demo_ready").disabled, "conditional button disabled")
	_expect(_option(panel, "demo_ready").text.contains("Primero confirme"), "disabled reason shown without relying on tooltip")
	_validate_calls_layout(panel, console)
	await _snapshot("conditional")
	var snapshot: Dictionary = panel.controller.engine.get_state_snapshot()
	var transcript: Array = panel.controller.get_view().history
	var history_nodes: Array = panel.get_node("History/Entries").get_children()
	for section: StringName in [&"audio", &"map", &"evidence", &"calls"]:
		await _click(console.navigation.buttons[section])
		_expect(panel.controller.engine.get_state_snapshot() == snapshot, "navigation cannot advance call")
	_expect(panel.controller.get_view().history == transcript, "transcript survives tab navigation")
	_expect(panel.get_node("History/Entries").get_children() == history_nodes, "navigation does not recreate transcript controls")
	await _click(console.get_node("ConsoleHeader/Content/TopRow/MenuButton"))
	await _click(app.main_menu.enter_button)
	_expect(panel.controller.get_view().history == transcript, "menu roundtrip preserves call")
	panel.history_scroll.scroll_vertical = 0
	await _settle()
	_expect(panel.history_scroll.get_v_scroll_bar().max_value > panel.history_scroll.get_v_scroll_bar().page, "long transcript really scrolls")
	await _click(_option(panel, "demo_adjust"))
	_expect(panel.history_scroll.scroll_vertical == 0, "reading older lines is not displaced by new intervention")
	_expect(_option(panel, "demo_adjust") == null, "once option disappears")
	_expect(not _option(panel, "demo_ready").disabled, "engine condition updates GUI")
	await _snapshot("history")
	panel.choices_scroll.ensure_control_visible(_option(panel, "demo_ready"))
	await _settle()
	after_first_tap = panel.controller.engine.get_state_snapshot().revision
	await _gesture_repeat(_option(panel, "demo_ready"), true)
	_expect(panel.controller.engine.get_state_snapshot().revision == after_first_tap, "classified double tap cannot send another response")
	await _touch(_option(panel, "demo_ready"))
	_expect(panel.controller.engine.get_current_node().id == "demo_n03", "touch chooses long response")
	_expect(panel.get_node("Caller").text == "Operador · prueba", "speaker changes from data")
	await _settle()
	_expect(panel.controller.saves.validate_save().ok, "confirmed progress saved through manager")
	snapshot = panel.controller.engine.get_state_snapshot()
	transcript = panel.controller.get_view().history
	panel.configure_development_storage(test_directory)
	await _settle()
	await _click(panel.restore_button)
	_expect(panel.controller.get_view().state == "CONNECTED", "restore answered call without new incoming screen")
	_expect(panel.controller.engine.get_state_snapshot() == snapshot, "restored engine exact")
	_expect(panel.controller.get_view().history == transcript, "restored transcript exact, no phantom lines")
	_expect(panel.history_scroll.scroll_vertical > 0, "restored conversation reveals the latest intervention after layout")
	await _snapshot("restored")
	await _click(_option(panel, "demo_finish"))
	_expect(panel.controller.get_view().state == "ENDED", "GUI route ends")
	_expect(panel.options.get_child_count() == 0 and not panel.choices_scroll.visible, "ending has no live choices")
	_expect(panel.get_node("Message").text.contains("demo_complete"), "technical ending clearly identified")
	await _snapshot("ended")
	await _click(panel.restore_button)
	_expect(panel.controller.get_view().state == "ENDED", "finished save remains ended")
	await _click(panel.restart_button)
	_expect(panel.controller.get_view().state == "INCOMING" and panel.get_node("History/Entries").get_child_count() == 0, "debug reset clears old lines")
	await _touch(panel.answer_button)
	await _click(_option(panel, "demo_wait"))
	await _click(_option(panel, "demo_move"))
	await _click(_option(panel, "demo_finish"))
	_expect(panel.controller.get_view().ending_id == "demo_partial", "alternative GUI ending")
	await _snapshot("ended_partial")
	panel.configure_development_storage(test_directory + "_failure", FailingSaves)
	panel.controller.saves.fail_write_suffix = "slot_01.tmp"
	await _click(panel.start_button)
	await _click(panel.answer_button)
	_expect(panel.controller.get_view().state == "CONNECTED" and panel.get_node("Retry").is_visible_in_tree(), "save error leaves conversation interactive and exposes retry")
	_expect(panel.get_node("Retry").get_global_rect().end.y <= console.navigation.get_global_rect().position.y, "save retry remains above fixed navigation")
	await _snapshot("save_error")
	panel.controller.saves.fail_write_suffix = ""
	await _click(panel.get_node("Retry"))
	_expect(panel.controller.get_view().error.is_empty(), "retry fixes disk state without restarting")
	panel.set_development_enabled(false)
	panel.configure_development_storage(test_directory + "_disabled")
	panel._prepare()
	_expect(panel.controller.get_view().state == "IDLE" and not panel.get_node("Development").visible, "disabled development policy cannot launch demonstration")
	_expect(app.main_menu.continue_button.disabled, "production continue remains disabled")
	panel.set_development_enabled(true)
	panel.controller.prepare_call("res://data/cases/missing_call_demo.json")
	await _settle()
	_expect(panel.controller.get_view().state == "ERROR", "content error has coherent visual state")
	await _snapshot("load_error")
	await _click(panel.start_button)
	_expect(panel.controller.get_view().state == "INCOMING", "user can recover from content error through development action")
	if failures.is_empty():
		print("PASS call_integration checks=", checks, " window=", root.size, " display=", DisplayServer.get_name(), " isolated_path=", test_directory)
	_finish()


func _option(panel, id: String) -> Button:
	for button: Button in panel.options.get_children():
		if button.choice_id == id:
			return button
	return null


func _validate_calls_layout(panel, console) -> void:
	_validate_visible_controls()
	_expect(panel.history_scroll.get_global_rect().size.y >= 160, "history has usable height")
	_expect(panel.choices_scroll.get_global_rect().end.y <= console.navigation.get_global_rect().position.y, "decisions remain above fixed navigation")
	_expect(root.get_visible_rect().encloses(console.navigation.get_global_rect()), "navigation within viewport")
	for button: Button in panel.options.get_children():
		_expect(button.autowrap_mode != TextServer.AUTOWRAP_OFF and button.text_overrun_behavior == TextServer.OVERRUN_NO_TRIMMING, "multiline choices never truncate")


func _double_click(button: Button) -> void:
	var parent: Node = button.get_parent()
	while parent != null:
		if parent is ScrollContainer:
			parent.ensure_control_visible(button)
		parent = parent.get_parent()
	await _settle()
	var position: Vector2 = button.get_global_rect().get_center()
	var motion: InputEventMouseMotion = InputEventMouseMotion.new()
	motion.position = position
	root.push_input(motion, true)
	for repetition: int in range(2):
		for pressed: bool in [true, false]:
			var event: InputEventMouseButton = InputEventMouseButton.new()
			event.button_index = MOUSE_BUTTON_LEFT
			event.position = position
			event.global_position = position
			event.pressed = pressed
			root.push_input(event, true)
	await _settle()


func _expect(condition: bool, description: String) -> void:
	checks += 1
	super._expect(condition, description)


func _gesture_repeat(button: Button, touch: bool) -> void:
	var parent: Node = button.get_parent()
	while parent != null:
		if parent is ScrollContainer:
			parent.ensure_control_visible(button)
		parent = parent.get_parent()
	await _settle()
	var position: Vector2 = button.get_global_rect().get_center()
	for pressed: bool in [true, false]:
		if touch:
			var event: InputEventScreenTouch = InputEventScreenTouch.new()
			event.position = root.get_final_transform() * position
			event.pressed = pressed
			event.double_tap = pressed
			Input.parse_input_event(event)
		else:
			var event: InputEventMouseButton = InputEventMouseButton.new()
			event.position = position
			event.global_position = position
			event.button_index = MOUSE_BUTTON_LEFT
			event.pressed = pressed
			event.double_click = pressed
			root.push_input(event, true)
	await _settle()


func _finish() -> void:
	if failures.is_empty():
		quit(0)
	else:
		for failure: String in failures:
			push_error("FAIL " + failure)
		quit(1)
