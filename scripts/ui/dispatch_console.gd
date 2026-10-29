extends VBoxContainer

signal back_requested

var active_section: StringName = &"calls"

@onready var navigation: HBoxContainer = %BottomNavigation
@onready var content_scroll: ScrollContainer = %ContentScroll
@onready var panels: Dictionary[StringName, Control] = {
	&"calls": %CallsPanel,
	&"audio": %AudioPanel,
	&"map": %MapPanel,
	&"evidence": %EvidencePanel,
}


func _ready() -> void:
	%ConsoleHeader.get_node("Content/TopRow/MenuButton").pressed.connect(back_requested.emit)
	navigation.section_selected.connect(select_section)
	%CallsPanel.call_presentation_changed.connect(_update_call_status)
	%CallsPanel.controller_replaced.connect(_bind_investigation)
	_bind_investigation(%CallsPanel.controller)
	select_section(&"calls")


func open_console() -> void:
	select_section(&"calls")
	navigation.buttons[&"calls"].grab_focus()


func select_section(section_id: StringName) -> void:
	if not panels.has(section_id):
		return
	active_section = section_id
	for panel_id: StringName in panels:
		panels[panel_id].visible = panel_id == section_id
	navigation.select_section(section_id)
	content_scroll.scroll_vertical = 0


func _update_call_status(view: Dictionary) -> void:
	var labels: Dictionary = {"IDLE": "LÍNEA EN ESPERA", "INCOMING": "LLAMADA ENTRANTE", "CONNECTED": "LLAMADA ACTIVA", "ENDED": "COMUNICACIÓN FINALIZADA", "ERROR": "REVISAR COMUNICACIÓN"}
	%ConsoleHeader.get_node("Content/Status").text = "COMUNICACIONES · " + labels[view.state]


func _bind_investigation(controller: RefCounted) -> void:
	%EvidencePanel.bind_engine(controller.engine, controller.saves)
	%AudioPanel.bind_engine(controller.engine, controller.saves)
	%MapPanel.bind_engine(controller.engine, controller.saves)
