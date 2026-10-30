extends VBoxContainer

signal back_requested
const Guidance = preload("res://scripts/ui/case_guidance.gd")
const ExperienceScene = preload("res://scenes/screens/case_experience.tscn")
var experience: Control

var active_section: StringName = &"calls"
var _engine: RefCounted
var _scroll_positions: Dictionary = {}
var _previous_state: Dictionary = {}
var _last_node: String = ""
var _scroll_generation: int = 0
var _notice: String = ""
var _unread: Dictionary = {}

@onready var navigation: HBoxContainer = %BottomNavigation
@onready var content_scroll: ScrollContainer = %ContentScroll
@onready var panels: Dictionary[StringName, Control] = {
	&"calls": %CallsPanel,
	&"audio": %AudioPanel,
	&"map": %MapPanel,
	&"evidence": %EvidencePanel,
}


func _ready() -> void:
	experience = ExperienceScene.instantiate()
	add_child(experience)
	experience.visible = false
	experience.menu_requested.connect(back_requested.emit)
	%ConsoleHeader.get_node("Content/TopRow/MenuButton").pressed.connect(back_requested.emit)
	navigation.section_selected.connect(select_section)
	%CallsPanel.call_presentation_changed.connect(_update_call_status)
	%CallsPanel.controller_replaced.connect(_bind_investigation)
	%CallsPanel.section_requested.connect(func(section: StringName) -> void: select_section(section, true))
	%CallsPanel.menu_requested.connect(back_requested.emit)
	%MapPanel.report_received.connect(select_section.bind(&"calls"))
	%EvidencePanel.selection_changed.connect(_update_guidance)
	$Guidance/Action.pressed.connect(_follow_objective)
	$ActionDock/Buttons/Return.pressed.connect(%CallsPanel.return_to_conversation)
	$ActionDock/Buttons/Confirm.pressed.connect(%EvidencePanel._relate)
	move_child($Guidance, 1)
	_bind_investigation(%CallsPanel.controller)
	select_section(&"calls")


func open_console() -> void:
	if Guidance.active(_engine):
		experience._queue_render()
		return
	select_section(&"calls")
	navigation.buttons[&"calls"].grab_focus()


func select_section(section_id: StringName, reset_scroll: bool = false) -> void:
	if not panels.has(section_id):
		return
	if Guidance.active(_engine):
		if section_id == &"calls":
			experience.back_to_call()
		elif experience.director.unlocked({&"map": "dispatch", &"evidence": "archive"}.get(section_id, String(section_id))):
			experience._open({&"map": "dispatch", &"evidence": "archive"}.get(section_id, String(section_id)))
		experience._queue_render()
		return
	if Guidance.active(_engine) and section_id != &"calls" and _engine.get_state_snapshot().get("variables", {}).get("etapa", "A") in ["A", "B"]:
		return
	_scroll_positions[active_section] = content_scroll.scroll_vertical
	if reset_scroll:
		_scroll_positions[section_id] = 0
	active_section = section_id
	for panel_id: StringName in panels:
		panels[panel_id].visible = panel_id == section_id
	navigation.select_section(section_id)
	_unread.erase(section_id)
	_scroll_generation += 1
	_restore_section_scroll.call_deferred(_scroll_generation, int(_scroll_positions.get(section_id, 0)))
	_update_guidance()


func _restore_section_scroll(generation: int, value: int, frames: int = 2) -> void:
	if not is_inside_tree():
		return
	if frames > 0:
		get_tree().process_frame.connect(_restore_section_scroll.bind(generation, value, frames - 1), CONNECT_ONE_SHOT)
		return
	if generation == _scroll_generation:
		content_scroll.scroll_vertical = value


func _update_call_status(view: Dictionary) -> void:
	var labels: Dictionary = {"IDLE": "LÍNEA EN ESPERA", "INCOMING": "LLAMADA ENTRANTE", "CONNECTED": "LLAMADA ACTIVA", "ENDED": "COMUNICACIÓN FINALIZADA", "ERROR": "REVISAR COMUNICACIÓN"}
	%ConsoleHeader.get_node("Content/Status").text = "COMUNICACIONES · " + labels[view.state]
	var node: String = %CallsPanel.controller.engine.get_current_node().get("id", "")
	if node != _last_node:
		_last_node = node
		_scroll_positions[&"calls"] = 0
		if active_section == &"calls":
			content_scroll.set_deferred("scroll_vertical", 0)
	_update_guidance()


func _bind_investigation(controller: RefCounted) -> void:
	if _engine != null:
		_engine.state_changed.disconnect(_on_state)
		_engine.session_restored.disconnect(_on_restored)
		_engine.case_loaded.disconnect(_on_loaded)
	_engine = controller.engine
	_engine.state_changed.connect(_on_state)
	_engine.session_restored.connect(_on_restored)
	_engine.case_loaded.connect(_on_loaded)
	_on_loaded("")
	%EvidencePanel.bind_engine(controller.engine, controller.saves)
	%AudioPanel.bind_engine(controller.engine, controller.saves)
	%MapPanel.bind_engine(controller.engine, controller.saves)
	experience.bind_services(controller, %EvidencePanel.evidence, %EvidencePanel.deductions, %AudioPanel.manager, %MapPanel.dispatch, %MapPanel.map_manager)
	_update_guidance()


func _on_loaded(_id: String) -> void:
	_previous_state = {}
	_scroll_positions.clear()
	_unread.clear()
	_notice = ""
	_last_node = ""
	_update_guidance()


func _on_restored(snapshot: Dictionary) -> void:
	_previous_state = snapshot.duplicate(true)
	_unread.clear()
	_notice = "Partida recuperada. Puedes retomar la investigación."
	_update_guidance()


func _on_state(snapshot: Dictionary) -> void:
	if Guidance.active(_engine) and not _previous_state.is_empty() and snapshot.revision > _previous_state.revision:
		_notice = ""
		var new_evidence: Array = snapshot.evidence.filter(func(id: String) -> bool: return id not in _previous_state.evidence)
		if not new_evidence.is_empty():
			_notice = "Nueva evidencia registrada." if new_evidence.size() == 1 else "%d evidencias registradas." % new_evidence.size()
			_unread[&"evidence"] = true
		for definition: Dictionary in _engine.get_investigation_catalog().get("deductions", []):
			if definition.id in snapshot.executed_actions and definition.id not in _previous_state.executed_actions:
				_notice = "Deducción confirmada. Revisa el objetivo actual para continuar."
		var previous_ready: bool = "c001_q01" in _previous_state.executed_actions and "c001_e06" in _previous_state.evidence
		if not previous_ready and "c001_q01" in snapshot.executed_actions and "c001_e06" in snapshot.evidence:
			_notice = "Nueva respuesta disponible en Llamadas."
			_unread[&"calls"] = true
	_previous_state = snapshot.duplicate(true)
	_update_guidance()


func _follow_objective() -> void:
	var goal: Dictionary = Guidance.view(_engine)
	if goal.get("section") == &"calls":
		%CallsPanel.return_to_conversation()
	elif not goal.is_empty():
		select_section(goal.section)


func _update_guidance() -> void:
	if not is_node_ready() or _engine == null:
		return
	var guided: bool = Guidance.active(_engine)
	if is_instance_valid(experience):
		experience.visible = guided
	%ConsoleHeader.visible = not guided
	content_scroll.visible = not guided
	navigation.visible = not guided
	if guided:
		$Guidance.visible = false
		$ActionDock.visible = false
		return
	$Guidance.visible = guided
	%ConsoleHeader.get_node("Content/LocationRow").visible = not guided
	%ConsoleHeader.get_node("Content/Status").visible = not guided
	%ConsoleHeader.get_node("Content/TopRow/Station").text = "Puerto Umbral · 02:17\nLínea dos" if guided else "Central de\nEmergencias"
	var goal: Dictionary = Guidance.view(_engine)
	var tools_ready: bool = not guided or _engine.get_state_snapshot().get("variables", {}).get("etapa", "A") not in ["A", "B"]
	for section: StringName in navigation.buttons:
		navigation.buttons[section].disabled = guided and section != &"calls" and not tools_ready
		navigation.buttons[section].get_node("Content/ActiveMarker").text = "ACTIVA" if section == active_section else ("NUEVO" if _unread.has(section) else "")
	$Guidance/Action.visible = not goal.is_empty() and goal.section != active_section and not goal.action.is_empty()
	$Guidance/Objective.visible = not $Guidance/Action.visible
	$Guidance/Objective.text = goal.get("title", "") + " · " + goal.get("detail", "")
	$Guidance/Action.text = goal.get("title", "") + "\n" + goal.get("action", "")
	$Guidance/Notice.text = _notice
	$Guidance/Notice.visible = not _notice.is_empty()
	$ActionDock.visible = guided and active_section != &"calls"
	var relating: bool = guided and active_section == &"evidence" and not _engine.is_investigation_closed()
	$ActionDock/Selection.visible = relating
	$ActionDock/Buttons/Confirm.visible = relating
	var archive: Control = panels[&"evidence"]
	$ActionDock/Selection.text = "%d evidencias seleccionadas" % archive.selected_ids.size()
	if not archive.selected_hypothesis.is_empty():
		var picker: OptionButton = archive.get_node("HypothesisPicker")
		$ActionDock/Selection.text = picker.get_item_text(picker.selected) + " · %d seleccionadas" % archive.selected_ids.size()
	$ActionDock/Buttons/Confirm.disabled = archive.selected_hypothesis.is_empty() or archive.selected_ids.is_empty()
