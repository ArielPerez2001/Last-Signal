extends VBoxContainer

const Map = preload("res://scripts/systems/map_manager.gd")
const Dispatch = preload("res://scripts/systems/dispatch_manager.gd")
const LABELS: Dictionary = {"AVAILABLE": "Disponible", "ASSIGNED": "Asignado", "BUSY": "En intervención", "UNAVAILABLE": "Fuera de servicio", "ACTIVE": "Activo", "REPORTED": "Comunicado · sin despacho habilitado", "RESOLVED": "Resuelto", "CLOSED": "Cerrado", "PATROL": "Patrulla", "AMBULANCE": "Ambulancia", "LOW": "Baja", "MEDIUM": "Media", "HIGH": "Alta"}
var map_manager: RefCounted
var dispatch: RefCounted
var engine: RefCounted
var saves: RefCounted
var location_id: String = ""
var incident_id: String = ""
var unit_id: String = ""
var pending: Dictionary = {}
var last_result: Dictionary = {}
var _queued: bool = false


func _ready() -> void:
	$Canvas.location_selected.connect(_select_location)
	$Review.pressed.connect(_review)
	$Confirmation/Confirm.pressed.connect(_confirm)
	$Confirmation/Cancel.pressed.connect(func() -> void:
		pending = {}
		$Confirmation.visible = false
	)
	$Retry.pressed.connect(func() -> void: saves.flush_pending_save())
	_refresh()


func bind_engine(narrative: RefCounted, save_service: RefCounted) -> void:
	_disconnect()
	engine = narrative
	saves = save_service
	map_manager = Map.new(engine)
	dispatch = Dispatch.new(engine)
	engine.state_changed.connect(_changed)
	engine.case_loaded.connect(_reset)
	engine.session_restored.connect(_reset)
	saves.operation_completed.connect(_on_save)
	_reset(null)


func _exit_tree() -> void:
	_disconnect()


func _disconnect() -> void:
	if engine != null:
		engine.state_changed.disconnect(_changed)
		engine.case_loaded.disconnect(_reset)
		engine.session_restored.disconnect(_reset)
		saves.operation_completed.disconnect(_on_save)
	engine = null
	saves = null


func _reset(_value: Variant) -> void:
	location_id = ""
	incident_id = ""
	unit_id = ""
	pending = {}
	last_result = {}
	$SaveNotice.visible = false
	$Retry.visible = false
	_changed(null)


func _changed(_value: Variant) -> void:
	if not _queued:
		_queued = true
		call_deferred("_refresh")


func _refresh() -> void:
	_queued = false
	if not is_inside_tree():
		return
	var map: Dictionary = {} if map_manager == null else map_manager.get_map()
	var locations: Array = [] if map.is_empty() else map_manager.get_visible_locations()
	$Title.text = map.get("title", "Sin mapa operativo activo")
	$Canvas.visible = not map.is_empty()
	$Canvas.configure(map, locations, location_id)
	$Notice.text = "No hay incidentes conocidos." if map.is_empty() or dispatch.get_incidents().is_empty() else "Plano de ensayo · ! indica incidente activo/asignado. Toque un marcador o use la lista. Los partes avanzan solo al solicitarlos."
	if engine != null and engine.is_case_finished():
		$Notice.text = "Operaciones cerradas · consulta del estado registrado. No se admiten nuevas asignaciones ni partes."
	_clear($Locations)
	for index: int in range(locations.size()):
		var item: Dictionary = locations[index]
		_add($Locations, "%d · %s%s" % [index + 1, item.name, " · seleccionada" if item.id == location_id else ""], _select_location.bind(item.id), "location_id", item.id)
	var detail: Dictionary = {} if map.is_empty() else map_manager.get_location(location_id).data
	$Location.text = "Seleccione una ubicación conocida." if detail.is_empty() else detail.name + " · " + detail.district_name + "\n" + detail.description + "\n" + "\n".join(detail.information)
	_clear($Incidents)
	var incidents: Array = [] if map.is_empty() else dispatch.get_incidents()
	for item: Dictionary in incidents:
		if item.location_id == location_id:
			_add($Incidents, item.title + " · " + LABELS[item.status] + " · Prioridad " + LABELS[item.priority], _select_incident.bind(item.id), "incident_id", item.id)
	var incident: Dictionary = {} if map.is_empty() else dispatch.get_incident(incident_id).data
	$Incident.text = "Seleccione un incidente conocido." if incident.is_empty() else incident.title + "\n" + incident.description + "\nEstado: " + LABELS[incident.status]
	_clear($Units)
	for item: Dictionary in ([] if map.is_empty() else dispatch.get_units()):
		var text: String = item.display_name + "\n" + LABELS[item.status] + (" · seleccionada" if item.unit_id == unit_id else "")
		_add($Units, text, _select_unit.bind(item.unit_id), "unit_id", item.unit_id)
	$Review.disabled = incident.is_empty() or unit_id.is_empty() or engine == null or engine.is_case_finished()
	$Confirmation.visible = not pending.is_empty()
	$Feedback.text = last_result.get("message", "")
	$Feedback.visible = not $Feedback.text.is_empty()
	_clear($Events)
	if not map.is_empty():
		for event: Dictionary in dispatch.get_available_events():
			_add($Events, event.label, _event.bind(event), "event_id", event.id)
	$EventsHeading.visible = $Events.get_child_count() > 0


func _select_location(id: String) -> void:
	if map_manager.get_location(id).ok:
		location_id = id
		incident_id = ""
		pending = {}
		_refresh()


func _select_incident(id: String) -> void:
	var item: Dictionary = dispatch.get_incident(id)
	if item.ok and item.data.location_id == location_id:
		incident_id = id
		pending = {}
		_refresh()


func _select_unit(id: String) -> void:
	if dispatch.get_unit_status(id).ok:
		unit_id = id
		pending = {}
		_refresh()


func _review() -> void:
	last_result = dispatch.can_dispatch(unit_id, incident_id)
	if last_result.ok and last_result.code == "VALID":
		pending = {"unit_id": unit_id, "incident_id": incident_id, "revision": engine.get_state_snapshot().revision}
		$Confirmation/Text.text = "Confirmar asignación\n" + dispatch.get_incident(incident_id).data.title + "\n" + map_manager.get_location(location_id).data.name + "\n" + dispatch.get_unit_status(unit_id).data.display_name + "\nLa unidad dejará de estar disponible hasta completar su intervención y liberación."
	_refresh()


func _confirm() -> void:
	if pending.is_empty():
		return
	var request: Dictionary = pending.duplicate()
	pending = {}
	last_result = dispatch.dispatch_unit(request.unit_id, request.incident_id, request.revision)
	_refresh()


func _event(event: Dictionary) -> void:
	last_result = dispatch.process_event(event.id, event.unit_id, event.incident_id, event.revision)
	_refresh()


func _on_save(result: Dictionary) -> void:
	if not result.ok:
		$SaveNotice.text = "No se pudo guardar o recuperar. El estado operativo actual sigue en memoria."
		$SaveNotice.visible = true
		$Retry.visible = engine != null and not engine.get_state_snapshot().is_empty()
	elif result.code in ["saved", "loaded", "restored_backup"]:
		$SaveNotice.visible = false
		$Retry.visible = false


func _add(container: Node, text: String, callback: Callable, field: String, id: String) -> void:
	var button: Button = Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(0, 88)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	button.text_overrun_behavior = TextServer.OVERRUN_NO_TRIMMING
	button.set_meta(field, id)
	button.pressed.connect(callback)
	container.add_child(button)


func _clear(container: Node) -> void:
	for child: Node in container.get_children():
		container.remove_child(child)
		child.queue_free()
