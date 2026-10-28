extends VBoxContainer

@export var heading: String = ""
@export var state_text: String = ""
@export var preview_text: String = ""
@export var availability_text: String = ""
@export var module_icon: Texture2D


func _ready() -> void:
	%ModuleHeading.text = heading
	%ModuleState.text = state_text
	%PreviewText.text = preview_text
	%Availability.text = availability_text
	%ModuleIcon.texture = module_icon
