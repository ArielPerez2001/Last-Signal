extends VBoxContainer

signal menu_requested
const Director = preload("res://scripts/ui/case_flow_director.gd")
const Canvas = preload("res://scripts/ui/map_canvas.gd")
var controller: RefCounted
var director: RefCounted
var evidence: RefCounted
var deductions: RefCounted
var audio: RefCounted
var dispatch: RefCounted
var map_manager: RefCounted
var mode: String = "call"
var question_id: String = "c001_q01"
var feedback: Dictionary = {}
var pending: Dictionary = {}
var help_level: int = 0
var show_all: bool = false
var show_map: bool = false
var audio_context: Dictionary = {}
var transcript: String = ""
var _queued: bool = false
var _locked: bool = false
var _last_node: String = ""
var _previous_evidence: Array = []
var _notice: String = ""
var _lesson: String = ""
var _help_return: String = "call"
var _scroll_positions: Dictionary = {}
var interaction_count: int = 0
var task_entries: int = 0
@onready var body: VBoxContainer = $Scroll/Body


func _ready() -> void:
	$Header/Menu.pressed.connect(func() -> void: menu_requested.emit())
	$Secondary/Archive.pressed.connect(func() -> void: _activate(_open.bind("archive")))
	$Secondary/Help.pressed.connect(func() -> void:
		_help_return = mode
		help_level = 0
		_activate(_open.bind("help"))
	)


func bind_services(calls: RefCounted, archive: RefCounted, reasoning: RefCounted, analysis: RefCounted, operations: RefCounted, locations: RefCounted) -> void:
	if controller != null and controller.presentation_changed.is_connected(_on_view):
		controller.presentation_changed.disconnect(_on_view)
	controller = calls
	director = Director.new(calls.engine, calls.saves)
	evidence = archive
	deductions = reasoning
	audio = analysis
	dispatch = operations
	map_manager = locations
	dispatch.contextual_reports = calls.engine.get_case_id() == "c001"
	mode = "call"
	_last_node = ""
	_previous_evidence = []
	_notice = ""
	feedback = {}
	pending = {}
	transcript = ""
	audio_context = {}
	_scroll_positions.clear()
	controller.presentation_changed.connect(_on_view)
	_on_view(controller.get_view())


func _on_view(view: Dictionary) -> void:
	if view.case_id != "c001":
		return
	dispatch.contextual_reports = true
	var state: Dictionary = controller.engine.get_state_snapshot()
	var node: String = state.get("current_node", "")
	if node != _last_node:
		_notice = ""
		mode = {"audio": "audio", "map": "dispatch", "evidence": "reason"}.get(controller.engine.get_current_node().get("panel_id", ""), "call")
		_last_node = node
		_scroll_positions[mode] = 0
		feedback = {}
		if mode == "reason":
			question_id = "c001_q01" if "c001_q01" not in state.get("executed_actions", []) else "c001_q02"
	if not _previous_evidence.is_empty():
		var new_items: Array = state.get("evidence", []).filter(func(id: String) -> bool: return id not in _previous_evidence)
		if not new_items.is_empty():
			_notice = "Registrado: " + evidence.get_detail(new_items[-1]).data.title
	_previous_evidence = state.get("evidence", []).duplicate()
	if not pending.is_empty() and pending.revision != state.get("revision"):
		pending = {}
	_queue_render()


func _queue_render() -> void:
	if not _queued:
		_queued = true
		_render.call_deferred()


func _render() -> void:
	_queued = false
	if not is_inside_tree() or controller == null or controller.engine.get_case_id() != "c001":
		return
	for child: Node in body.get_children():
		body.remove_child(child)
		child.queue_free()
	var node: Dictionary = controller.engine.get_current_node()
	$Secondary.visible = node.get("id") != "c001_n01"
	$Secondary/Archive.visible = director.unlocked("archive")
	$Secondary/Archive.disabled = mode == "archive"
	$Secondary/Help.disabled = mode == "help"
	_lesson = director.current_lesson() if mode == "call" else {"reason": "deduction", "audio": "audio", "dispatch": "dispatch", "archive": "archive"}.get(mode, "")
	var view: Dictionary = controller.get_view()
	if not view.error.is_empty():
		_label(view.error.message + " El progreso disponible sigue en memoria.", "AccentLabel")
		_button("Reintentar guardado", "retry", _retry)
	match mode:
		"call": _render_call()
		"reason": _render_reason()
		"dispatch": _render_dispatch()
		"audio": _render_audio()
		"recordings": _render_recordings()
		"archive": _render_archive()
		"history": _render_history()
		"help": _render_help()
	if mode != "call":
		_button("Retomar llamada", "return", back_to_call)
	if not _notice.is_empty() and mode == "call":
		_label(_notice, "SignalLabel")
	_restore_scroll.call_deferred(mode, int(_scroll_positions.get(mode, 0)))


func _render_call() -> void:
	_label(controller.engine.get_current_node().get("speaker_name", "Línea dos"), "SignalLabel")
	_label(director.text(), "", "narrative")
	var goal: Dictionary = director.goal()
	if controller.engine.get_current_node().get("id") != "c001_n01":
		_label(goal.get("text", ""), "MutedLabel", "objective")
	_tutorial()
	var actions: Array = director.actions()
	for action: Dictionary in actions:
		_button(action.label, action.id, _action.bind(action), actions.size() == 1, _lesson)
	if controller.engine.get_current_node().get("id") == "c001_n24":
		_button("Revisar investigación antes de decidir", "review", _choose.bind("c001_n24_o01", controller.engine.get_state_snapshot().revision))
	if controller.engine.is_case_finished():
		_button("Volver al menú", "menu", menu_requested.emit)


func _render_reason() -> void:
	var view: Dictionary = deductions.get_reasoning(question_id)
	if not view.ok:
		_label(view.message)
		return
	_label("CRUCE DE FUENTES", "SignalLabel")
	_label(view.data.question, "HeadingLabel", "question")
	_tutorial()
	if view.code == "CONFIRMED":
		_label(view.message, "", "conclusion")
		return
	for source: Dictionary in view.data.sources:
		_source(source, true)
	if not feedback.is_empty():
		_label(feedback.message, "AccentLabel", "feedback")
	if view.code != "READY":
		_label(view.message)
	else:
		for answer: Dictionary in view.data.answers:
			_button(answer.text, "answer:" + answer.id, _reason.bind(answer.id, view.data.revision), false, "deduction")
	if not feedback.is_empty() and not feedback.ok:
		_button("Pedir orientación", "hint", _help_for_current)


func _render_dispatch() -> void:
	_label("INSPECCIÓN EXTERIOR", "SignalLabel")
	_label("Comprobar el Hotel Mirador sin entrar en una estructura insegura.", "HeadingLabel")
	_tutorial()
	if not feedback.is_empty():
		_label(feedback.message, "AccentLabel", "feedback")
	if not pending.is_empty():
		_label(pending.text, "", "confirmation")
		_button("Confirmar instrucción a R1", "dispatch_confirm", _confirm_dispatch, true, "dispatch")
		_button("Elegir otro acceso", "dispatch_cancel", _cancel_dispatch)
		return
	var state: Dictionary = controller.engine.get_state_snapshot()
	if controller.engine.is_investigation_closed():
		_label("Operaciones cerradas. Se conserva el último estado registrado.")
	else:
		for event: Dictionary in dispatch.get_available_events():
			_button(event.label, "event:" + event.id, _operation_event.bind(event), true, "dispatch")
		for incident: Dictionary in dispatch.get_incidents(true):
			var checked: Dictionary = dispatch.can_dispatch("c001_r1", incident.id)
			if checked.ok and checked.code == "VALID":
				_button(incident.title, "access:" + incident.id, _select_access.bind(incident.id), false, "dispatch")
	if state.variables.r1_status != "AVAILABLE" and not controller.engine.is_investigation_closed():
		_label("R1 mantiene su asignación. El siguiente cambio requiere un parte o una instrucción disponible.", "MutedLabel")
	if controller.engine.get_current_node().get("id") == "c001_n25" and not controller.engine.is_investigation_closed():
		_label("Hay una instrucción preparada. Retoma la llamada y elige «Corregir antes de transmitir» para cambiar el plan.", "AccentLabel")
	_button("Ocultar plano" if show_map else "Consultar plano · opcional", "map", _toggle_map)
	if show_map:
		var canvas: Control = Canvas.new()
		canvas.custom_minimum_size.y = 250
		body.add_child(canvas)
		canvas.configure(map_manager.get_map(), map_manager.get_visible_locations(), "")
		canvas.location_selected.connect(func(id: String) -> void:
			for item: Dictionary in dispatch.get_incidents(true):
				if item.location_id == id:
					_activate(_select_access.bind(item.id), "dispatch")
		)


func _render_audio() -> void:
	_label("REGISTRO DE LA LÍNEA", "SignalLabel")
	_tutorial()
	if audio_context.is_empty():
		for record: Dictionary in audio.get_recordings():
			if record.recording_id == "c001_g01":
				audio_context = {"record": record.recording_id, "segment": "c001_g01_s02", "filter": "voces"}
	if not transcript.is_empty():
		_label(transcript, "", "transcript")
		if not feedback.is_empty(): _label(feedback.message, "SignalLabel")
	else:
		_label("Examina las palabras registradas en este fragmento. La transcripción es la alternativa provisional; no hay reproducción oficial disponible.")
		_button("Examinar fragmento", "read", _read_audio, true, "audio")
	_button("Otros fragmentos · opcional", "recordings", _list_recordings)


func _render_archive() -> void:
	_label("REGISTROS CONSERVADOS", "SignalLabel")
	_tutorial()
	var discovered: Array = evidence.get_discovered()
	var ids: Array = ["c001_e01", "c001_e02"] if "c001_q01" not in controller.engine.get_state_snapshot().executed_actions else ["c001_e03", "c001_e04", "c001_e06", "c001_e07"]
	_label("Expediente completo" if show_all else "Fuentes para contrastar la atención", "HeadingLabel")
	for record: Dictionary in discovered:
		if show_all or record.id in ids:
			_source(record)
	_button("Ver fuentes del momento" if show_all else "Consultar expediente completo", "all_sources", _toggle_sources, false, "archive")
	for conclusion: Dictionary in deductions.get_confirmed():
		_label(conclusion.title + "\n" + conclusion.narrative_feedback, "MutedLabel")
	_button("Historial de la comunicación", "history", _open.bind("history"), false, "archive")
	var node: String = controller.engine.get_current_node().get("id", "")
	if node == "c001_n10":
		_label("Ampliar la investigación · opcional", "SignalLabel")
		for choice: Dictionary in controller.engine.get_available_choices():
			if choice.enabled and choice.id in ["c001_n10_o01", "c001_n10_o02", "c001_n10_o04", "c001_n10_o05", "c001_n10_o08", "c001_n10_o11"]:
				_button(director.config.get("labels", {}).get(choice.id, choice.text), choice.id, _choose.bind(choice.id, choice.revision), false, "archive")
	if director.unlocked("deduction"):
		for hypothesis: Dictionary in deductions.get_hypotheses():
			var view: Dictionary = deductions.get_reasoning(hypothesis.id)
			if view.ok and view.code == "READY":
				_button(hypothesis.title, "reason:" + hypothesis.id, _open_reason.bind(hypothesis.id), false, "archive")
	if director.unlocked("audio"):
		_button("Consultar registro de la línea", "audio", _open.bind("audio"), false, "archive")
	if director.unlocked("dispatch"):
		_button("Revisar inspección exterior", "dispatch", _open.bind("dispatch"), false, "archive")


func _render_history() -> void:
	_label("HISTORIAL DE LA LÍNEA DOS", "SignalLabel")
	for entry: Dictionary in controller.get_view().history:
		_label(entry.get("speaker_name", entry.get("speaker", "")) + "\n" + entry.get("text", ""))


func _render_help() -> void:
	_label("AYUDA DE LA CENTRAL", "SignalLabel")
	var goal: Dictionary = director.goal()
	_label(goal.get("text", ""), "HeadingLabel")
	var local: Dictionary = {
		"reason": ["Compara qué afirma cada fuente mostrada.", "Elige una conclusión respaldada por esas fuentes; no necesitas seleccionar fichas."],
		"dispatch": ["La inspección contrasta el exterior actual con la llamada.", "Elige un acceso y confirma. Si R1 ya está asignada, recibe el parte disponible; un plan preparado necesita corrección explícita."],
		"audio": ["Puedes consultar el registro sin utilizar filtros.", "Pulsa Examinar fragmento. El texto se muestra y la observación se registra cuando sus condiciones se cumplen."],
		"archive": ["Estas consultas amplían o recuerdan lo conocido.", "Puedes volver a la llamada sin completar todos los registros ni todas las conclusiones."]}
	var hints: Array = local.get(_help_return, goal.get("help", []))
	for index: int in range(mini(help_level, hints.size())):
		_label(hints[index])
	if help_level < hints.size():
		_button("Orientación" if help_level == 0 else "Ayuda concreta", "more_hint", _more_help)
	for lesson: String in controller.saves.get_tutorials_seen():
		_label(director.config.tutorials.get(lesson, ""), "MutedLabel")
	_button("Volver a la consulta", "help_back", _open.bind(_help_return))


func _tutorial() -> void:
	var text: String = director.tutorial(_lesson)
	if not text.is_empty(): _label(text, "AccentLabel", "tutorial")


func _action(action: Dictionary) -> void:
	match action.kind:
		"choice": _choose(action.choice, action.revision)
		"reason": _open_reason(action.target)
		"dispatch": _open("dispatch")
		"audio":
			audio_context = {"record": "c001_g01", "segment": "c001_g01_s02", "filter": "voces"}
			_open("audio")


func _choose(id: String, revision: int) -> void:
	if controller.engine.get_state_snapshot().revision != revision:
		feedback = {"ok": false, "message": "La comunicación ha cambiado. Revisa las opciones actuales."}
		return
	if controller.get_view().state == "INCOMING":
		if not controller.answer_call().ok: return
		revision = controller.engine.get_state_snapshot().revision
	var result: Dictionary = controller.select_choices(director.sequence(id), revision)
	feedback = {} if result.ok else result
	if controller.engine.is_case_finished() and result.ok:
		menu_requested.emit()


func _open(next_mode: String) -> void:
	_scroll_positions[mode] = $Scroll.scroll_vertical
	mode = next_mode
	feedback = {}
	_notice = ""
	if next_mode in ["reason", "dispatch", "audio"]: task_entries += 1
	if next_mode == "audio": transcript = ""


func back_to_call() -> void:
	var node: Dictionary = controller.engine.get_current_node()
	var choices: Array = controller.engine.get_available_choices()
	if not node.get("panel_id", "").is_empty() and choices.size() == 1 and choices[0].enabled:
		_choose(choices[0].id, choices[0].revision)
	else:
		_open("call")


func go_back() -> void:
	if mode == "help":
		_open(_help_return)
	elif mode == "history":
		_open("archive")
	elif mode == "recordings":
		_open("audio")
	else:
		back_to_call()


func _open_reason(id: String) -> void:
	question_id = id
	_open("reason")


func _reason(answer: String, revision: int) -> void:
	feedback = deductions.reason(question_id, answer, revision)


func _select_access(id: String) -> void:
	var checked: Dictionary = dispatch.can_dispatch("c001_r1", id)
	if checked.ok and checked.code == "VALID":
		pending = {"kind": "assign", "incident": id, "revision": controller.engine.get_state_snapshot().revision, "text": "R1 · " + dispatch.get_incident(id).data.title + "\nInspección desde una zona exterior segura."}
	else: feedback = checked


func _cancel_dispatch() -> void:
	pending = {}


func _confirm_dispatch() -> void:
	if pending.is_empty(): return
	var request: Dictionary = pending.duplicate(true)
	pending = {}
	if request.kind == "assign":
		feedback = dispatch.dispatch_unit("c001_r1", request.incident, request.revision)
	else:
		feedback = dispatch.process_event(request.id, request.unit, request.incident, request.revision)


func _operation_event(event: Dictionary) -> void:
	if event.id == "c001_m05":
		pending = {"kind": "event", "id": event.id, "unit": event.unit_id, "incident": event.incident_id, "revision": event.revision, "text": event.label + "\nMantener la inspección desde una zona exterior segura."}
	else:
		feedback = dispatch.process_event(event.id, event.unit_id, event.incident_id, event.revision)


func _read_audio() -> void:
	if audio_context.is_empty(): return
	feedback = audio.select_recording(audio_context.record)
	if not feedback.ok: return
	feedback = audio.set_filter(audio_context.filter)
	if not feedback.ok: return
	feedback = audio.play_segment(audio_context.segment)
	if not feedback.ok: return
	transcript = audio.get_accessible_information()
	if not controller.engine.is_investigation_closed():
		feedback = audio.consult_selected()
		if feedback.ok:
			feedback.message = "Observación conservada en Registros."
	else:
		feedback = {"ok": true, "message": "Registro conservado para consulta."}


func _list_recordings() -> void:
	_open("recordings")


func _render_recordings() -> void:
	# No selectors for filters that produce no perceptible difference in TEXT.
	_label("Fragmentos disponibles", "HeadingLabel")
	for record: Dictionary in audio.get_recordings():
		var view: Dictionary = audio.get_recording(record.recording_id)
		for segment: Dictionary in view.data.segments:
			_button(record.title + " · " + segment.title, "segment:" + segment.segment_id, _select_fragment.bind(record.recording_id, segment.segment_id))


func _select_fragment(record: String, segment: String) -> void:
	mode = "audio"
	audio_context = {"record": record, "segment": segment, "filter": "voces"}
	_read_audio()


func _toggle_map() -> void:
	show_map = not show_map


func _toggle_sources() -> void:
	show_all = not show_all


func _more_help() -> void:
	help_level = mini(2, help_level + 1)


func _help_for_current() -> void:
	_help_return = mode
	help_level = 0
	_open("help")


func _retry() -> void:
	feedback = controller.retry_save()


func _source(record: Dictionary, compact: bool = false) -> void:
	var panel := PanelContainer.new()
	panel.theme_type_variation = &"StatusPanel"
	body.add_child(panel)
	var label := Label.new()
	label.text = record.title + "\n" + record.description + ("" if compact else "\n" + record.source)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	panel.add_child(label)


func _label(text: String, variation: String = "", identity: String = "") -> void:
	if text.is_empty(): return
	var label := Label.new()
	label.text = text
	label.theme_type_variation = StringName(variation)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	if not identity.is_empty(): label.set_meta("role", identity)
	body.add_child(label)


func _button(text: String, identity: String, callback: Callable, primary: bool = false, lesson: String = "") -> void:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size.y = 88
	button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	button.set_meta("intent", identity)
	button.theme_type_variation = &"PrimaryButton" if primary else &"Button"
	button.pressed.connect(_activate.bind(callback, lesson))
	body.add_child(button)


func _activate(callback: Callable, lesson: String = "") -> void:
	if _locked: return
	_locked = true
	interaction_count += 1
	callback.call()
	if not lesson.is_empty(): controller.saves.mark_tutorial_seen(lesson)
	_unlock.call_deferred()


func _input(event: InputEvent) -> void:
	if is_visible_in_tree() and ((event is InputEventMouseButton and event.double_click) or (event is InputEventScreenTouch and event.double_tap)):
		_locked = true
		_unlock.call_deferred()


func _unlock() -> void:
	_locked = false
	_queue_render()


func _restore_scroll(expected_mode: String, value: int) -> void:
	if mode == expected_mode: $Scroll.scroll_vertical = value
