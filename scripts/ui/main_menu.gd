extends ScrollContainer

signal enter_requested
signal settings_requested
signal credits_requested

@onready var enter_button: Button = %EnterButton
@onready var continue_button: Button = %ContinueButton
@onready var settings_button: Button = %SettingsButton
@onready var credits_button: Button = %CreditsButton


func _ready() -> void:
	enter_button.pressed.connect(enter_requested.emit)
	settings_button.pressed.connect(settings_requested.emit)
	credits_button.pressed.connect(credits_requested.emit)
	continue_button.disabled = true
	continue_button.focus_mode = Control.FOCUS_NONE
	var available_buttons: Array[Button] = [enter_button, settings_button, credits_button]
	for button_index: int in range(available_buttons.size()):
		var button: Button = available_buttons[button_index]
		var next_button: Button = available_buttons[(button_index + 1) % available_buttons.size()]
		var previous_button: Button = available_buttons[(button_index + available_buttons.size() - 1) % available_buttons.size()]
		button.focus_next = button.get_path_to(next_button)
		button.focus_previous = button.get_path_to(previous_button)
		button.focus_neighbor_bottom = button.focus_next
		button.focus_neighbor_top = button.focus_previous


func focus_primary() -> void:
	enter_button.grab_focus()
