extends Button

signal choice_requested(choice_id: String, revision: int)
var choice_id: String = ""
var revision: int = -1

func _ready() -> void:
	pressed.connect(_request)

func configure(choice: Dictionary) -> void:
	choice_id = choice.id
	revision = choice.revision
	text = choice.text + ("\n" + choice.disabled_reason if not choice.enabled else "")
	disabled = not choice.enabled
	tooltip_text = choice.disabled_reason
	autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	text_overrun_behavior = TextServer.OVERRUN_NO_TRIMMING
	alignment = HORIZONTAL_ALIGNMENT_LEFT
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	custom_minimum_size.y = 88

func _request() -> void:
	if disabled:
		return
	disabled = true
	choice_requested.emit(choice_id, revision)
