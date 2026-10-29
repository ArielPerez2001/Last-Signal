extends VBoxContainer

signal call_presentation_changed(view: Dictionary)
signal controller_replaced(controller: RefCounted)

const Controller = preload("res://scripts/systems/call_controller.gd")
const EntryScene = preload("res://scenes/components/calls/dialogue_entry.tscn")
const ChoiceScene = preload("res://scenes/components/calls/dialogue_choice.tscn")
const Lifecycle = preload("res://scripts/systems/save_lifecycle.gd")
var controller: RefCounted
var development_enabled: bool = OS.is_debug_build()
var _entries: Array = []
var _choice_signature: Array = []
var _input_locked: bool = false
var _scroll_generation: int = 0
var lifecycle: Node
var _demo_path: String = Controller.DEMO_PATH
var _storage_directory: String = Controller.DEMO_DIRECTORY

@onready var history_scroll: ScrollContainer = $History
@onready var choices_scroll: ScrollContainer = $Choices
@onready var options: VBoxContainer = $Choices/Options
@onready var answer_button: Button = $Answer
@onready var start_button: Button = $Development/Actions/Start
@onready var restore_button: Button = $Development/Actions/Restore
@onready var restart_button: Button = $Development/Actions/Restart


func _ready() -> void:
	configure_development_storage(Controller.DEMO_DIRECTORY)
	answer_button.pressed.connect(_answer)
	start_button.pressed.connect(_prepare)
	restore_button.pressed.connect(_restore)
	restart_button.pressed.connect(_restart)
	$Development/Actions/Investigation.pressed.connect(_prepare_investigation)
	$Development/Actions/Audio.pressed.connect(_prepare_audio)
	$Development/Actions/Dispatch.pressed.connect(_prepare_dispatch)
	$Retry.pressed.connect(func() -> void: controller.retry_save())


func configure_development_storage(directory: String, save_script: Script = null, case_path: String = Controller.DEMO_PATH) -> void:
	if controller != null:
		controller.dispose()
	controller = Controller.new(directory, save_script)
	_demo_path = case_path
	_storage_directory = directory
	controller.presentation_changed.connect(_render)
	if lifecycle == null:
		lifecycle = Lifecycle.new()
		add_child(lifecycle)
	lifecycle.save_manager = controller.saves
	_render(controller.get_view())
	controller_replaced.emit(controller)


func _exit_tree() -> void:
	if controller != null:
		controller.dispose()


func _input(event: InputEvent) -> void:
	if not is_visible_in_tree():
		return
	# Respect Godot's gesture classification across frames, without adding a
	# timer to the narrative. Same-turn repeats also use _input_locked.
	if (event is InputEventMouseButton and event.double_click) or (event is InputEventScreenTouch and event.double_tap):
		_lock_until_next_turn()


func set_development_enabled(enabled: bool) -> void:
	development_enabled = enabled and OS.is_debug_build()
	_render(controller.get_view())


func _prepare() -> void:
	if development_enabled:
		controller.prepare_call(_demo_path)


func _prepare_investigation() -> void:
	if development_enabled and controller.get_view().state in ["IDLE", "ERROR"] and controller.engine.get_state_snapshot().is_empty():
		var directory: String = _storage_directory + "_investigation" if _storage_directory.begins_with("user://save_tests/") else Controller.INVESTIGATION_DIRECTORY
		configure_development_storage(directory, null, Controller.INVESTIGATION_PATH)
		controller.prepare_call(_demo_path)


func _answer() -> void:
	if _input_locked:
		return
	answer_button.disabled = true
	controller.answer_call()
	_lock_until_next_turn()


func _prepare_dispatch() -> void:
	if development_enabled and controller.get_view().state in ["IDLE", "ERROR"] and controller.engine.get_state_snapshot().is_empty():
		var directory: String = _storage_directory + "_dispatch" if _storage_directory.begins_with("user://save_tests/") else Controller.DISPATCH_DIRECTORY
		configure_development_storage(directory, null, Controller.DISPATCH_PATH)
		controller.prepare_call(_demo_path)


func _prepare_audio() -> void:
	if development_enabled and controller.get_view().state in ["IDLE", "ERROR"] and controller.engine.get_state_snapshot().is_empty():
		var directory: String = _storage_directory + "_audio" if _storage_directory.begins_with("user://save_tests/") else Controller.AUDIO_DIRECTORY
		configure_development_storage(directory, null, Controller.AUDIO_PATH)
		controller.prepare_call(_demo_path)


func _restore() -> void:
	if development_enabled and not _input_locked:
		controller.restore_call(_demo_path)
		_lock_until_next_turn()


func _restart() -> void:
	if development_enabled and not _input_locked:
		controller.restart_demo()
		_lock_until_next_turn()


func _choose(choice_id: String, revision: int) -> void:
	if _input_locked:
		return
	for option: Button in options.get_children():
		option.disabled = true
	controller.select_choice(choice_id, revision)
	_lock_until_next_turn()


func _lock_until_next_turn() -> void:
	_input_locked = true
	call_deferred("_unlock")


func _unlock() -> void:
	_input_locked = false
	_render(controller.get_view())


func _render(view: Dictionary) -> void:
	var active: bool = view.state in ["CONNECTED", "ENDED"]
	$Caller.text = view.caller if view.state != "IDLE" else "Línea en espera"
	var states: Dictionary = {"IDLE": "SIN LLAMADA ACTIVA", "INCOMING": "● LLAMADA ENTRANTE", "CONNECTED": "● COMUNICACIÓN ACTIVA", "ENDED": "COMUNICACIÓN FINALIZADA", "ERROR": "COMUNICACIÓN NO DISPONIBLE"}
	$Connection.text = states[view.state]
	$Message.text = view.message
	if not view.error.is_empty():
		$Message.text += "\nPrueba técnica · " + view.error.code
	answer_button.visible = view.state == "INCOMING"
	answer_button.disabled = view.busy or _input_locked
	$TranscriptHeading.visible = active
	history_scroll.visible = active
	$ChoicesHeading.visible = view.state == "CONNECTED"
	choices_scroll.visible = view.state == "CONNECTED"
	$Development.visible = development_enabled
	start_button.visible = view.state in ["IDLE", "ERROR"] and controller.engine.get_state_snapshot().is_empty()
	$Development/Actions/Investigation.visible = start_button.visible
	$Development/Actions/Audio.visible = start_button.visible
	$Development/Actions/Dispatch.visible = start_button.visible
	restart_button.visible = not start_button.visible
	$Retry.visible = not view.error.is_empty() and controller.saves.get_status().data.dirty and active
	_update_history(view.history)
	_update_choices(view.choices)
	if $Retry.visible:
		$Development.visible = false
	call_presentation_changed.emit(view.duplicate(true))


func _update_history(history: Array) -> void:
	if history == _entries:
		return
	var scrollbar: VScrollBar = history_scroll.get_v_scroll_bar()
	var following: bool = _entries.is_empty() or scrollbar.value + scrollbar.page >= scrollbar.max_value - 24
	var old_scroll: int = history_scroll.scroll_vertical
	var prefix: bool = history.size() >= _entries.size() and history.slice(0, _entries.size()) == _entries
	if not prefix:
		for child: Node in $History/Entries.get_children():
			child.free()
		_entries = []
		following = true
	for index: int in range(_entries.size(), history.size()):
		var line: Dictionary = history[index]
		var entry: VBoxContainer = EntryScene.instantiate()
		entry.set_meta("entry_id", line.id)
		entry.get_node("Speaker").text = "%02d · %s" % [index + 1, line.speaker.to_upper()]
		entry.get_node("Speaker").theme_type_variation = &"AccentLabel" if line.kind == "choice" else &"SignalLabel"
		entry.get_node("Text").text = line.text
		$History/Entries.add_child(entry)
	_entries = history.duplicate(true)
	_scroll_generation += 1
	_restore_scroll.call_deferred(_scroll_generation, following, old_scroll)


func _restore_scroll(generation: int, following: bool, old_scroll: int) -> void:
	await get_tree().process_frame
	await get_tree().process_frame
	if generation != _scroll_generation:
		return
	if following and $History/Entries.get_child_count() > 0:
		history_scroll.scroll_vertical = int($History/Entries.get_child(-1).position.y)
	else:
		history_scroll.scroll_vertical = old_scroll


func _update_choices(choices: Array) -> void:
	if choices != _choice_signature:
		for child: Node in options.get_children():
			child.queue_free()
			options.remove_child(child)
		for choice: Dictionary in choices:
			var button: Button = ChoiceScene.instantiate()
			button.configure(choice)
			button.choice_requested.connect(_choose)
			options.add_child(button)
		_choice_signature = choices.duplicate(true)
		choices_scroll.scroll_vertical = 0
	for index: int in range(choices.size()):
		options.get_child(index).disabled = _input_locked or not choices[index].enabled
