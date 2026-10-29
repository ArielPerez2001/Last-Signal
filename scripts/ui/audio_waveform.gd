extends Control

signal seek_requested(ratio: float)
var peaks: Array = []
var progress: float = 0.0
var selection: Vector2 = Vector2(-1, -1)


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color("172d29"))
	if selection.x >= 0:
		draw_rect(Rect2(Vector2(size.x * selection.x, 0), Vector2(size.x * (selection.y - selection.x), size.y)), Color("345b50"))
	for index: int in range(peaks.size()):
		var x: float = (index + 0.5) * size.x / peaks.size()
		var half: float = float(peaks[index]) * size.y * 0.46
		draw_line(Vector2(x, size.y / 2 - half), Vector2(x, size.y / 2 + half), Color("78c7a6"), 2.0)
	draw_line(Vector2(size.x * progress, 0), Vector2(size.x * progress, size.y), Color("e1b35e"), 3.0)


func _gui_input(event: InputEvent) -> void:
	if (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed) or (event is InputEventScreenTouch and event.pressed):
		seek_requested.emit(clampf(event.position.x / maxf(1, size.x), 0, 1))
		accept_event()
