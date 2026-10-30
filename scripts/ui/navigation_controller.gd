extends Control

var current_screen: StringName = &"menu"
var menu_return_button: Button
const Controller = preload("res://scripts/systems/call_controller.gd")
var official_directory: String = Controller.OFFICIAL_DIRECTORY
var _confirmation: ConfirmationDialog

@onready var main_menu: ScrollContainer = $SafeArea/MainMenu
@onready var console: VBoxContainer = $SafeArea/DispatchConsole
@onready var information: ScrollContainer = $SafeArea/InformationPanel


func _ready() -> void:
	get_tree().quit_on_go_back = false
	main_menu.enter_requested.connect(_open_console)
	main_menu.settings_requested.connect(_open_settings)
	main_menu.credits_requested.connect(_open_credits)
	main_menu.new_game_requested.connect(request_new_game)
	main_menu.continue_requested.connect(continue_game)
	_confirmation = ConfirmationDialog.new()
	_confirmation.title = "Sustituir partida"
	_confirmation.dialog_text = "¿Reemplazar el progreso del Caso 001? Solo se sustituirá al confirmar."
	_confirmation.ok_button_text = "Reemplazar partida"
	_confirmation.cancel_button_text = "Conservar progreso"
	_confirmation.get_ok_button().custom_minimum_size.y = 88
	_confirmation.get_cancel_button().custom_minimum_size.y = 88
	_confirmation.confirmed.connect(_start_new_game)
	add_child(_confirmation)
	console.back_requested.connect(_open_menu)
	information.back_requested.connect(_open_menu)
	_open_menu()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and not event.is_echo():
		go_back()
		get_viewport().set_input_as_handled()


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_GO_BACK_REQUEST and is_node_ready():
		go_back()


func go_back() -> void:
	if current_screen == &"console" and console.experience.visible and console.experience.mode != "call":
		console.experience.go_back()
		console.experience._queue_render()
		return
	if current_screen != &"menu":
		_open_menu()


func _open_menu() -> void:
	if is_instance_valid(console):
		var calls: Control = console.panels[&"calls"]
		if calls.controller.get_view().case_id == "c001" and calls.controller.saves.get_status().data.dirty:
			if not calls.controller.retry_save().ok:
				return
	refresh_official_save()
	_show_screen(&"menu")
	if is_instance_valid(menu_return_button):
		menu_return_button.grab_focus()
	else:
		main_menu.focus_primary()


func _open_console() -> void:
	var calls: Control = console.panels[&"calls"]
	if calls.controller.get_view().case_id == "c001":
		var saved: Dictionary = calls.controller.retry_save()
		if not saved.ok:
			main_menu.set_save_status(false, saved.message)
			return
		calls.development_enabled = OS.is_debug_build()
		calls.configure_development_storage(Controller.DEMO_DIRECTORY)
	menu_return_button = main_menu.enter_button
	_show_screen(&"console")
	console.open_console()


func _inspect_official() -> Dictionary:
	var inspector = Controller.new(official_directory)
	if not inspector.engine.load_case(Controller.OFFICIAL_PATH):
		inspector.dispose()
		return {"ok": false, "data": {"valid": false}, "message": "No se pudo validar el contenido del caso."}
	var result: Dictionary = inspector.saves.get_save_metadata()
	inspector.dispose()
	return result


func refresh_official_save() -> void:
	if not is_instance_valid(main_menu):
		return
	var inspected: Dictionary = _inspect_official()
	var available: bool = inspected.ok and inspected.data.get("valid", false)
	var exists: bool = inspected.data.get("exists", false) or inspected.data.get("backup_exists", false)
	main_menu.set_save_status(available, "Partida del Caso 001 disponible" if available else ("No se puede continuar esta partida. Los archivos se conservan." if exists else "Aún no hay una partida guardada"))


func request_new_game() -> void:
	var inspected: Dictionary = _inspect_official()
	var calls: Control = console.panels[&"calls"]
	var live: bool = calls.controller.get_view().case_id == "c001"
	if live or inspected.data.get("exists", false) or inspected.data.get("backup_exists", false):
		_confirmation.popup_centered(Vector2i(560, 300))
	else:
		_start_new_game()


func _start_new_game() -> void:
	var calls: Control = console.panels[&"calls"]
	# The confirmation authorizes replacing only the official fixed slot.
	var replacement = Controller.new(official_directory)
	var deleted: Dictionary = replacement.saves.delete_save(true)
	replacement.dispose()
	if not deleted.ok:
		main_menu.set_save_status(false, deleted.message)
		return
	calls.configure_official(official_directory)
	var prepared: Dictionary = calls.controller.prepare_call(Controller.OFFICIAL_PATH)
	if not prepared.ok:
		main_menu.set_save_status(false, prepared.message)
		return
	_show_screen(&"console")
	console.open_console()


func continue_game() -> void:
	var calls: Control = console.panels[&"calls"]
	# Reopen a live official session without discarding unflushed progress.
	if calls.controller.get_view().case_id == "c001" and not calls.controller.engine.get_state_snapshot().is_empty():
		_show_screen(&"console")
		console.open_console()
		return
	calls.configure_official(official_directory)
	var recovered: Dictionary = calls.controller.restore_call(Controller.OFFICIAL_PATH)
	if not recovered.ok:
		main_menu.set_save_status(false, recovered.message)
		return
	_show_screen(&"console")
	console.open_console()


func _open_settings() -> void:
	menu_return_button = main_menu.settings_button
	_show_screen(&"settings")
	information.show_information("Configuración", "Prototipo de interfaz\nGodot 4.7.2 · Español\n\nLas preferencias de sonido, lectura y presentación todavía no están disponibles.\n\nEsta versión no guarda ajustes.")


func _open_credits() -> void:
	menu_return_button = main_menu.credits_button
	_show_screen(&"credits")
	information.show_information("Créditos", "ÚLTIMA SEÑAL\n\nThriller narrativo de investigación y misterio.\n\nLa información de autoría todavía no está registrada en los créditos del proyecto.")


func _show_screen(screen_id: StringName) -> void:
	current_screen = screen_id
	main_menu.visible = screen_id == &"menu"
	console.visible = screen_id == &"console"
	information.visible = screen_id in [&"settings", &"credits"]
