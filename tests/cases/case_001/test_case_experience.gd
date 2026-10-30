extends "res://tests/navigation_smoke.gd"

const Calls = preload("res://scripts/systems/call_controller.gd")
const Failing = preload("res://tests/save/failing_save_manager.gd")
var app: Control
var experience: Control
var calls_panel: Control
var checks: int = 0
var directory: String
var route_metrics: Array = []
var pointer_steps: Array = []
var route_start: int = 0


func _expect(condition: bool, description: String) -> void:
	checks += 1
	super._expect(condition, description)
	if not condition:
		push_error(description)


func _run() -> void:
	if not await _prepare_main():
		_finish()
		return
	app = current_scene
	directory = "user://save_tests/experience_%d_%d" % [OS.get_process_id(), Time.get_ticks_usec()]
	app.official_directory = directory
	_bind_ui()
	for ending: String in ["A", "B", "C"]:
		route_start = pointer_steps.size()
		await _new_route(ending)
		if not failures.is_empty(): _finish(); return
		await _initial(ending == "C")
		if ending == "A":
			await _shot("first_deduction")
			var before: Dictionary = calls_panel.controller.engine.get_state_snapshot()
			await intent("answer:prank")
			_expect(calls_panel.controller.engine.get_state_snapshot() == before, "wrong conclusion has no story effects")
			await _shot("deduction_feedback")
			await intent("hint")
			await intent("more_hint"); await intent("more_hint")
			_expect(calls_panel.controller.engine.get_state_snapshot() == before, "all three hint levels pure and no timer")
			await _shot("help")
			await intent("help_back")
		await intent("answer:contradiction")
		_expect("c001_q01" in calls_panel.controller.engine.get_state_snapshot().executed_actions, "first deduction confirmed by service")
		await intent("return")
		if ending == "A":
			await intent("audio")
			_expect(experience.transcript.is_empty(), "opening audio does not grant the transcript observation")
			await intent("read")
			_expect("c001_e03" in calls_panel.controller.engine.get_state_snapshot().evidence and experience.transcript.contains("Bomberos"), "one explicit consultation records approved audio evidence")
			await _shot("transcript")
			await intent("recordings")
			await intent("segment:c001_g01_s01")
			_expect(experience.transcript.contains("Mirador"), "optional segment can be reread without filters")
			await intent("return")
		await intent("inspect")
		var before_dispatch: Dictionary = calls_panel.controller.engine.get_state_snapshot()
		var incident: String = "c001_i02" if ending == "A" else "c001_i01"
		await intent("access:" + incident)
		_expect(before_dispatch == calls_panel.controller.engine.get_state_snapshot(), "choosing access is a pure preview")
		if ending == "A":
			await _shot("dispatch_confirmation")
			await intent("dispatch_cancel")
			_expect(before_dispatch == calls_panel.controller.engine.get_state_snapshot(), "cancel preserves resource and narrative")
			await intent("access:" + incident)
		await intent("dispatch_confirm")
		_expect(calls_panel.controller.engine.get_state_snapshot().variables.r1_status == "ASSIGNED", "explicit confirmation sends R1")
		if ending == "A":
			await _cold_restore()
			_expect(calls_panel.controller.engine.get_state_snapshot().variables.r1_status == "ASSIGNED", "continue preserves assigned unit without arrival")
			_expect("dispatch" in calls_panel.controller.saves.get_tutorials_seen(), "dispatch tutorial survives cold menu")
			await _shot("continued")
			await intent("report")
			await intent("map")
			await _shot("optional_map")
		var event: String = "c001_u02" if ending == "A" else "c001_u01"
		await intent("event:" + event)
		_expect("c001_e06" in calls_panel.controller.engine.get_state_snapshot().evidence, "part records exterior evidence")
		await intent("c001_n20_o01" if ending == "A" else "c001_n19_o01")
		if ending == "A":
			await intent("danger")
			await _shot("subsequent_deduction")
			await intent("answer:separate_route")
			_expect("c001_q02" in calls_panel.controller.engine.get_state_snapshot().executed_actions, "interpretation remains explicit, tutorial does not select it")
			await _shot("conclusion")
			await intent("return")
		await intent("c001_n10_o09")
		await intent("c001_n21_o02" if ending == "C" else "c001_n21_o01")
		if ending == "A": await _shot("date")
		await intent("c001_n22_o01")
		_expect(calls_panel.controller.engine.get_current_node().id == "c001_n24", "preparation skips redundant handoff and retains Clara request")
		if ending == "A":
			await _shot("critical")
			var before: Dictionary = calls_panel.controller.engine.get_state_snapshot()
			await _click(experience.get_node("Secondary/Archive"))
			await intent("all_sources")
			await _shot("archive")
			await intent("history")
			await _shot("history")
			await _key(KEY_ESCAPE)
			_expect(experience.mode == "archive", "system back leaves history before leaving attention")
			await intent("return")
			_expect(before == calls_panel.controller.engine.get_state_snapshot(), "optional exploration never cancels plan or advances danger")
		await intent("c001_n24_o03" if ending == "A" else ("c001_n24_o02" if ending == "B" else "c001_n24_o04"))
		if ending == "A":
			var prepared: Dictionary = calls_panel.controller.engine.get_state_snapshot()
			await _shot("prepared_instruction")
			await _click(experience.get_node("Secondary/Archive"))
			await intent("dispatch")
			await intent("return")
			_expect(prepared == calls_panel.controller.engine.get_state_snapshot(), "exploration preserves prepared plan")
			await intent("c001_n25_o02")
			_expect(calls_panel.controller.engine.get_current_node().id == "c001_n24", "explicit correction still available")
			await intent("c001_n24_o03")
		if ending == "C":
			await _shot("risk_warning")
			await intent("c001_n26_o02")
		await intent("c001_n25_o01")
		_expect(calls_panel.controller.engine.get_state_snapshot().variables.resultado == ending, "actual UI reaches " + ending)
		await _shot("ending_" + ending.to_lower())
		for index: int in range(4):
			var node: String = calls_panel.controller.engine.get_current_node().id
			await intent(node + "_o01")
		_expect(calls_panel.controller.engine.get_current_node().id == "c001_n37", "basic closure remains")
		await intent("c001_n37_o01")
		route_metrics.append({"ending":ending,"mouse_activations":pointer_steps.size() - route_start,"includes_optional_qa_detours":ending == "A","replacement_dialog_acknowledged_by_signal":ending != "A","steps":pointer_steps.slice(route_start)})
		_expect(app.current_screen == &"menu", "final action returns to menu")
		print("EXPERIENCE ROUTE ", ending, " PASS")
	# Controlled write failure, never the official production directory.
	var errors_directory: String = directory + "_errors"
	calls_panel.configure_development_storage(errors_directory, Failing, Calls.OFFICIAL_PATH)
	calls_panel.controller.saves.fail_write_suffix = "slot_01.tmp"
	_expect(calls_panel.controller.prepare_call(Calls.OFFICIAL_PATH).ok, "error scenario starts isolated")
	app._show_screen(&"console")
	await _settle()
	await _shot("save_error")
	_expect(not calls_panel.controller.get_view().error.is_empty(), "save failure visible")
	calls_panel.controller.saves.fail_write_suffix = ""
	await intent("retry")
	_expect(calls_panel.controller.get_view().error.is_empty(), "retry recovers same session")
	var metrics_path: String = OS.get_environment("TEMP").path_join("ultima_senal_11r_gui_" + str(root.size.x) + "x" + str(root.size.y) + ".json")
	var file := FileAccess.open(metrics_path, FileAccess.WRITE)
	file.store_string(JSON.stringify(route_metrics, "  "))
	file.close()
	if user_arguments.size() > 1:
		file = FileAccess.open(user_arguments[1].path_join("ui_route_metrics.json"), FileAccess.WRITE)
		file.store_string(JSON.stringify(route_metrics, "  "))
		file.close()
	print("CASE001 EXPERIENCE PASS checks=", checks, " window=", root.size, " renderer=", DisplayServer.get_name())
	_finish()


func _bind_ui() -> void:
	calls_panel = app.console.panels[&"calls"]
	experience = app.console.experience


func _click(button: Button) -> void:
	var before: Dictionary = {"intent":String(button.get_meta("intent", button.name)),"mode":experience.mode if experience != null else "menu","node":calls_panel.controller.engine.get_current_node().get("id", "") if calls_panel != null else ""}
	await super._click(button)
	before["mode_after"] = experience.mode if experience != null else "menu"
	before["node_after"] = calls_panel.controller.engine.get_current_node().get("id", "") if calls_panel != null else ""
	pointer_steps.append(before)


func _new_route(ending: String) -> void:
	var previous: Dictionary = calls_panel.controller.engine.get_state_snapshot()
	await _click(app.main_menu.get_node("Content/Actions/NewGame"))
	if app._confirmation.visible:
		_expect(previous == calls_panel.controller.engine.get_state_snapshot(), "replacement dialog never starts a new game itself")
		if ending == "B":
			app._confirmation.hide()
			app._confirmation.canceled.emit()
			_expect(previous == calls_panel.controller.engine.get_state_snapshot(), "cancel replacement preserves completed session")
			app.request_new_game()
		# Native desktop dialog is acknowledged through its real public signal;
		# the campaign below uses pointer events. This is not a physical touch test.
		app._confirmation.hide()
		app._confirmation.confirmed.emit()
	await _settle()
	_expect(app.current_screen == &"console" and experience.is_visible_in_tree(), "official experience visible " + ending)
	_expect(not app.console.navigation.is_visible_in_tree(), "no four-tab bar in official case")
	_expect(experience.get_node("Scroll").size.y >= root.get_visible_rect().size.y * 0.65, "content occupies at least 65 percent of portrait")
	if ending == "A": await _shot("incoming")


func _initial(hostile: bool) -> void:
	await intent("c001_n01_o01")
	_expect(calls_panel.controller.engine.get_current_node().id == "c001_n03", "attend once")
	_expect(experience.body.get_children().filter(func(item: Node) -> bool: return item is Button).size() == 2, "first conversation offers two meaningful responses")
	await intent("c001_n03_o02" if hostile else "c001_n03_o01")
	await intent("c001_n04_o01")
	await intent("c001_n05_o01")
	_expect(calls_panel.controller.engine.get_current_node().id == "c001_n08", "one verification action opens actual record")
	if not hostile: await _shot("record")
	await intent("c001_n08_o01")
	_expect(experience.mode == "reason", "contextual first deduction opens directly")


func intent(id: String) -> void:
	await _settle()
	var found: Button
	for item: Node in experience.body.get_children():
		if item is Button and item.get_meta("intent", "") == id:
			found = item
	_expect(found != null, "visible intent " + id + " in " + experience.mode + " at " + str(calls_panel.controller.engine.get_current_node().get("id")))
	if found != null:
		await _click(found)
		_expect(failures.is_empty(), "interaction completed " + id)


func _cold_restore() -> void:
	_expect(calls_panel.controller.retry_save().ok, "checkpoint before cold restore")
	var before: Dictionary = calls_panel.controller.engine.get_state_snapshot()
	var seen: Array = calls_panel.controller.saves.get_tutorials_seen()
	root.remove_child(app)
	app.free()
	app = load("res://scenes/core/main.tscn").instantiate()
	root.add_child(app)
	current_scene = app
	app.official_directory = directory
	app.refresh_official_save()
	_bind_ui()
	await _settle()
	_expect(not app.main_menu.continue_button.disabled, "cold menu offers exact compatible save")
	await _click(app.main_menu.continue_button)
	_expect(calls_panel.controller.engine.get_state_snapshot() == before, "cold Continue restores exact story")
	_expect(calls_panel.controller.saves.get_tutorials_seen() == seen, "cold Continue restores seen lessons")


func _shot(label: String) -> void:
	await _settle()
	_validate_visible_controls()
	if user_arguments.size() > 1:
		_expect(DirAccess.make_dir_recursive_absolute(user_arguments[1]) == OK, "capture directory")
		experience.get_node("Scroll").scroll_vertical = 0
		await _settle()
		await _capture(user_arguments[1].path_join(label + ".png"))
