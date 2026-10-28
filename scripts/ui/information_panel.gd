extends ScrollContainer

signal back_requested

@onready var title_label: Label = %InformationTitle
@onready var body_label: Label = %InformationBody
@onready var back_button: Button = %InformationBack


func _ready() -> void:
	back_button.pressed.connect(back_requested.emit)


func show_information(title: String, body: String) -> void:
	title_label.text = title
	body_label.text = body
	scroll_vertical = 0
	back_button.grab_focus()
