extends "res://tests/navigation_smoke.gd"

const Calls = preload("res://scripts/systems/call_controller.gd")
const FailingSaves = preload("res://tests/save/failing_save_manager.gd")
var checks: int = 0
var _stage: String = "initialization"


func _run() -> void:
	create_timer(60.0).timeout.connect(func() -> void:
		_expect(false, "integration timeout at " + _stage)
		_finish()
	)
	if not await _prepare_main():
		_finish()
		return
	_validate_menu()
	var app = current_scene
	var console = app.console
	var calls = console.panels[&"calls"]
	var archive = console.panels[&"evidence"]
	var test_directory: String = "user://save_tests/investigation_ui_%d_%d" % [OS.get_process_id(), Time.get_ticks_usec()]
	calls.configure_development_storage(test_directory)
	await _click(app.main_menu.enter_button)
	await _click(console.navigation.buttons[&"evidence"])
	_expect(archive.cards.is_empty() and archive.get_node("Relate").disabled, "no active case has coherent empty archive")
	await _shot("empty")
	await _click(console.navigation.buttons[&"calls"])
	await _click(calls.get_node("Development/Actions/Investigation"))
	_expect(calls.controller.engine.get_case_metadata().narrative_schema_version == 2, "development action loads investigation schema")
	_expect(calls.controller.saves.get_paths().main.begins_with(test_directory), "test development action remains isolated")
	var directory: String = calls.controller.saves.get_paths().main.get_base_dir()
	await _click(calls.answer_button)
	await _click(_choice(calls, "inv_testimony"))
	await _click(console.navigation.buttons[&"evidence"])
	_expect(archive.engine == calls.controller.engine, "calls and archive share one engine")
	_expect(archive.cards.size() == 1 and archive.cards.has("inv_e01"), "new discovery appears in archive")
	_expect(not _visible_text(archive).contains("Acta de la comprobación"), "hidden evidence title not exposed")
	_expect(not archive.get_node("Summary").text.contains("/5"), "summary reveals no hidden total")
	await _shot("one_evidence")
	var original: Dictionary = archive.engine.get_state_snapshot()
	await _click(_card_button(archive, "inv_e01", "Detail"))
	_expect(archive.get_node("Detail/Source").text.contains("Procedencia"), "source visible")
	_expect(archive.engine.get_state_snapshot() == original, "detail has no rewards")
	await _click(archive.get_node("Detail/Back"))
	await _click(console.navigation.buttons[&"calls"])
	await _click(_choice(calls, "inv_document"))
	await _click(_choice(calls, "inv_log"))
	await _click(console.navigation.buttons[&"evidence"])
	_expect(archive.cards.size() == 3, "three narrative acquisitions")
	await _shot("evidence_list")
	await _click(_card_button(archive, "inv_e01", "Select"))
	await _click(_category(archive, "document"))
	_expect(archive.cards.size() == 1 and archive.selected_ids == ["inv_e01"], "filter preserves hidden-from-filter selection")
	await _shot("category")
	await _tap(_card_button(archive, "inv_e02", "Select"))
	_expect(archive.selected_ids == ["inv_e01", "inv_e02"], "two distinct selections through mouse and touch")
	if archive.selected_ids.size() != 2:
		_finish()
		return
	await _click(_card_button(archive, "inv_e02", "Detail"))
	_expect(archive.get_node("Detail/Description").text == archive.evidence.get_detail("inv_e02").data.description, "full long description available")
	_expect(archive.get_node("Detail/Image").visible, "validated image rendered")
	await _shot("evidence_detail")
	await _click(archive.get_node("Detail/Back"))
	_expect(archive.category == "document" and archive.selected_ids.size() == 2, "detail preserves filter and selections")
	var before: Dictionary = archive.engine.get_state_snapshot()
	var history: Array = archive.engine.get_conversation_history()
	await _click(archive.get_node("Relate"))
	_expect(archive.result.code == "VALID", "09 relation through GUI confirms conclusion")
	_expect(archive.engine.get_state_snapshot().current_node == before.current_node and archive.engine.get_state_snapshot().visits == before.visits, "deduction does not reenter dialogue")
	_expect(archive.engine.get_conversation_history() == history, "deduction does not invent transcript lines")
	_expect(archive.deductions.get_confirmed().size() == 1, "conclusion appears")
	await _shot("valid")
	before = archive.engine.get_state_snapshot()
	var writes: int = calls.controller.saves.get_status().data.writes
	await _click(archive.get_node("Relate"))
	_expect(archive.result.code == "ALREADY_DISCOVERED" and archive.engine.get_state_snapshot() == before, "repeated combination no duplicate effects")
	_expect(calls.controller.saves.get_status().data.writes == writes, "known conclusion does not autosave again")
	await _click(_conclusion(archive, "inv_d01"))
	_expect(archive.get_node("Detail/Source").text.contains("Testimonio del indicador"), "confirmed conclusion explains supporting evidence")
	_expect(archive.engine.get_state_snapshot() == before, "consulting conclusion pure")
	await _shot("conclusion")
	await _click(archive.get_node("Detail/Back"))
	await _click(_card_button(archive, "inv_e02", "Select"))
	await _click(_category(archive, ""))
	await _click(_card_button(archive, "inv_e03", "Select"))
	await _click(archive.get_node("Relate"))
	_expect(archive.result.code == "INSUFFICIENT" and archive.engine.get_state_snapshot() == before, "wrong combination gives harmless feedback")
	await _shot("insufficient")
	await _click(_action(archive, "inv_read_transcript"))
	await _click(_action(archive, "inv_read_comparison"))
	_expect(archive.cards.size() == 5, "two alternate acquisition routes")
	_expect(console.content_scroll.get_v_scroll_bar().max_value > console.content_scroll.get_v_scroll_bar().page, "long list has usable vertical scrolling")
	await _click(_card_button(archive, "inv_e01", "Select"))
	await _click(_card_button(archive, "inv_e03", "Select"))
	await _click(_card_button(archive, "inv_e04", "Select"))
	await _click(_card_button(archive, "inv_e05", "Select"))
	before = archive.engine.get_state_snapshot()
	await _click(archive.get_node("Relate"))
	_expect(archive.result.code == "LOCKED" and archive.engine.get_state_snapshot() == before, "additional condition protects optional rule")
	_expect(not _visible_text(archive).contains("Códigos de control distintos"), "locked rule does not reveal its conclusion")
	await _shot("locked")
	await _click(console.navigation.buttons[&"calls"])
	_expect(_choice(calls, "inv_unlocked") != null, "deduction updates dialogue choices")
	await _shot("dialogue_unlocked")
	_stage = "review choice"
	await _click(_choice(calls, "inv_review"))
	_stage = "return to evidence"
	await _click(console.navigation.buttons[&"evidence"])
	_expect(archive.selected_ids == ["inv_e04", "inv_e05"], "selection survives call navigation")
	await _click(archive.get_node("Relate"))
	_expect(archive.result.code == "VALID" and archive.deductions.get_confirmed().size() == 2, "optional deduction after narrative requirement")
	await _shot("optional")
	before = archive.engine.get_state_snapshot()
	history = archive.engine.get_conversation_history()
	var count: int = app.find_children("*", "", true, false).size()
	for section: StringName in [&"map", &"audio", &"calls", &"evidence"]:
		await _click(console.navigation.buttons[section])
	_expect(archive.engine.get_state_snapshot() == before and app.find_children("*", "", true, false).size() == count, "navigation preserves session and visual instances")
	_expect(calls.controller.saves.validate_save().data.document.save_version == 2, "versioned investigation checkpoint exists")
	await _click(console.navigation.buttons[&"calls"])
	calls.configure_development_storage(directory, null, Calls.INVESTIGATION_PATH)
	var notices: Array[String] = []
	calls.controller.engine.evidence_registered.connect(func(_id: String) -> void: notices.append("evidence"))
	calls.controller.engine.deduction_confirmed.connect(func(_id: String) -> void: notices.append("deduction"))
	calls.controller.engine.event_requested.connect(func(_event: Dictionary) -> void: notices.append("event"))
	await _click(calls.restore_button)
	await _click(console.navigation.buttons[&"evidence"])
	_expect(archive.engine.get_state_snapshot() == before and notices.is_empty(), "17/23 restore complete investigation without repeated signals")
	_expect(archive.deductions.get_confirmed().size() == 2 and archive.cards.size() == 5, "evidence and conclusions reconstructed")
	_expect(archive.engine.get_conversation_history() == history, "restored history remains exact")
	await _shot("restored")
	await _click(console.navigation.buttons[&"calls"])
	await _click(_choice(calls, "inv_unlocked"))
	await _click(_choice(calls, "inv_finish"))
	await _click(console.navigation.buttons[&"evidence"])
	_expect(archive.engine.is_case_finished() and archive.get_node("Relate").disabled and archive.get_node("Actions").get_child_count() == 0, "closed dossier is read only")
	await _shot("closed")
	await _click(_conclusion(archive, "inv_d01"))
	_expect(archive.get_node("Detail").visible, "closed dossier still allows conclusion consult")
	await _click(console.navigation.buttons[&"calls"])
	await _click(calls.restart_button)
	await _click(console.navigation.buttons[&"evidence"])
	_expect(archive.cards.is_empty() and archive.deductions.get_confirmed().is_empty() and archive.selected_ids.is_empty(), "19 new investigation clears old presentation")
	await _click(console.navigation.buttons[&"calls"])
	calls.configure_development_storage(directory + "_failure", FailingSaves, Calls.INVESTIGATION_PATH)
	calls.controller.saves.fail_write_suffix = "slot_01.tmp"
	await _click(calls.start_button)
	await _click(calls.answer_button)
	await _click(_choice(calls, "inv_testimony"))
	await _click(console.navigation.buttons[&"evidence"])
	_expect(archive.get_node("RetrySave").is_visible_in_tree() and archive.cards.size() == 1, "write failure visible in archive without losing evidence")
	await _shot("save_error")
	before = archive.engine.get_state_snapshot()
	calls.controller.saves.fail_write_suffix = ""
	await _click(archive.get_node("RetrySave"))
	_expect(archive.engine.get_state_snapshot() == before and not archive.get_node("RetrySave").visible, "retry writes existing state without replay")
	_expect(app.main_menu.continue_button.disabled, "production continue unchanged")
	if failures.is_empty():
		print("PASS investigation_integration checks=", checks, " window=", root.size, " display=", DisplayServer.get_name())
	_finish()


func _choice(panel, id: String) -> Button:
	for button: Button in panel.options.get_children():
		if button.choice_id == id:
			return button
	return null


func _card_button(panel, id: String, name: String) -> Button:
	return panel.cards[id].get_node("Content/Actions/" + name)


func _category(panel, id: String) -> Button:
	return _metadata_button(panel.get_node("Filters"), "category", id)


func _action(panel, id: String) -> Button:
	return _metadata_button(panel.get_node("Actions"), "action_id", id)


func _conclusion(panel, id: String) -> Button:
	return _metadata_button(panel.get_node("Conclusions"), "deduction_id", id)


func _metadata_button(container: Node, field: String, id: String) -> Button:
	for button: Button in container.get_children():
		if button.get_meta(field, "") == id:
			return button
	return null


func _tap(button: Button) -> void:
	var parent: Node = button.get_parent()
	while parent != null:
		if parent is ScrollContainer:
			parent.ensure_control_visible(button)
		parent = parent.get_parent()
	await _settle()
	var activations: Array[int] = [0]
	var observer: Callable = func() -> void: activations[0] += 1
	button.pressed.connect(observer)
	var position: Vector2 = button.get_global_rect().get_center()
	for pressed: bool in [true, false]:
		var event: InputEventScreenTouch = InputEventScreenTouch.new()
		event.position = position
		event.pressed = pressed
		root.push_input(event, true)
	await _settle()
	button.pressed.disconnect(observer)
	_expect(activations[0] == 1, "viewport touch activates selection exactly once")


func _visible_text(parent: Node) -> String:
	var result: String = ""
	for child: Node in parent.find_children("*", "Label", true, false):
		if child.is_visible_in_tree():
			result += child.text + "\n"
	for child: Node in parent.find_children("*", "Button", true, false):
		if child.is_visible_in_tree():
			result += child.text + "\n"
	return result


func _shot(name: String) -> void:
	_stage = "capture " + name
	_validate_visible_controls()
	_expect(root.get_visible_rect().encloses(current_scene.console.navigation.get_global_rect()), "fixed navigation remains accessible")
	await _snapshot(name)
	_stage = "after " + name


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
