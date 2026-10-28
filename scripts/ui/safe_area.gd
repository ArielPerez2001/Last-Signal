extends MarginContainer


func _ready() -> void:
	get_viewport().size_changed.connect(_update_margins)
	_update_margins()


func _update_margins() -> void:
	var insets: Vector4 = Vector4.ZERO
	if OS.get_name() == "Android":
		var window: Window = get_window()
		var safe_rect: Rect2i = DisplayServer.get_display_safe_area()
		var window_rect: Rect2i = Rect2i(window.position, window.size)
		if safe_rect.has_area() and window_rect.has_area():
			var scale_factor: Vector2 = get_viewport_rect().size / Vector2(window.size)
			insets = Vector4(
				maxi(0, safe_rect.position.x - window_rect.position.x) * scale_factor.x,
				maxi(0, safe_rect.position.y - window_rect.position.y) * scale_factor.y,
				maxi(0, window_rect.end.x - safe_rect.end.x) * scale_factor.x,
				maxi(0, window_rect.end.y - safe_rect.end.y) * scale_factor.y
			)
	add_theme_constant_override("margin_left", 32 + ceili(insets.x))
	add_theme_constant_override("margin_top", 24 + ceili(insets.y))
	add_theme_constant_override("margin_right", 32 + ceili(insets.z))
	add_theme_constant_override("margin_bottom", 24 + ceili(insets.w))
