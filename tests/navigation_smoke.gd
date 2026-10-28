extends "res://tests/bootstrap_smoke.gd"


func _run() -> void:
	if not await _prepare_main():
		_finish()
		return
	_validate_menu()
	var app: Control = current_scene
	var menu: ScrollContainer = app.main_menu
	var console: VBoxContainer = app.console
	var information: ScrollContainer = app.information
	var original_node_count: int = app.find_children("*", "", true, false).size()
	await _snapshot("menu")
	await _key(KEY_TAB)
	_expect(menu.settings_button.has_focus(), "keyboard skips disabled continue")
	await _key(KEY_TAB)
	_expect(menu.credits_button.has_focus(), "keyboard reaches credits")
	await _key(KEY_TAB)
	_expect(menu.enter_button.has_focus(), "keyboard focus cycles within menu")
	await _click(menu.continue_button)
	_expect(app.current_screen == &"menu", "disabled continue does not navigate")
	await _click(menu.settings_button)
	_expect(app.current_screen == &"settings", "settings opens")
	_expect(information.title_label.text == "Configuración", "settings content")
	_validate_visible_controls()
	await _snapshot("settings")
	information.body_label.text = "Comprobación de desplazamiento vertical.\n".repeat(40)
	await _settle()
	_expect(information.get_v_scroll_bar().max_value > information.get_v_scroll_bar().page, "long information scrolls vertically")
	await _click(information.back_button)
	_expect(app.current_screen == &"menu", "settings closes")
	_expect(menu.settings_button.has_focus(), "settings focus restored")
	await _click(menu.settings_button)
	await _key(KEY_ESCAPE)
	_expect(app.current_screen == &"menu", "escape closes secondary screen first")
	await _click(menu.credits_button)
	_expect(app.current_screen == &"credits", "credits opens")
	_expect(information.body_label.text.contains("autoría todavía no está registrada"), "no invented authors")
	await _snapshot("credits")
	app.notification(Node.NOTIFICATION_WM_GO_BACK_REQUEST)
	await _settle()
	_expect(app.current_screen == &"menu", "system back closes credits")
	await _click(menu.enter_button)
	_expect(app.current_screen == &"console", "enter opens console")
	_expect(console.active_section == &"calls", "console defaults to calls")
	_expect(console.get_node("ConsoleHeader/Content/LocationRow/Time").text == "02:17 AM", "time is narrative and static")
	var section_ids: Array[StringName] = [&"calls", &"audio", &"map", &"evidence"]
	for section_id: StringName in section_ids:
		await _click(console.navigation.buttons[section_id])
		_validate_section(console, section_id)
		_validate_visible_controls()
		await _snapshot(String(section_id))
	for repetition: int in range(8):
		for section_id: StringName in section_ids:
			await _click(console.navigation.buttons[section_id])
			_validate_section(console, section_id)
	_expect(app.find_children("*", "", true, false).size() == original_node_count, "repeated navigation does not duplicate instances")
	await _click(console.get_node("ConsoleHeader/Content/TopRow/MenuButton"))
	_expect(app.current_screen == &"menu", "visible menu button works")
	_expect(menu.enter_button.has_focus(), "entry focus restored")
	await _key(KEY_ENTER)
	_expect(app.current_screen == &"console", "keyboard activates focused entry")
	_expect(console.active_section == &"calls", "reentry resets to calls")
	await _key(KEY_RIGHT)
	_expect(console.navigation.buttons[&"audio"].has_focus(), "arrow moves tab focus")
	await _key(KEY_ENTER)
	_validate_section(console, &"audio")
	await _key(KEY_ESCAPE)
	_expect(app.current_screen == &"menu", "escape returns to menu")
	await _touch(menu.enter_button)
	_expect(app.current_screen == &"console", "touch enters console")
	await _touch(console.navigation.buttons[&"map"])
	_validate_section(console, &"map")
	app.notification(Node.NOTIFICATION_WM_GO_BACK_REQUEST)
	await _settle()
	_expect(app.current_screen == &"menu", "system back returns without quitting")
	app.notification(Node.NOTIFICATION_WM_GO_BACK_REQUEST)
	_expect(app.current_screen == &"menu", "system back at menu is safe")
	_expect(not quit_on_go_back, "automatic back quit disabled")
	_expect(app.find_children("*", "", true, false).size() == original_node_count, "complete flow preserves instances")
	print("NAVIGATION window=", root.size, " nodes=", original_node_count, " display=", DisplayServer.get_name())
	_finish()


func _validate_section(console: VBoxContainer, section_id: StringName) -> void:
	_expect(console.active_section == section_id, "active section: " + String(section_id) + " actual=" + String(console.active_section) + " screen=" + String(current_scene.current_screen))
	_expect(console.navigation.is_visible_in_tree(), "navigation remains visible")
	_expect(root.get_visible_rect().encloses(console.navigation.get_global_rect()), "navigation is within viewport")
	for panel_id: StringName in console.panels:
		_expect(console.panels[panel_id].is_visible_in_tree() == (panel_id == section_id), "single visible section")
		var button: Button = console.navigation.buttons[panel_id]
		_expect(button.button_pressed == (panel_id == section_id), "pressed tab matches section")
		var marker: Label = button.get_node("Content/ActiveMarker") as Label
		_expect((marker.text == "ACTIVA") == (panel_id == section_id), "active marker is explicit")


func _click(button: Button) -> void:
	var parent: Node = button.get_parent()
	while parent != null:
		if parent is ScrollContainer:
			parent.ensure_control_visible(button)
		parent = parent.get_parent()
	await _settle()
	var position: Vector2 = button.get_global_rect().get_center()
	var motion: InputEventMouseMotion = InputEventMouseMotion.new()
	motion.position = position
	motion.global_position = position
	root.push_input(motion, true)
	for pressed: bool in [true, false]:
		var event: InputEventMouseButton = InputEventMouseButton.new()
		event.button_index = MOUSE_BUTTON_LEFT
		event.position = position
		event.global_position = position
		event.pressed = pressed
		root.push_input(event, true)
	await _settle()


func _key(keycode: Key) -> void:
	for pressed: bool in [true, false]:
		var event: InputEventKey = InputEventKey.new()
		event.keycode = keycode
		event.pressed = pressed
		root.push_input(event, true)
		await process_frame
	await _settle()


func _touch(button: Button) -> void:
	await _settle()
	var position: Vector2 = root.get_final_transform() * button.get_global_rect().get_center()
	for pressed: bool in [true, false]:
		var event: InputEventScreenTouch = InputEventScreenTouch.new()
		event.index = 0
		event.position = position
		event.pressed = pressed
		Input.parse_input_event(event)
	await _settle()


func _snapshot(view_name: String) -> void:
	if user_arguments.size() > 1:
		var destination: String = user_arguments[1]
		_expect(DirAccess.make_dir_recursive_absolute(destination) == OK, "capture directory")
		await _capture(destination.path_join(view_name + ".png"))
