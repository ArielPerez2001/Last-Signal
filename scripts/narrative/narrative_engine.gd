extends RefCounted

signal case_loaded(case_id: String)
signal node_changed(node: Dictionary)
signal choices_changed(choices: Array)
signal state_changed(snapshot: Dictionary)
signal evidence_registered(evidence_id: String)
signal event_requested(event: Dictionary)
signal case_finished(ending_id: String)
signal narrative_error(diagnostics: Array)
signal session_restored(snapshot: Dictionary)

const Loader = preload("res://scripts/narrative/narrative_loader.gd")
const Validator = preload("res://scripts/narrative/narrative_validator.gd")
const SessionState = preload("res://scripts/narrative/narrative_session_state.gd")
const Conditions = preload("res://scripts/narrative/condition_evaluator.gd")
const Effects = preload("res://scripts/narrative/effect_processor.gd")
const StateValidator = preload("res://scripts/narrative/narrative_state_validator.gd")
const MAX_AUTO_TRANSITIONS: int = 64

var _case: Dictionary = {}
var _nodes: Dictionary = {}
var _state: SessionState
var _source: String = ""
var _busy: bool = false
var _reporting_error: bool = false
var _diagnostics: Dictionary = {"ok": true, "errors": [], "warnings": []}


func load_case(path: String) -> bool:
	if _busy:
		return _fail("busy", "No se puede modificar la sesión durante una notificación.")
	_busy = true
	var loaded: Dictionary = Loader.load_file(path)
	if not loaded.ok:
		_busy = false
		return _report_failure(loaded)
	var validation: Dictionary = Validator.new().validate(loaded.data, path)
	if not validation.ok:
		_busy = false
		return _report_failure(validation)
	_case = loaded.data.duplicate(true)
	_nodes.clear()
	for node: Dictionary in _case.nodes:
		_nodes[node.id] = node
	_source = path
	_state = null
	_diagnostics = validation.duplicate(true)
	case_loaded.emit(_case.case_id)
	_busy = false
	return true


func start_case() -> bool:
	return _start(false)


func restart_case() -> bool:
	return _start(true)


func _start(restart: bool) -> bool:
	if _busy:
		return _fail("busy", "No se puede iniciar durante una notificación.")
	if _case.is_empty():
		return _fail("case_not_loaded", "Primero debe cargar un caso válido.")
	if _state != null and not restart:
		return _fail("already_started", "La sesión ya comenzó; use restart_case para reiniciarla.")
	_busy = true
	var candidate: SessionState = SessionState.new(_case)
	var pending: Array[Dictionary] = []
	var error_message: String = _advance(candidate, _case.initial_node, pending)
	if not error_message.is_empty():
		_busy = false
		return _fail("execution_error", error_message, "initial_node", candidate.data.current_node)
	candidate.data.revision = 1
	_state = candidate
	_clear_errors()
	_publish(pending, true)
	_busy = false
	return true


func select_choice(choice_id: String, expected_revision: int = -1) -> bool:
	if _busy:
		return _fail("busy", "No se permiten elecciones reentrantes.")
	if _state == null:
		return _fail("session_not_started", "La sesión todavía no comenzó.")
	if _state.data.finished:
		return _fail("session_finished", "La sesión terminó; reinicie o cargue otro caso.")
	if expected_revision < -1 or (expected_revision != -1 and expected_revision != _state.data.revision):
		return _fail("stale_choice", "La opción corresponde a una revisión anterior.", "revision")
	var selected: Dictionary = {}
	for option: Dictionary in _nodes[_state.data.current_node].options:
		if option.id == choice_id:
			selected = option
			break
	if selected.is_empty():
		return _fail("unknown_choice", "La opción no pertenece al nodo actual.", "choice_id")
	if not _eligible(selected, _state.data):
		return _fail("choice_unavailable", "La opción está oculta o deshabilitada.", "choice_id")
	_busy = true
	var candidate: SessionState = _state.copy()
	var pending: Array[Dictionary] = []
	var scope: String = "choice:" + candidate.data.current_node + ":" + str(candidate.data.visit_serial) + ":" + choice_id
	if choice_id not in candidate.data.executed_actions:
		candidate.data.executed_actions.append(choice_id)
	candidate.data.transaction_log.append({"node_id": candidate.data.current_node, "choice_id": choice_id, "revision": candidate.data.revision})
	var error_message: String = Effects.apply(selected.get("effects", []), candidate.data, _case.variables, scope, pending)
	if error_message.is_empty():
		error_message = _advance(candidate, selected.next, pending)
	if not error_message.is_empty():
		_busy = false
		return _fail("execution_error", error_message, "next", candidate.data.current_node)
	candidate.data.revision += 1
	_state = candidate
	_clear_errors()
	_publish(pending, true)
	_busy = false
	return true


func _advance(candidate: SessionState, target: String, pending: Array[Dictionary]) -> String:
	var automatic_steps: int = 0
	while true:
		if not _nodes.has(target):
			return "Destino inexistente: " + target
		var node: Dictionary = _nodes[target]
		candidate.data.current_node = target
		candidate.data.visit_serial += 1
		candidate.data.visits[target] = candidate.data.visits.get(target, 0) + 1
		var scope: String = "entry:" + target + ":" + str(candidate.data.visit_serial)
		var effect_error: String = Effects.apply(node.get("entry_effects", []), candidate.data, _case.variables, scope, pending)
		if not effect_error.is_empty():
			return target + ": " + effect_error
		match node.type:
			"ending":
				candidate.data.finished = true
				candidate.data.ending_id = node.ending_id
				return ""
			"dialogue":
				for option: Dictionary in node.options:
					if _eligible(option, candidate.data):
						return ""
				return target + ": no hay opciones visibles y habilitadas."
			"transition":
				automatic_steps += 1
				if automatic_steps > MAX_AUTO_TRANSITIONS:
					return target + ": se superó el límite de %d transiciones automáticas." % MAX_AUTO_TRANSITIONS
				if Conditions.evaluate(node.get("condition", {"op": "always"}), candidate.data):
					target = node.next
				elif node.has("fallback_next"):
					target = node.fallback_next
				else:
					return target + ": condición de transición no satisfecha y sin fallback_next."
			_:
				return target + ": tipo de nodo no reconocido."
	return ""


func _eligible(option: Dictionary, state: Dictionary) -> bool:
	return Conditions.evaluate(option.get("visible_when", {"op": "always"}), state) and Conditions.evaluate(option.get("enabled_when", {"op": "always"}), state)


func get_current_node() -> Dictionary:
	if _state == null:
		return {}
	var node: Dictionary = _nodes[_state.data.current_node]
	var view: Dictionary = {"id": node.id, "type": node.type, "text": node.get("text", ""), "revision": _state.data.revision}
	if node.has("speaker_id"):
		view.speaker_id = node.speaker_id
		for character: Dictionary in _case.characters:
			if character.id == node.speaker_id:
				view.speaker_name = character.display_name
	if node.has("ending_id"):
		view.ending_id = node.ending_id
	return view.duplicate(true)


func get_available_choices() -> Array[Dictionary]:
	var choices: Array[Dictionary] = []
	if _state == null or _state.data.finished:
		return choices
	for option: Dictionary in _nodes[_state.data.current_node].options:
		if not Conditions.evaluate(option.get("visible_when", {"op": "always"}), _state.data):
			continue
		var enabled: bool = Conditions.evaluate(option.get("enabled_when", {"op": "always"}), _state.data)
		choices.append({"id": option.id, "text": option.text, "enabled": enabled, "disabled_reason": "" if enabled else option.get("disabled_reason", "No disponible"), "revision": _state.data.revision})
	return choices


func get_state_snapshot() -> Dictionary:
	return {} if _state == null else _state.snapshot()


func get_case_metadata() -> Dictionary:
	if _case.is_empty():
		return {}
	return {"case_id": _case.case_id, "content_version": _case.content_version, "narrative_schema_version": int(_case.schema_version), "content_fingerprint": JSON.stringify(_case, "", true, true).sha256_text()}


func is_busy() -> bool:
	return _busy


func validate_state_snapshot(snapshot: Dictionary) -> Dictionary:
	var validation: Dictionary = StateValidator.validate(snapshot, _case)
	if not validation.ok:
		return validation
	var candidate: Dictionary = validation.data
	# Replay is confined to an unobserved engine. The live session emits no effects.
	var replay = get_script().new()
	replay._case = _case.duplicate(true)
	replay._nodes = _nodes.duplicate(true)
	if not replay.start_case():
		return StateValidator.failure("invalid_history", "El contenido no permite reconstruir el inicio.")
	var consumed_index: int = 0
	for entry: Dictionary in candidate.transaction_log:
		while replay.get_state_snapshot().revision < entry.revision:
			if consumed_index >= candidate.consumed_events.size() or not replay.consume_event(candidate.consumed_events[consumed_index]):
				return StateValidator.failure("invalid_history", "El historial de consumo de eventos es inconsistente.")
			consumed_index += 1
		var before: Dictionary = replay.get_state_snapshot()
		if before.revision != entry.revision or before.current_node != entry.node_id or not replay.select_choice(entry.choice_id, entry.revision):
			return StateValidator.failure("invalid_history", "Una decisión del historial no es válida para su nodo o revisión.")
	while consumed_index < candidate.consumed_events.size():
		if not replay.consume_event(candidate.consumed_events[consumed_index]):
			return StateValidator.failure("invalid_history", "El registro contiene un evento desconocido o ya consumido.")
		consumed_index += 1
	if replay.get_state_snapshot() != candidate:
		return StateValidator.failure("inconsistent_snapshot", "El estado, sus referencias o sus efectos no coinciden con el historial confirmado.")
	return {"ok": true, "code": "valid_snapshot", "message": "Estado completo validado contra el contenido.", "data": candidate.duplicate(true)}


func restore_state_snapshot(snapshot: Dictionary) -> bool:
	if _busy:
		return _fail("busy", "No se permite restaurar durante una notificación.")
	_busy = true
	var validation: Dictionary = validate_state_snapshot(snapshot)
	if not validation.ok:
		_busy = false
		return _fail(validation.code, validation.message, "session")
	var candidate: SessionState = SessionState.new()
	candidate.data = validation.data.duplicate(true)
	_state = candidate
	_clear_errors()
	# Restoration is its own notification, not a narrative advance or new event.
	session_restored.emit(get_state_snapshot())
	node_changed.emit(get_current_node())
	choices_changed.emit(get_available_choices())
	_busy = false
	return true


func is_case_finished() -> bool:
	return _state != null and _state.data.finished


func get_ending_id() -> String:
	return "" if _state == null else _state.data.ending_id


func get_diagnostics() -> Dictionary:
	return _diagnostics.duplicate(true)


func get_pending_events() -> Array[Dictionary]:
	var pending: Array[Dictionary] = []
	if _state != null:
		for event: Dictionary in _state.data.events:
			if event.id not in _state.data.consumed_events:
				pending.append(event.duplicate(true))
	return pending


func consume_event(event_instance_id: String) -> bool:
	if _busy:
		return _fail("busy", "No se puede consumir un evento durante una notificación.")
	if _state == null:
		return _fail("session_not_started", "La sesión todavía no comenzó.")
	var available: bool = false
	for event: Dictionary in get_pending_events():
		if event.id == event_instance_id:
			available = true
	if not available:
		return _fail("event_unavailable", "El evento no existe o ya fue consumido.", "event_id")
	_busy = true
	var candidate: SessionState = _state.copy()
	candidate.data.consumed_events.append(event_instance_id)
	candidate.data.revision += 1
	_state = candidate
	_clear_errors()
	_publish([], false)
	_busy = false
	return true


func _publish(pending: Array[Dictionary], changed_node: bool) -> void:
	state_changed.emit(get_state_snapshot())
	for notification: Dictionary in pending:
		if notification.kind == "evidence":
			evidence_registered.emit(notification.id)
		else:
			event_requested.emit(notification.event.duplicate(true))
	if changed_node:
		node_changed.emit(get_current_node())
	choices_changed.emit(get_available_choices())
	if changed_node and is_case_finished():
		case_finished.emit(get_ending_id())


func _clear_errors() -> void:
	_diagnostics.ok = true
	_diagnostics.errors = []


func _fail(code: String, message: String, property: String = "$", node_override: String = "") -> bool:
	var node_id: String = node_override if not node_override.is_empty() else ("" if _state == null else str(_state.data.current_node))
	return _report_failure({"ok": false, "errors": [{"source": _source, "node_id": node_id, "property": property, "code": code, "message": message}], "warnings": _diagnostics.warnings})


func _report_failure(report: Dictionary) -> bool:
	_diagnostics = {"ok": false, "errors": report.errors.duplicate(true), "warnings": report.get("warnings", []).duplicate(true)}
	if not _reporting_error:
		var previous_busy: bool = _busy
		_busy = true
		_reporting_error = true
		narrative_error.emit(_diagnostics.errors.duplicate(true))
		_reporting_error = false
		_busy = previous_busy
	return false
