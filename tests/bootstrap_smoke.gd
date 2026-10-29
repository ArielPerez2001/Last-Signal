extends SceneTree


var failures: Array[String] = []
var user_arguments: PackedStringArray
var expected_window_size: Vector2i = Vector2i(720, 1280)


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	if not await _prepare_main():
		_finish()
		return
	_validate_menu()
	if user_arguments.size() > 1:
		await _capture(user_arguments[1])
	print("BOOTSTRAP viewport=", root.get_visible_rect().size, " window=", root.size, " display=", DisplayServer.get_name())
	_finish()


func _prepare_main() -> bool:
	user_arguments = OS.get_cmdline_user_args()
	if not user_arguments.is_empty():
		var dimensions: PackedStringArray = user_arguments[0].split("x")
		_expect(dimensions.size() == 2, "resolution argument has width and height")
		if dimensions.size() != 2:
			return false
		expected_window_size = Vector2i(dimensions[0].to_int(), dimensions[1].to_int())
	_expect(expected_window_size.x > 0 and expected_window_size.y > 0, "resolution is positive")
	if not failures.is_empty():
		return false
	root.size = expected_window_size
	var expected_settings: Dictionary = {
		"application/run/main_scene": "res://scenes/core/main.tscn",
		"display/window/size/viewport_width": 720,
		"display/window/size/viewport_height": 1280,
		"display/window/stretch/mode": "canvas_items",
		"display/window/stretch/aspect": "expand",
		"display/window/handheld/orientation": DisplayServer.SCREEN_PORTRAIT,
		"rendering/renderer/rendering_method": "gl_compatibility",
		"rendering/renderer/rendering_method.mobile": "gl_compatibility",
		"internationalization/locale/fallback": "es",
	}
	for setting_name: String in expected_settings:
		_expect(ProjectSettings.get_setting(setting_name) == expected_settings[setting_name], setting_name)
	var scene_error: Error = change_scene_to_file(expected_settings["application/run/main_scene"])
	_expect(scene_error == OK, "main scene loads")
	if scene_error != OK:
		return false
	await _settle()
	current_scene.official_directory = "user://save_tests/menu_%d_%d" % [OS.get_process_id(), Time.get_ticks_usec()]
	current_scene.refresh_official_save()
	_expect(current_scene is Control, "main is Control")
	_expect(current_scene.theme != null, "shared theme assigned")
	var scale_factor: float = minf(expected_window_size.x / 720.0, expected_window_size.y / 1280.0)
	var expected_visible_size: Vector2 = Vector2(expected_window_size) / scale_factor
	_expect(root.size == expected_window_size, "requested window resolution is effective")
	_expect(root.get_visible_rect().size.is_equal_approx(expected_visible_size), "expanded canvas size")
	return failures.is_empty()


func _validate_menu() -> void:
	_expect(current_scene.current_screen == &"menu", "main menu is entry screen")
	var main_menu: ScrollContainer = current_scene.main_menu
	_expect(main_menu.continue_button.disabled, "continue is unavailable")
	_expect(main_menu.get_node("Content/Branding/Title").text == "ÚLTIMA SEÑAL", "project identity")
	_validate_visible_controls()


func _validate_visible_controls() -> void:
	var visible_area: Rect2 = root.get_visible_rect().grow(1)
	for node: Node in current_scene.find_children("*", "Control", true, false):
		var control: Control = node as Control
		if not control.is_visible_in_tree():
			continue
		_expect(control.get_global_rect().position.x >= -1, "left overflow: " + str(control.get_path()))
		_expect(control.get_global_rect().end.x <= visible_area.end.x + 1, "right overflow: " + str(control.get_path()))
		if control is BaseButton:
			_expect(control.size.y >= 88, "comfortable button height: " + str(control.get_path()))
		if control is ScrollContainer:
			var scrollbar: HScrollBar = control.get_h_scroll_bar()
			_expect(scrollbar.max_value <= scrollbar.page + 1, "no horizontal scroll: " + str(control.get_path()))


func _capture(file_path: String) -> void:
	_expect(DisplayServer.get_name() != "headless", "capture requires graphical renderer")
	if DisplayServer.get_name() == "headless":
		return
	# An occluded desktop window may stop emitting frame_post_draw. Request
	# a real renderer frame explicitly instead of waiting indefinitely for it.
	await process_frame
	RenderingServer.force_draw(false)
	var screenshot: Image = root.get_texture().get_image()
	_expect(not screenshot.is_empty(), "rendered image is not empty")
	if not screenshot.is_empty():
		_expect(screenshot.get_size() == expected_window_size, "capture has requested resolution")
		_expect(screenshot.save_png(file_path) == OK, "screenshot saved")


func _settle() -> void:
	for frame_index: int in range(5):
		await process_frame


func _expect(condition: bool, description: String) -> void:
	if not condition:
		failures.append(description)


func _finish() -> void:
	if failures.is_empty():
		print("PASS ", "navigation_smoke" if get_script().resource_path.ends_with("navigation_smoke.gd") else "bootstrap_smoke")
		quit(0)
	else:
		for failure: String in failures:
			push_error("FAIL " + failure)
		quit(1)
