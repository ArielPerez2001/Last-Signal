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
signal deduction_confirmed(deduction_id: String)

const Loader = preload("res://scripts/narrative/narrative_loader.gd")
const Validator = preload("res://scripts/narrative/narrative_validator.gd")
const SessionState = preload("res://scripts/narrative/narrative_session_state.gd")
const Conditions = preload("res://scripts/narrative/condition_evaluator.gd")
const Effects = preload("res://scripts/narrative/effect_processor.gd")
const StateValidator = preload("res://scripts/narrative/narrative_state_validator.gd")
const Deductions = preload("res://scripts/systems/deduction_manager.gd")
const DispatchRules = preload("res://scripts/systems/dispatch_rules.gd")
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
	for variant: Dictionary in node.get("text_variants", []):
		if Conditions.evaluate(variant.condition, _state.data):
			view.text = variant.text
			break
	for row: Dictionary in node.get("text_rows", []):
		if Conditions.evaluate(row.condition, _state.data):
			view.text += "\n" + row.text
	if node.has("speaker_id"):
		view.speaker_id = node.speaker_id
		for character: Dictionary in _case.characters:
			if character.id == node.speaker_id:
				view.speaker_name = character.display_name
	if node.has("panel_id"):
		view.panel_id = node.panel_id
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
	var metadata: Dictionary = {"case_id": _case.case_id, "content_version": _case.content_version, "narrative_schema_version": int(_case.schema_version), "content_fingerprint": JSON.stringify(_case, "", true, true).sha256_text()}
	if _case.has("connection_action"):
		metadata.connection_action = _case.connection_action
	return metadata


func get_case_id() -> String:
	return _case.get("case_id", "")


func is_busy() -> bool:
	return _busy


func get_investigation_catalog() -> Dictionary:
	if not _case.has("investigation"):
		return {}
	var catalog: Dictionary = _case.investigation.duplicate(true)
	catalog.case_id = _case.case_id
	catalog.title = _case.title
	return catalog


func get_dispatch_catalog() -> Dictionary:
	return _case.get("operations", {}).duplicate(true)


func process_dispatch(command: Dictionary, expected_revision: int = -1) -> Dictionary:
	if _busy:
		return DispatchRules.report(false, "BUSY", "Espere a que termine la operación actual.")
	var result: Dictionary = DispatchRules.evaluate(get_dispatch_catalog(), get_state_snapshot(), command)
	if not result.ok or result.code != "VALID":
		return result
	var committed: Dictionary = _commit_investigation(result.data, false, expected_revision, {}, command)
	if committed.ok:
		committed.message = result.message
	return committed


func get_audio_catalog() -> Dictionary:
	return _case.get("audio_analysis", {}).duplicate(true)


func _dispatch_context_path(command: Dictionary) -> Array:
	if _state == null or command.get("kind") != "event":
		return []
	var rule: Dictionary = DispatchRules.find(get_dispatch_catalog().get("event_rules", []), "id", command.get("event_id", ""))
	var target: String = rule.get("from_node", _state.data.current_node)
	if target == _state.data.current_node:
		return []
	# Only effect-free tool/return choices may prepare a report's existing
	# context. Never cross a plan, emotional choice, evidence entry or ending.
	var queue: Array = [{"node": _state.data.current_node, "path": []}]
	var visited: Array = []
	while not queue.is_empty() and visited.size() < 16:
		var item: Dictionary = queue.pop_front()
		if item.node in visited:
			continue
		visited.append(item.node)
		for choice: Dictionary in _nodes[item.node].get("options", []):
			var destination: Dictionary = _nodes[choice.next]
			if not choice.get("effects", []).is_empty() or not _eligible(choice, _state.data) or destination.type != "dialogue" or not destination.get("entry_effects", []).is_empty():
				continue
			var path: Array = item.path + [choice.id]
			if destination.id == target:
				return path
			queue.append({"node": destination.id, "path": path})
	return []


func preview_contextual_dispatch(command: Dictionary) -> Dictionary:
	var state: Dictionary = get_state_snapshot()
	var direct: Dictionary = DispatchRules.evaluate(get_dispatch_catalog(), state, command)
	if direct.ok or state.is_empty():
		return direct
	var path: Array = _dispatch_context_path(command)
	if path.is_empty():
		return direct
	var rule: Dictionary = DispatchRules.find(get_dispatch_catalog().event_rules, "id", command.event_id)
	state.current_node = rule.from_node
	return DispatchRules.evaluate(get_dispatch_catalog(), state, command)


func process_contextual_dispatch(command: Dictionary, expected_revision: int = -1) -> Dictionary:
	if _busy:
		return DispatchRules.report(false, "BUSY", "Espere a que termine la operación actual.")
	if _state == null:
		return DispatchRules.report(false, "LOCKED", "No hay una investigación activa.")
	if expected_revision < -1 or (expected_revision != -1 and expected_revision != _state.data.revision):
		return DispatchRules.report(false, "STALE", "El parte corresponde a una revisión anterior.")
	var available: Dictionary = preview_contextual_dispatch(command)
	if not available.ok or available.code != "VALID":
		return available
	var path: Array = _dispatch_context_path(command)
	if path.is_empty():
		return process_dispatch(command, expected_revision)
	_busy = true
	# Reuse the exact command implementations on an isolated candidate. Publish
	# a single stable result; failure leaves the live session entirely intact.
	var candidate = get_script().new()
	candidate._case = _case.duplicate(true)
	candidate._nodes = _nodes.duplicate(true)
	candidate._state = _state.copy()
	var pending: Array[Dictionary] = []
	candidate.evidence_registered.connect(func(id: String) -> void: pending.append({"kind": "evidence", "id": id}))
	candidate.event_requested.connect(func(event: Dictionary) -> void: pending.append({"kind": "event", "event": event}))
	for id: String in path:
		if not candidate.select_choice(id, candidate.get_state_snapshot().revision):
			_busy = false
			return DispatchRules.report(false, "INVALID_EVENT", "No se pudo preparar la consulta del parte.")
	var result: Dictionary = candidate.process_dispatch(command, candidate.get_state_snapshot().revision)
	if result.ok and result.code == "VALID":
		_state = candidate._state.copy()
		_clear_errors()
		_publish(pending, true)
	_busy = false
	return result


# Internal bridge for AudioAnalysisManager and deterministic restoration.
# Player UI submits no timing data; the playback service supplies the proof.
func register_audio_observation(rule_id: String, proof: Dictionary, expected_revision: int = -1) -> Dictionary:
	if _busy:
		return Deductions.result(false, "BUSY", "Espere a que termine la operación actual.")
	if _state == null:
		return Deductions.result(false, "LOCKED", "No hay una investigación activa.")
	for rule: Dictionary in _case.get("audio_analysis", {}).get("discovery_rules", []):
		if rule.id != rule_id:
			continue
		var record: Dictionary = {}
		for item: Dictionary in _case.audio_analysis.recordings:
			if item.recording_id == rule.recording_id:
				record = item
		if not Conditions.evaluate(record.unlocked_by, _state.data):
			return Deductions.result(false, "LOCKED", "La grabación no está disponible.")
		if rule_id in _state.data.executed_actions:
			return Deductions.result(true, "ALREADY_DISCOVERED", "La observación ya está registrada.")
		if _state.data.finished or not Conditions.evaluate(rule.get("additional_conditions", {"op": "always"}), _state.data):
			return Deductions.result(false, "LOCKED", "La investigación no admite este descubrimiento ahora.")
		var interval: Dictionary = {}
		for segment: Dictionary in record.segments:
			if segment.segment_id == rule.segment_id:
				interval = segment
		if not StateValidator.has_fields(proof, ["recording_id", "segment_id", "filter_id", "listened_ms"]):
			return Deductions.result(false, "INSUFFICIENT", "Examine el fragmento con el filtro adecuado antes de registrar.")
		if proof.recording_id != rule.recording_id or proof.segment_id != rule.segment_id or proof.filter_id != rule.filter_id or not StateValidator.is_integer(proof.listened_ms, ceili(rule.min_listen_seconds * 1000.0), ceili((interval.end_time - interval.start_time) * 1000.0)):
			return Deductions.result(false, "INSUFFICIENT", "El examen del fragmento todavía es insuficiente.")
		var definition: Dictionary = {"id": rule.id, "effects": [{"op": "add_to_set", "target": "evidence", "value": rule.evidence_id}]}
		if rule.has("event_id"):
			definition.effects.append({"op": "emit_event", "event_id": rule.event_id})
		var normalized: Dictionary = proof.duplicate(true)
		normalized.listened_ms = int(normalized.listened_ms)
		return _commit_investigation(definition, false, expected_revision, normalized)
	return Deductions.result(false, "INVALID", "Observación no disponible.")


func get_investigation_actions() -> Array:
	var result: Array = []
	if _state == null or _state.data.finished:
		return result
	for action: Dictionary in _case.get("investigation", {}).get("actions", []):
		if not action.get("internal", false) and action.id not in _state.data.executed_actions and Conditions.evaluate(action.get("condition", {"op": "always"}), _state.data):
			result.append({"id": action.id, "title": action.title, "enabled": true, "revision": _state.data.revision})
	return result


func process_investigation_action(action_id: String, expected_revision: int = -1) -> Dictionary:
	if _busy:
		return Deductions.result(false, "BUSY", "Espere a que termine la operación actual.")
	for action: Dictionary in _case.get("investigation", {}).get("actions", []):
		if action.id == action_id:
			if _state == null or _state.data.finished:
				return Deductions.result(false, "LOCKED", "No hay una sesión activa que admita cambios.")
			if action_id in _state.data.executed_actions:
				return Deductions.result(true, "ALREADY_DISCOVERED", "La consulta ya está registrada.")
			if not Conditions.evaluate(action.get("condition", {"op": "always"}), _state.data):
				return Deductions.result(false, "LOCKED", "La consulta todavía no está disponible.")
			return _commit_investigation(action, false, expected_revision)
	return Deductions.result(false, "INVALID", "Acción de investigación desconocida.")


func confirm_deduction(evidence_ids: Array, expected_revision: int = -1) -> Dictionary:
	if _busy:
		return Deductions.result(false, "BUSY", "Espere a que termine la operación actual.")
	var evaluated: Dictionary = Deductions.evaluate(get_investigation_catalog(), get_state_snapshot(), evidence_ids)
	if evaluated.code != "VALID":
		return evaluated
	for definition: Dictionary in _case.investigation.deductions:
		if definition.id == evaluated.data.id:
			var committed: Dictionary = _commit_investigation(definition, true, expected_revision)
			if committed.ok:
				evaluated.data.confirmed = true
			return evaluated if committed.ok else committed
	return Deductions.result(false, "INVALID", "Regla no disponible.")


func _commit_investigation(definition: Dictionary, is_deduction: bool, expected_revision: int, analysis: Dictionary = {}, dispatch: Dictionary = {}) -> Dictionary:
	if expected_revision < -1 or (expected_revision != -1 and expected_revision != _state.data.revision):
		return Deductions.result(false, "STALE", "La selección corresponde a un estado anterior.")
	_busy = true
	var candidate: SessionState = _state.copy()
	candidate.data.executed_actions.append(definition.id)
	candidate.data.transaction_log.append({"node_id": candidate.data.current_node, "choice_id": definition.id, "revision": candidate.data.revision})
	if not analysis.is_empty():
		candidate.data.transaction_log[-1]["analysis"] = analysis.duplicate(true)
	if not dispatch.is_empty():
		candidate.data.transaction_log[-1]["dispatch"] = dispatch.duplicate(true)
	var pending: Array[Dictionary] = []
	var error_message: String = Effects.apply(definition.effects, candidate.data, _case.variables, "investigation:" + definition.id, pending)
	var changed_node: bool = definition.has("next")
	if error_message.is_empty() and changed_node:
		error_message = _advance(candidate, definition.next, pending)
	var eligible: bool = candidate.data.finished
	for option: Dictionary in _nodes[candidate.data.current_node].get("options", []):
		eligible = eligible or _eligible(option, candidate.data)
	if not error_message.is_empty() or not eligible:
		_busy = false
		return Deductions.result(false, "INVALID", "La acción no produce un estado narrativo estable.", {"node_id": _state.data.current_node, "detail": error_message if not error_message.is_empty() else "No hay opciones disponibles tras los efectos."})
	candidate.data.revision += 1
	_state = candidate
	_clear_errors()
	if is_deduction:
		pending.append({"kind": "deduction", "id": definition.id})
	_publish(pending, changed_node)
	_busy = false
	return Deductions.result(true, "VALID", "Acción de investigación confirmada.", {"id": definition.id})


func validate_state_snapshot(snapshot: Dictionary) -> Dictionary:
	return _validate_snapshot(snapshot, false)


func get_conversation_history() -> Array:
	if _state == null:
		return []
	return _validate_snapshot(get_state_snapshot(), true).get("history", []).duplicate(true)


func _validate_snapshot(snapshot: Dictionary, include_history: bool) -> Dictionary:
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
	var history: Array = []
	if include_history:
		_append_transcript_node(history, replay)
	var consumed_index: int = 0
	for entry: Dictionary in candidate.transaction_log:
		while replay.get_state_snapshot().revision < entry.revision:
			if consumed_index >= candidate.consumed_events.size() or not replay.consume_event(candidate.consumed_events[consumed_index]):
				return StateValidator.failure("invalid_history", "El historial de consumo de eventos es inconsistente.")
			consumed_index += 1
		var before: Dictionary = replay.get_state_snapshot()
		if entry.has("dispatch"):
			if entry.has("analysis") or before.revision != entry.revision or before.current_node != entry.node_id:
				return StateValidator.failure("invalid_history", "Transacción operativa fuera de su contexto.")
			var dispatch_result: Dictionary = replay.process_dispatch(entry.dispatch, entry.revision)
			if not dispatch_result.ok or dispatch_result.code != "VALID" or dispatch_result.data.id != entry.choice_id:
				return StateValidator.failure("invalid_history", "Asignación o parte operativo incoherente.")
			if include_history and replay.get_state_snapshot().visit_serial != before.visit_serial:
				_append_transcript_node(history, replay)
			continue
		var audio_rule: Dictionary = {}
		for rule: Dictionary in _case.get("audio_analysis", {}).get("discovery_rules", []):
			if rule.id == entry.choice_id:
				audio_rule = rule
		if not audio_rule.is_empty():
			if before.revision != entry.revision or before.current_node != entry.node_id:
				return StateValidator.failure("invalid_history", "Observación fuera de su revisión/nodo.")
			var audio_result: Dictionary = replay.register_audio_observation(audio_rule.id, entry.get("analysis", {}), entry.revision)
			if not audio_result.ok or audio_result.code != "VALID":
				return StateValidator.failure("invalid_history", "Comprobante de observación incoherente.")
			continue
		if entry.has("analysis"):
			return StateValidator.failure("invalid_history", "Solo las observaciones admiten comprobantes de audio.")
		var investigation: Dictionary = {}
		var is_deduction: bool = false
		for group: String in ["actions", "deductions"]:
			for definition: Dictionary in _case.get("investigation", {}).get(group, []):
				if definition.id == entry.choice_id:
					investigation = definition
					is_deduction = group == "deductions"
		if not investigation.is_empty():
			if before.revision != entry.revision or before.current_node != entry.node_id:
				return StateValidator.failure("invalid_history", "Acción de investigación fuera de su revisión/nodo.")
			var action_result: Dictionary = replay.confirm_deduction(investigation.required_evidence, entry.revision) if is_deduction else replay.process_investigation_action(investigation.id, entry.revision)
			if not action_result.ok or action_result.code != "VALID":
				return StateValidator.failure("invalid_history", "La investigación no corresponde a una acción válida nueva.")
			continue
		var chosen_text: String = ""
		if include_history and _nodes.has(entry.node_id):
			for option: Dictionary in _nodes[entry.node_id].get("options", []):
				if option.id == entry.choice_id:
					chosen_text = option.text
		if before.revision != entry.revision or before.current_node != entry.node_id or not replay.select_choice(entry.choice_id, entry.revision):
			return StateValidator.failure("invalid_history", "Una decisión del historial no es válida para su nodo o revisión.")
		if include_history:
			history.append({"id": "choice:" + str(entry.revision), "kind": "choice", "speaker": "Operador", "text": chosen_text, "node_id": entry.node_id, "choice_id": entry.choice_id})
			_append_transcript_node(history, replay)
	while consumed_index < candidate.consumed_events.size():
		if not replay.consume_event(candidate.consumed_events[consumed_index]):
			return StateValidator.failure("invalid_history", "El registro contiene un evento desconocido o ya consumido.")
		consumed_index += 1
	if replay.get_state_snapshot() != candidate:
		return StateValidator.failure("inconsistent_snapshot", "El estado, sus referencias o sus efectos no coinciden con el historial confirmado.")
	var result: Dictionary = {"ok": true, "code": "valid_snapshot", "message": "Estado completo validado contra el contenido.", "data": candidate.duplicate(true)}
	if include_history:
		result.history = history
	return result


func _append_transcript_node(history: Array, replay) -> void:
	var node: Dictionary = replay.get_current_node()
	if not node.text.is_empty():
		history.append({"id": "node:" + str(replay.get_state_snapshot().visit_serial), "kind": "node", "speaker": node.get("speaker_name", "Central"), "text": node.text, "node_id": node.id})


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


func is_investigation_closed() -> bool:
	return DispatchRules.is_closed(get_dispatch_catalog(), get_state_snapshot())


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
		elif notification.kind == "deduction":
			deduction_confirmed.emit(notification.id)
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
