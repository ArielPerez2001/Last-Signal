extends Control

var current_screen: StringName = &"menu"
var menu_return_button: Button

@onready var main_menu: ScrollContainer = $SafeArea/MainMenu
@onready var console: VBoxContainer = $SafeArea/DispatchConsole
@onready var information: ScrollContainer = $SafeArea/InformationPanel


func _ready() -> void:
	get_tree().quit_on_go_back = false
	main_menu.enter_requested.connect(_open_console)
	main_menu.settings_requested.connect(_open_settings)
	main_menu.credits_requested.connect(_open_credits)
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
	if current_screen != &"menu":
		_open_menu()


func _open_menu() -> void:
	_show_screen(&"menu")
	if is_instance_valid(menu_return_button):
		menu_return_button.grab_focus()
	else:
		main_menu.focus_primary()


func _open_console() -> void:
	menu_return_button = main_menu.enter_button
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
