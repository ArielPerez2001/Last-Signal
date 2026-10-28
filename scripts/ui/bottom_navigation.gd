extends HBoxContainer

signal section_selected(section_id: StringName)

@onready var buttons: Dictionary[StringName, Button] = {
	&"calls": $CallsButton,
	&"audio": $AudioButton,
	&"map": $MapButton,
	&"evidence": $EvidenceButton,
}


func _ready() -> void:
	for section_id: StringName in buttons:
		buttons[section_id].pressed.connect(_on_section_pressed.bind(section_id))
	select_section(&"calls")


func select_section(section_id: StringName) -> void:
	if not buttons.has(section_id):
		return
	for button_id: StringName in buttons:
		var button: Button = buttons[button_id]
		var selected: bool = button_id == section_id
		button.set_pressed_no_signal(selected)
		var marker: Label = button.get_node("Content/ActiveMarker") as Label
		marker.text = "ACTIVA" if selected else ""


func _on_section_pressed(section_id: StringName) -> void:
	section_selected.emit(section_id)
