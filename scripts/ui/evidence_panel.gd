extends VBoxContainer

const Evidence = preload("res://scripts/systems/evidence_manager.gd")
const Deductions = preload("res://scripts/systems/deduction_manager.gd")
const CardScene = preload("res://scenes/components/evidence/evidence_card.tscn")
const MAX_SELECTED: int = 2
var engine: RefCounted
var evidence: RefCounted
var deductions: RefCounted
var save_manager: RefCounted
var selected_ids: Array[String] = []
var category: String = ""
var result: Dictionary = {}
var cards: Dictionary = {}
var _detail_id: String = ""
var _detail_is_conclusion: bool = false
var _pending_refresh: bool = false
var _last_revision: int = 0


func _ready() -> void:
	$Relate.pressed.connect(_relate)
	$Detail/Back.pressed.connect(_close_detail)
	$RetrySave.pressed.connect(_retry_save)
	_refresh()


func bind_engine(new_engine: RefCounted, saves: RefCounted = null) -> void:
	_disconnect()
	engine = new_engine
	evidence = Evidence.new(engine)
	deductions = Deductions.new(engine)
	save_manager = saves
	if save_manager != null:
		save_manager.operation_completed.connect(_on_save_result)
	engine.state_changed.connect(_on_state_changed)
	engine.case_loaded.connect(_on_case_loaded)
	engine.session_restored.connect(_on_restored)
	evidence.evidence_discovered.connect(_on_discovered)
	_clear_presentation()
	_refresh()


func _exit_tree() -> void:
	_disconnect()


func _disconnect() -> void:
	if engine == null:
		return
	engine.state_changed.disconnect(_on_state_changed)
	engine.case_loaded.disconnect(_on_case_loaded)
	engine.session_restored.disconnect(_on_restored)
	evidence.evidence_discovered.disconnect(_on_discovered)
	evidence.dispose()
	if save_manager != null:
		save_manager.operation_completed.disconnect(_on_save_result)
	save_manager = null
	engine = null


func _clear_presentation() -> void:
	selected_ids.clear()
	category = ""
	result = {}
	_detail_id = ""
	_last_revision = 0
	$SaveNotice.text = ""
	$SaveNotice.visible = false
	$RetrySave.visible = false


func _on_case_loaded(_case_id: String) -> void:
	_clear_presentation()
	_request_refresh()


func _on_restored(_snapshot: Dictionary) -> void:
	_clear_presentation()
	_request_refresh()


func _on_state_changed(snapshot: Dictionary) -> void:
	if snapshot.revision < _last_revision:
		_clear_presentation()
	_last_revision = snapshot.revision
	_request_refresh()


func _on_discovered(_id: String) -> void:
	_request_refresh()


func _request_refresh() -> void:
	if not _pending_refresh:
		_pending_refresh = true
		call_deferred("_refresh")


func _refresh() -> void:
	_pending_refresh = false
	if not is_inside_tree():
		return
	var catalog: Dictionary = {} if engine == null else engine.get_investigation_catalog()
	var records: Array = [] if evidence == null else evidence.get_discovered()
	var conclusions: Array = [] if deductions == null else deductions.get_confirmed()
	$CaseTitle.text = catalog.get("title", "Sin expediente activo")
	$Summary.text = "Evidencias: %d · Deducciones: %d" % [records.size(), conclusions.size()]
	var closed: bool = engine != null and engine.is_case_finished()
	$Notice.text = "Expediente cerrado · consulta de evidencias y conclusiones." if closed else ("Todavía no se han registrado evidencias. Examine las comunicaciones disponibles." if records.is_empty() else "Consulte las fuentes y seleccione dos evidencias distintas para relacionarlas.")
	if catalog.is_empty() and engine != null and not engine.get_case_metadata().is_empty():
		$Notice.text = "El contenido activo no define un expediente consultable."
	var available_ids: Array = records.map(func(record: Dictionary) -> String: return record.id)
	selected_ids.assign(selected_ids.filter(func(id: String) -> bool: return id in available_ids))
	if not _detail_is_conclusion and not _detail_id.is_empty() and _detail_id not in available_ids:
		_detail_id = ""
	_rebuild_filters()
	_rebuild_cards()
	_rebuild_conclusions(conclusions)
	_rebuild_actions()
	_update_selection()
	$Feedback.text = result.get("message", "")
	$Feedback.visible = not $Feedback.text.is_empty()
	_show_detail()


func _rebuild_filters() -> void:
	_clear_children($Filters)
	if evidence == null or evidence.get_discovered().is_empty():
		return
	var filters: Array = [{"id": "", "title": "Todas"}] + evidence.get_categories()
	if not filters.any(func(filter: Dictionary) -> bool: return filter.id == category):
		category = ""
	for filter: Dictionary in filters:
		var button: Button = _button(filter.title + (" · activa" if filter.id == category else ""))
		button.set_meta("category", filter.id)
		button.pressed.connect(_set_category.bind(filter.id))
		$Filters.add_child(button)


func _rebuild_cards() -> void:
	_clear_children($Cards)
	cards.clear()
	if evidence == null:
		return
	for record: Dictionary in evidence.get_discovered(category):
		var card: PanelContainer = CardScene.instantiate()
		card.set_meta("evidence_id", record.id)
		card.get_node("Content/Title").text = record.title
		card.get_node("Content/Category").text = record.category_label
		card.get_node("Content/Actions/Detail").pressed.connect(_open_detail.bind(record.id, false))
		card.get_node("Content/Actions/Select").pressed.connect(_toggle_selection.bind(record.id))
		$Cards.add_child(card)
		cards[record.id] = card


func _rebuild_conclusions(conclusions: Array) -> void:
	_clear_children($Conclusions)
	for conclusion: Dictionary in conclusions:
		var button: Button = _button(conclusion.title + " · confirmada")
		button.set_meta("deduction_id", conclusion.id)
		button.pressed.connect(_open_detail.bind(conclusion.id, true))
		$Conclusions.add_child(button)
	$ConclusionsHeading.visible = not conclusions.is_empty()


func _rebuild_actions() -> void:
	_clear_children($Actions)
	var actions: Array = [] if evidence == null else evidence.get_available_actions()
	for action: Dictionary in actions:
		var button: Button = _button(action.title)
		button.disabled = not action.enabled
		button.set_meta("action_id", action.id)
		button.pressed.connect(_discover.bind(action.id, action.revision))
		$Actions.add_child(button)
	$ActionsHeading.visible = not actions.is_empty()


func _set_category(id: String) -> void:
	category = id
	_refresh()


func _toggle_selection(id: String) -> void:
	if evidence == null or not evidence.get_detail(id).ok or engine.is_case_finished():
		return
	if id in selected_ids:
		selected_ids.erase(id)
		result = {}
	elif selected_ids.size() < MAX_SELECTED:
		selected_ids.append(id)
		result = {}
	else:
		result = {"message": "Quite una selección antes de añadir otra evidencia."}
		$Feedback.text = result.message
		$Feedback.visible = true
	if result.is_empty():
		$Feedback.text = ""
		$Feedback.visible = false
	_update_selection()


func _update_selection() -> void:
	var titles: PackedStringArray = []
	for id: String in selected_ids:
		titles.append(evidence.get_detail(id).data.title)
	$Selection.text = "Selección: " + ("ninguna" if titles.is_empty() else "; ".join(titles))
	$Relate.disabled = selected_ids.size() != MAX_SELECTED or engine == null or engine.is_case_finished()
	for id: String in cards:
		var button: Button = cards[id].get_node("Content/Actions/Select")
		button.text = "✓ Seleccionada · quitar" if id in selected_ids else "Seleccionar"
		button.disabled = engine.is_case_finished()


func _relate() -> void:
	if deductions == null or selected_ids.size() != MAX_SELECTED:
		return
	$Relate.disabled = true
	result = deductions.relate(selected_ids, engine.get_state_snapshot().revision)
	$Feedback.text = result.message
	$Feedback.visible = true
	if result.code in ["INVALID", "STALE", "BUSY"] and OS.is_debug_build():
		print("INVESTIGATION_DIAGNOSTIC ", JSON.stringify(result))
	_request_refresh()


func _discover(id: String, revision: int) -> void:
	result = evidence.discover_from_action(id, revision)
	_request_refresh()


func _on_save_result(report: Dictionary) -> void:
	if not report.ok:
		$SaveNotice.text = "No se pudo guardar o recuperar el progreso. La sesión actual sigue en memoria."
		$SaveNotice.visible = true
		$RetrySave.visible = engine != null and not engine.get_state_snapshot().is_empty()
	elif report.code in ["saved", "loaded", "restored_backup"]:
		$SaveNotice.text = ""
		$SaveNotice.visible = false
		$RetrySave.visible = false


func _retry_save() -> void:
	if save_manager != null:
		save_manager.flush_pending_save()


func _open_detail(id: String, conclusion: bool) -> void:
	_detail_id = id
	_detail_is_conclusion = conclusion
	_show_detail()
	_focus_detail()


func _close_detail() -> void:
	_detail_id = ""
	_show_detail()


func _show_detail() -> void:
	$Detail.visible = not _detail_id.is_empty()
	$Cards.visible = _detail_id.is_empty()
	$Filters.visible = _detail_id.is_empty()
	if _detail_id.is_empty():
		return
	var data: Dictionary = {}
	if _detail_is_conclusion:
		for conclusion: Dictionary in deductions.get_confirmed():
			if conclusion.id == _detail_id:
				data = conclusion
	else:
		data = evidence.get_detail(_detail_id).data
	if data.is_empty():
		_detail_id = ""
		_show_detail()
		return
	$Detail/Title.text = data.title
	$Detail/Description.text = data.description
	$Detail/Image.visible = false
	$Detail/Image.texture = null
	if _detail_is_conclusion:
		var titles: PackedStringArray = []
		for id: String in data.required_evidence:
			titles.append(evidence.get_detail(id).data.title)
		$Detail/Source.text = "Fundamento: " + "; ".join(titles) + "\n" + data.narrative_feedback
	else:
		$Detail/Source.text = "Procedencia: " + data.source
		if data.asset_available:
			$Detail/Image.texture = load(data.related_asset) as Texture2D
			$Detail/Image.visible = $Detail/Image.texture != null


func _focus_detail() -> void:
	$Detail/Back.grab_focus()
	var parent: Node = get_parent()
	while parent != null:
		if parent is ScrollContainer:
			parent.ensure_control_visible($Detail/Back)
		parent = parent.get_parent()


func _button(text: String) -> Button:
	var button: Button = Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(168, 88)
	button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	button.text_overrun_behavior = TextServer.OVERRUN_NO_TRIMMING
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return button


func _clear_children(container: Node) -> void:
	for child: Node in container.get_children():
		container.remove_child(child)
		child.queue_free()
