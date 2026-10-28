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
