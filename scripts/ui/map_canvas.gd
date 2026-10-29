extends Control

signal location_selected(id: String)
var map: Dictionary = {}
var locations: Array = []
var selected: String = ""


func configure(view: Dictionary, visible_locations: Array, selected_id: String) -> void:
	map = view.duplicate(true)
	locations = visible_locations.duplicate(true)
	selected = selected_id
	_rebuild()


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED and is_inside_tree():
		_rebuild()


func _rebuild() -> void:
	for child: Node in get_children():
		remove_child(child)
		child.queue_free()
	for index: int in range(locations.size()):
		var location: Dictionary = locations[index]
		var button: Button = Button.new()
		button.text = str(index + 1) + (" !" if location.has_active_incident else "")
		button.toggle_mode = true
		button.set_pressed_no_signal(selected == location.id)
		button.custom_minimum_size = Vector2(88, 88)
		button.size = Vector2(88, 88)
		button.set_meta("location_id", location.id)
		button.position = Vector2(clampf(location.position[0] * size.x - 44, 0, maxf(0, size.x - 88)), clampf(location.position[1] * size.y - 44, 0, maxf(0, size.y - 88)))
		button.pressed.connect(location_selected.emit.bind(location.id))
		add_child(button)
	queue_redraw()


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color("102421"))
	for district: Dictionary in map.get("districts", []):
		var b: Array = district.bounds
		var rect: Rect2 = Rect2(Vector2(b[0] * size.x, b[1] * size.y), Vector2(b[2] * size.x, b[3] * size.y))
		draw_rect(rect, Color("19352f"))
		draw_rect(rect, Color("426359"), false, 1)
		draw_string(get_theme_default_font(), rect.position + Vector2(8, 26), district.name, HORIZONTAL_ALIGNMENT_LEFT, rect.size.x - 16, 18, Color("a9bdb4"))
	# Static street/port schematic; no routes, GPS, traffic or live simulation.
	if map.get("layout_kind") == "building":
		draw_rect(Rect2(size * Vector2(0.22, 0.23), size * Vector2(0.56, 0.53)), Color("7f958b"), false, 3)
		draw_line(size * Vector2(0.22, 0.5), size * Vector2(0.78, 0.5), Color("426359"), 2)
		return
	draw_line(Vector2(size.x * 0.08, size.y * 0.48), Vector2(size.x * 0.92, size.y * 0.48), Color("658276"), 5)
	draw_line(Vector2(size.x * 0.49, size.y * 0.18), Vector2(size.x * 0.49, size.y * 0.93), Color("658276"), 4)
	for y: float in [0.68, 0.82, 0.93]:
		draw_line(Vector2(size.x * 0.86, size.y * y), Vector2(size.x * 0.98, size.y * y), Color("82988b"), 3)
