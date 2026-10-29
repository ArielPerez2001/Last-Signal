extends VBoxContainer

const Analysis = preload("res://scripts/systems/audio_analysis_manager.gd")
const Playback = preload("res://scripts/systems/audio_playback_controller.gd")
const Catalog = preload("res://scripts/systems/audio_catalog_validator.gd")
const Guidance = preload("res://scripts/ui/case_guidance.gd")
var manager: RefCounted
var playback: Node
var saves: RefCounted
var _queued: bool = false
var _dragging: bool = false
var _touch_index: int = -1
var last_result: Dictionary = {}
var _displayed_record: Dictionary = {}
var _read_context: String = ""


func _ready() -> void:
	playback = Playback.new()
	add_child(playback)
	playback.progressed.connect(_on_progress)
	playback.playback_error.connect(_show_result)
	$Player/Transport/Play.pressed.connect(func() -> void: _show_result(playback.play()))
	$Player/Transport/Pause.pressed.connect(func() -> void: playback.pause())
	$Player/Transport/Stop.pressed.connect(func() -> void: playback.stop())
	$Player/Transport/Replay.pressed.connect(func() -> void: _show_result(playback.replay()))
	$Player/Transport/Full.pressed.connect(func() -> void: _show_result(playback.play_full()))
	$Player/Register.pressed.connect(func() -> void: _show_result(manager.register_observation()))
	$Player/ReadText.pressed.connect(_read_fragment)
	$Player/Capture.pressed.connect(func() -> void: _show_result({"ok": true, "message": "\n".join(_displayed_record.get("capture_information", []))}))
	$Player/Progress.drag_started.connect(func() -> void: _dragging = true)
	$Player/Progress.drag_ended.connect(func(_changed: bool) -> void:
		_dragging = false
		playback.seek($Player/Progress.value)
	)
	$Player/Progress.value_changed.connect(func(value: float) -> void:
		if not _dragging:
			playback.seek(value)
	)
	$Player/Progress.gui_input.connect(_on_slider_input)
	$Player/Wave.seek_requested.connect(func(ratio: float) -> void: playback.seek(ratio * playback.get_view().duration))
	$RetrySave.pressed.connect(func() -> void:
		if saves != null:
			saves.flush_pending_save()
	)
	visibility_changed.connect(_on_visibility)
	_refresh()


func bind_engine(engine: RefCounted, save_service: RefCounted) -> void:
	_disconnect()
	playback.clear()
	saves = save_service
	saves.operation_completed.connect(_on_save)
	manager = Analysis.new(engine, playback)
	manager.changed.connect(_request_refresh)
	last_result = {}
	_read_context = ""
	$Feedback.visible = false
	$SaveNotice.visible = false
	$RetrySave.visible = false
	_refresh()


func _disconnect() -> void:
	if manager != null:
		manager.changed.disconnect(_request_refresh)
		manager.dispose()
		manager = null
	if saves != null:
		saves.operation_completed.disconnect(_on_save)
		saves = null


func _exit_tree() -> void:
	_disconnect()


func _request_refresh() -> void:
	if not _queued:
		_queued = true
		call_deferred("_refresh")


func _refresh() -> void:
	_queued = false
	if not is_inside_tree():
		return
	_clear($Recordings)
	var records: Array = [] if manager == null else manager.get_recordings()
	$Empty.visible = records.is_empty()
	for record: Dictionary in records:
		var button: Button = _button("%s\n%s · %d observaciones registradas" % [record.title, _time(record.duration), record.confirmed])
		button.set_meta("recording_id", record.recording_id)
		button.pressed.connect(_select_recording.bind(record.recording_id))
		$Recordings.add_child(button)
	var view: Dictionary = playback.get_view()
	var record: Dictionary = {} if manager == null else manager.get_recording(view.recording_id).data
	_displayed_record = record
	$Player.visible = not record.is_empty()
	$Status.text = "Sin grabación seleccionada" if record.is_empty() else _state_text(view)
	if record.is_empty():
		return
	$Player/Title.text = record.title
	$Player/Description.text = record.description
	$Player/Capture.visible = not record.capture_information.is_empty()
	$Player/Wave.peaks = record.waveform
	$Player/WaveNote.text = "Onda de amplitud precalculada del archivo Original. Toque para buscar." if not record.waveform.is_empty() else "Sin datos de amplitud precalculados. Use el control temporal."
	$Player/Progress.max_value = record.duration
	_clear($Player/Filters)
	for variant: Dictionary in record.variants:
		var text: String = variant.label + (" · activo" if variant.filter_id == view.filter_id else "")
		if Guidance.active(manager.engine) and variant.filter_id == "voces":
			text = "Voces" + (" · activo" if variant.filter_id == view.filter_id else "")
		if not variant.available and not (Guidance.active(manager.engine) and variant.text_only):
			text += "\n" + variant.reason
		var button: Button = _button(text)
		button.disabled = not variant.available and not variant.text_only
		button.set_meta("filter_id", variant.filter_id)
		button.pressed.connect(_select_filter.bind(variant.filter_id))
		$Player/Filters.add_child(button)
	_clear($Player/Segments)
	for segment: Dictionary in record.segments:
		var button: Button = _button(segment.title + (" · seleccionado" if segment.segment_id == view.segment_id else "") + ("\nSeleccionar intervalo textual" if view.state == "TEXT" else "\nReproducir intervalo"))
		button.set_meta("segment_id", segment.segment_id)
		button.pressed.connect(_select_segment.bind(segment.segment_id))
		$Player/Segments.add_child(button)
	$Player/Accessible.text = "INFORMACIÓN SONORA EQUIVALENTE\n" + manager.get_accessible_information()
	var observations: Array = manager.get_observations()
	$Player/Observation.text = "No hay una observación preparada para esta combinación. Explore los intervalos y las mezclas." if observations.is_empty() else observations[0].title
	$Player/Register.disabled = manager.engine.is_case_finished() or view.state in ["ERROR", "EMPTY"]
	$Player/ReadText.visible = view.state == "TEXT"
	var textual: bool = Guidance.active(manager.engine) and view.state == "TEXT"
	for control: String in ["Wave", "WaveNote", "Progress", "Time", "Transport", "Observation", "Register"]:
		get_node("Player/" + control).visible = not textual
	if textual:
		$Player/Description.text = "Audio pendiente de producción. Puedes investigar mediante sus transcripciones."
		$Player/ReadText.text = "Fragmento leído" if _read_context == _context_key() else "Leer fragmento"
		$Player/ReadText.disabled = view.segment_id.is_empty() or _read_context == _context_key()
		if _read_context != _context_key():
			$Player/Accessible.text = "Selecciona un fragmento y una variante, y pulsa «Leer fragmento» para examinarlo."
	$Player/Transport/Pause.disabled = view.state != "PLAYING"
	for name: String in ["Play", "Replay", "Full", "Stop"]:
		get_node("Player/Transport/" + name).disabled = view.state in ["ERROR", "EMPTY", "TEXT"]
	_on_progress(view)


func _on_progress(view: Dictionary) -> void:
	if not is_inside_tree():
		return
	if not _dragging:
		$Player/Progress.set_value_no_signal(view.position)
	$Player/Time.text = "%s / %s · %s" % [_time(view.position), _time(view.duration), "Grabación completa" if view.segment_id.is_empty() else "Modo segmento"]
	$Player/Wave.progress = view.position / maxf(0.001, view.duration)
	$Player/Wave.selection = Vector2(-1, -1)
	if manager != null:
		var segment: Dictionary = Catalog.find_segment(_displayed_record, view.segment_id)
		if not segment.is_empty():
			$Player/Wave.selection = Vector2(segment.start_time / view.duration, segment.end_time / view.duration)
	$Player/Wave.queue_redraw()


func _on_slider_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed and _touch_index == -1:
			_touch_index = event.index
			_dragging = true
		if event.index == _touch_index:
			$Player/Progress.set_value_no_signal(clampf(event.position.x / maxf(1, $Player/Progress.size.x), 0, 1) * $Player/Progress.max_value)
			if not event.pressed:
				_touch_index = -1
				_dragging = false
				playback.seek($Player/Progress.value)
			$Player/Progress.accept_event()
	elif event is InputEventScreenDrag and event.index == _touch_index:
		$Player/Progress.set_value_no_signal(clampf(event.position.x / maxf(1, $Player/Progress.size.x), 0, 1) * $Player/Progress.max_value)
		$Player/Progress.accept_event()


func _select_recording(id: String) -> void:
	_show_result(manager.select_recording(id))


func _context_key() -> String:
	var view: Dictionary = playback.get_view()
	return view.recording_id + ":" + view.filter_id + ":" + view.segment_id


func _read_fragment() -> void:
	var result: Dictionary = manager.consult_selected()
	if result.ok:
		_read_context = _context_key()
	_show_result(result)
	if result.ok and Guidance.active(manager.engine):
		_focus_reading.call_deferred()


func _focus_reading(frames: int = 2) -> void:
	if not is_inside_tree():
		return
	if frames > 0:
		var callback: Callable = _focus_reading.bind(frames - 1)
		if not get_tree().process_frame.is_connected(callback):
			get_tree().process_frame.connect(callback, CONNECT_ONE_SHOT)
		return
	if not is_visible_in_tree():
		return
	var ancestor: Node = get_parent()
	while ancestor != null:
		if ancestor is ScrollContainer:
			ancestor.ensure_control_visible($Player/ReadText)
		ancestor = ancestor.get_parent()


func _select_filter(id: String) -> void:
	_show_result(manager.set_filter(id))


func _select_segment(id: String) -> void:
	_show_result(manager.play_segment(id))
	if not is_visible_in_tree():
		playback.pause()


func _show_result(result: Dictionary) -> void:
	last_result = result.duplicate(true)
	$Feedback.text = result.get("message", "")
	$Feedback.visible = not $Feedback.text.is_empty()
	_request_refresh()


func _on_visibility() -> void:
	if playback != null and not is_visible_in_tree():
		playback.pause()


func _on_save(report: Dictionary) -> void:
	if not report.ok:
		$SaveNotice.text = "No se pudo guardar o recuperar el progreso. La sesión sigue en memoria."
		$SaveNotice.visible = true
		$RetrySave.visible = manager != null and not manager.engine.get_state_snapshot().is_empty()
	elif report.code in ["saved", "loaded", "restored_backup"]:
		$SaveNotice.visible = false
		$RetrySave.visible = false


func _state_text(view: Dictionary) -> String:
	var labels: Dictionary = {"EMPTY": "Sin audio", "STOPPED": "Detenido", "PLAYING": "Reproduciendo", "PAUSED": "En pausa · pulse Reproducir para continuar", "ENDED": "Intervalo finalizado" if not view.segment_id.is_empty() else "Grabación finalizada", "ERROR": "Error de reproducción"}
	return labels.get(view.state, "Grabación pendiente · consulta textual") + ("\n" + view.error if not view.error.is_empty() else "")


func _time(seconds: float) -> String:
	return "%02d:%02d" % [int(seconds) / 60, int(seconds) % 60]


func _button(text: String) -> Button:
	var button: Button = Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(180, 88)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	button.text_overrun_behavior = TextServer.OVERRUN_NO_TRIMMING
	return button


func _clear(container: Node) -> void:
	for child: Node in container.get_children():
		container.remove_child(child)
		child.queue_free()
