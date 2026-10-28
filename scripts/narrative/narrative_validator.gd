extends RefCounted

const SCHEMA_VERSION: int = 1
const INVESTIGATION_SCHEMA_VERSION: int = 2
const Evidence = preload("res://scripts/systems/evidence_manager.gd")
const MAX_SAFE_INTEGER: int = 9007199254740991
const MAX_CONDITION_DEPTH: int = 32
const COLLECTIONS: Array[String] = ["evidence", "events", "consumed_events", "applied_once_keys", "executed_actions"]

var _source: String
var _errors: Array[Dictionary] = []
var _warnings: Array[Dictionary] = []
var _variables: Dictionary = {}
var _nodes: Dictionary = {}
var _edges: Dictionary = {}
var _options: Dictionary = {}
var _once_keys: Dictionary = {}
var _references: Array[Dictionary] = []
var _speakers: Array[String] = []
var _evidence: Array[String] = []
var _events: Array[String] = []
var _endings: Array[String] = []
var _identifier_pattern: RegEx = RegEx.create_from_string("^[a-z][a-z0-9_]*$")


func validate(input: Variant, source: String = "memory") -> Dictionary:
	_reset(source)
	if not input is Dictionary:
		_error("invalid_root", "La raíz debe ser un objeto.", "$")
		return _report()
	var case_data: Dictionary = input
	if not is_integer(case_data.get("schema_version")) or int(case_data.get("schema_version")) not in [SCHEMA_VERSION, INVESTIGATION_SCHEMA_VERSION]:
		_error("incompatible_schema", "Se requiere schema_version 1 o 2 numérico.", "schema_version")
		return _report()
	var fields: Array = ["schema_version", "case_id", "content_version", "title", "initial_node", "initial_state", "variables", "characters", "evidence_catalog", "event_catalog", "endings", "nodes"]
	if int(case_data.schema_version) == INVESTIGATION_SCHEMA_VERSION:
		fields.append("investigation")
	_keys(case_data, fields, "$")
	_identifier(case_data.get("case_id"), "case_id")
	_string(case_data.get("title"), "title")
	_string(case_data.get("content_version"), "content_version")
	_evidence = _catalog(case_data.get("evidence_catalog"), "evidence_catalog")
	_events = _catalog(case_data.get("event_catalog"), "event_catalog")
	_endings = _catalog(case_data.get("endings"), "endings")
	if _endings.is_empty():
		_error("missing_ending", "Debe declararse al menos un desenlace.", "endings")
	_validate_characters(case_data.get("characters"))
	_validate_variables(case_data.get("variables"))
	_validate_initial_state(case_data.get("initial_state"))
	_validate_nodes(case_data.get("nodes"))
	if int(case_data.schema_version) == INVESTIGATION_SCHEMA_VERSION:
		_validate_investigation(case_data.get("investigation"))
	_validate_references()
	if _identifier(case_data.get("initial_node"), "initial_node"):
		if not _nodes.has(case_data.initial_node):
			_error("missing_initial_node", "El nodo inicial no existe.", "initial_node")
		elif _errors.is_empty():
			_analyze_graph(case_data.initial_node)
	return _report()


func _reset(source: String) -> void:
	_source = source
	_errors.clear()
	_warnings.clear()
	_variables.clear()
	_nodes.clear()
	_edges.clear()
	_options.clear()
	_once_keys.clear()
	_references.clear()
	_speakers.clear()
	_evidence.clear()
	_events.clear()
	_endings.clear()


func _validate_investigation(input: Variant) -> void:
	if not input is Dictionary:
		_error("invalid_investigation", "El esquema 2 requiere un catálogo de investigación.", "investigation")
		return
	_keys(input, ["evidence", "deductions", "actions"], "investigation")
	for field: String in ["evidence", "deductions", "actions"]:
		if not input.get(field) is Array:
			_error("invalid_investigation", "Se requiere una lista: " + field, "investigation." + field)
	if not _errors.is_empty():
		return
	var found: Array = []
	for record: Variant in input.evidence:
		if not record is Dictionary:
			_error("invalid_evidence", "Cada evidencia debe ser un objeto.", "investigation.evidence")
			continue
		_keys(record, ["id", "title", "description", "category", "source", "importance", "related_asset", "order"], "investigation.evidence")
		if _identifier(record.get("id"), "investigation.evidence.id"):
			if record.id in found or record.id not in _evidence:
				_error("invalid_evidence", "ID duplicado o no declarado.", "investigation.evidence.id")
			found.append(record.id)
		for field: String in ["title", "description", "source"]:
			_string(record.get(field), "investigation.evidence." + field)
		if not record.get("category") is String or not Evidence.CATEGORIES.has(record.category):
			_error("invalid_category", "Categoría de evidencia desconocida.", "investigation.evidence.category")
		if not record.get("importance") is String or record.importance not in Evidence.IMPORTANCE:
			_error("invalid_importance", "Importancia no reconocida.", "investigation.evidence.importance")
		if record.has("order") and (not is_integer(record.order) or record.order < 0):
			_error("invalid_order", "order debe ser un entero no negativo.", "investigation.evidence.order")
		if record.has("related_asset"):
			var asset: Variant = record.related_asset
			if not asset is String:
				_error("invalid_asset", "related_asset debe ser texto.", "investigation.evidence.related_asset")
			elif not asset.is_empty():
				if not asset.begins_with("res://") or asset != asset.simplify_path() or asset.contains("\\") or asset.get_extension().to_lower() not in ["png", "jpg", "jpeg", "webp", "svg"]:
					_error("invalid_asset", "Solo se permiten imágenes canónicas de res://.", "investigation.evidence.related_asset")
				elif not ResourceLoader.exists(asset, "Texture2D"):
					_warning("missing_optional_asset", "La imagen opcional no existe; se utilizará la descripción textual.", "investigation.evidence.related_asset")
	if found.size() != _evidence.size():
		_error("incomplete_catalog", "Debe existir una ficha para cada ID de evidence_catalog.", "investigation.evidence")
	var combinations: Dictionary = {}
	for group: String in ["deductions", "actions"]:
		for definition: Variant in input[group]:
			if not definition is Dictionary:
				_error("invalid_investigation", "Cada regla/acción debe ser un objeto.", "investigation." + group)
				continue
			var path: String = "investigation." + group
			if _identifier(definition.get("id"), path + ".id"):
				if _options.has(definition.id):
					_error("duplicate_id", "Las opciones, acciones y deducciones requieren ID globalmente únicos.", path + ".id")
				_options[definition.id] = group
			_string(definition.get("title"), path + ".title")
			_effects(definition.get("effects"), path + ".effects", "")
			if group == "actions":
				_keys(definition, ["id", "title", "condition", "effects"], path)
				_condition(definition.get("condition", {"op": "always"}), path + ".condition", "")
			else:
				_keys(definition, ["id", "title", "description", "required_evidence", "additional_conditions", "result_type", "effects", "repeatable", "narrative_feedback"], path)
				_string(definition.get("description"), path + ".description")
				_string(definition.get("narrative_feedback"), path + ".narrative_feedback")
				var required: Array = _catalog(definition.get("required_evidence"), path + ".required_evidence")
				if required.size() not in [2, 3]:
					_error("invalid_combination", "Una deducción requiere dos o tres evidencias distintas.", path)
				for evidence_id: String in required:
					if evidence_id not in _evidence:
						_error("unknown_evidence", "Evidencia requerida inexistente.", path)
				required.sort()
				var key: String = ",".join(required)
				if combinations.has(key):
					_error("ambiguous_combination", "No puede haber dos reglas para la misma combinación.", path)
				combinations[key] = true
				if not definition.get("result_type") is String or definition.result_type != "VALID" or not definition.get("repeatable", false) is bool or definition.get("repeatable", false):
					_error("invalid_deduction", "Solo se admiten reglas VALID no repetibles.", path)
				_condition(definition.get("additional_conditions", {"op": "always"}), path + ".additional_conditions", "")


func _validate_characters(input: Variant) -> void:
	if not input is Array:
		_error("invalid_type", "characters debe ser un array.", "characters")
		return
	for character: Variant in input:
		if not character is Dictionary:
			_error("invalid_type", "Cada personaje debe ser un objeto.", "characters")
			continue
		_keys(character, ["id", "display_name"], "characters")
		_string(character.get("display_name"), "characters.display_name")
		if _identifier(character.get("id"), "characters.id"):
			if character.id in _speakers:
				_error("duplicate_id", "Personaje duplicado: " + character.id, "characters.id")
			_speakers.append(character.id)


func _validate_variables(input: Variant) -> void:
	if not input is Dictionary:
		_error("invalid_type", "variables debe ser un objeto de declaraciones.", "variables")
		return
	for variable_name: Variant in input:
		var path: String = "variables." + str(variable_name)
		if not _identifier(variable_name, path):
			continue
		if variable_name in COLLECTIONS:
			_error("reserved_name", "El nombre está reservado para una colección.", path)
			continue
		var definition: Variant = input[variable_name]
		if not definition is Dictionary or definition.get("type") not in ["int", "bool", "string"]:
			_error("invalid_type", "La variable debe declarar type int, bool o string.", path)
			continue
		_variables[variable_name] = definition
		match definition.type:
			"int":
				_keys(definition, ["type", "min", "max"], path)
				if not is_integer(definition.get("min")) or not is_integer(definition.get("max")):
					_error("invalid_bounds", "min y max deben ser enteros seguros.", path)
				elif definition.min > definition.max:
					_error("invalid_bounds", "min no puede superar max.", path)
			"bool":
				_keys(definition, ["type"], path)
			"string":
				_keys(definition, ["type", "allowed_values"], path)
				if definition.has("allowed_values"):
					var allowed: Variant = definition.allowed_values
					if not allowed is Array or allowed.is_empty():
						_error("invalid_enum", "allowed_values debe ser un array no vacío.", path)
					else:
						var seen: Array = []
						for value: Variant in allowed:
							if not value is String or value in seen:
								_error("invalid_enum", "Los valores deben ser textos únicos.", path)
							seen.append(value)


func _validate_initial_state(input: Variant) -> void:
	if not input is Dictionary:
		_error("invalid_type", "initial_state debe ser un objeto.", "initial_state")
		return
	_keys(input, ["variables", "evidence"], "initial_state")
	if not input.get("variables") is Dictionary:
		_error("invalid_type", "Faltan los valores iniciales de variables.", "initial_state.variables")
	else:
		for variable_name: String in _variables:
			if not input.variables.has(variable_name):
				_error("missing_variable", "Falta el valor inicial de " + variable_name, "initial_state.variables")
			else:
				_value(variable_name, input.variables[variable_name], true, "initial_state.variables." + variable_name)
		for variable_name: Variant in input.variables:
			if not _variables.has(variable_name):
				_error("unknown_variable", "Variable no declarada: " + str(variable_name), "initial_state.variables")
	var initial_evidence: Array[String] = _catalog(input.get("evidence"), "initial_state.evidence")
	for evidence_id: String in initial_evidence:
		if evidence_id not in _evidence:
			_error("unknown_evidence", "Evidencia no declarada: " + evidence_id, "initial_state.evidence")


func _validate_nodes(input: Variant) -> void:
	if not input is Array or input.is_empty():
		_error("invalid_nodes", "nodes debe ser un array no vacío.", "nodes")
		return
	for node: Variant in input:
		if not node is Dictionary or not _identifier(node.get("id"), "nodes.id"):
			if not node is Dictionary:
				_error("invalid_type", "Cada nodo debe ser un objeto.", "nodes")
			continue
		var node_id: String = node.id
		if _nodes.has(node_id):
			_error("duplicate_id", "Nodo duplicado.", "id", node_id)
			continue
		_nodes[node_id] = node
		_edges[node_id] = []
		_effects(node.get("entry_effects", []), "entry_effects", node_id)
		match node.get("type"):
			"dialogue":
				_keys(node, ["id", "type", "speaker_id", "text", "entry_effects", "options"], "node", node_id)
				_string(node.get("text"), "text", node_id)
				if not node.get("speaker_id") is String or node.get("speaker_id") not in _speakers:
					_error("unknown_speaker", "El personaje no está declarado.", "speaker_id", node_id)
				_validate_options(node.get("options"), node_id)
			"transition":
				_keys(node, ["id", "type", "entry_effects", "condition", "next", "fallback_next"], "node", node_id)
				_condition(node.get("condition", {"op": "always"}), "condition", node_id)
				_destination(node.get("next"), "next", node_id)
				if node.has("fallback_next"):
					_destination(node.fallback_next, "fallback_next", node_id)
			"ending":
				_keys(node, ["id", "type", "entry_effects", "ending_id", "text"], "node", node_id)
				if not node.get("ending_id") is String or node.get("ending_id") not in _endings:
					_error("unknown_ending", "El desenlace no está declarado.", "ending_id", node_id)
				if node.has("text"):
					_string(node.text, "text", node_id)
			_:
				_error("unknown_node_type", "Tipo de nodo no reconocido.", "type", node_id)


func _validate_options(input: Variant, node_id: String) -> void:
	if not input is Array or input.is_empty():
		_error("missing_options", "Un diálogo necesita opciones de salida.", "options", node_id)
		return
	var has_unconditional_exit: bool = false
	for option: Variant in input:
		if not option is Dictionary:
			_error("invalid_type", "Cada opción debe ser un objeto.", "options", node_id)
			continue
		var path: String = "options." + str(option.get("id", "?"))
		_keys(option, ["id", "text", "visible_when", "enabled_when", "disabled_reason", "effects", "next"], path, node_id)
		if _identifier(option.get("id"), path + ".id", node_id):
			if _options.has(option.id):
				_error("duplicate_id", "Identificador de opción duplicado en el caso.", path + ".id", node_id)
			_options[option.id] = node_id
		_string(option.get("text"), path + ".text", node_id)
		_condition(option.get("visible_when", {"op": "always"}), path + ".visible_when", node_id)
		_condition(option.get("enabled_when", {"op": "always"}), path + ".enabled_when", node_id)
		if option.has("enabled_when") and not _is_always(option.enabled_when):
			_string(option.get("disabled_reason"), path + ".disabled_reason", node_id)
		elif option.has("disabled_reason") and not option.disabled_reason is String:
			_error("invalid_type", "disabled_reason debe ser texto.", path, node_id)
		_effects(option.get("effects", []), path + ".effects", node_id)
		_destination(option.get("next"), path + ".next", node_id)
		if _is_always(option.get("visible_when", {"op": "always"})) and _is_always(option.get("enabled_when", {"op": "always"})):
			has_unconditional_exit = true
	if not has_unconditional_exit:
		_warning("conditional_exits", "Todas las salidas tienen condiciones; su disponibilidad se comprobará al entrar.", "options", node_id)


func _condition(input: Variant, path: String, node_id: String, depth: int = 0) -> void:
	if not input is Dictionary or depth >= MAX_CONDITION_DEPTH:
		_error("invalid_condition", "Condición inválida o demasiado anidada.", path, node_id)
		return
	match input.get("op"):
		"always":
			_keys(input, ["op"], path, node_id)
		"all", "any":
			_keys(input, ["op", "conditions"], path, node_id)
			if not input.get("conditions") is Array or input.conditions.is_empty():
				_error("invalid_condition", "Se requieren subcondiciones no vacías.", path, node_id)
			else:
				for child: Variant in input.conditions:
					_condition(child, path + ".conditions", node_id, depth + 1)
		"not":
			_keys(input, ["op", "condition"], path, node_id)
			_condition(input.get("condition"), path + ".condition", node_id, depth + 1)
		"once_not_applied":
			_keys(input, ["op", "value"], path, node_id)
			if _identifier(input.get("value"), path + ".value", node_id):
				_references.append({"kind": "once", "value": input.value, "property": path, "node_id": node_id})
		"contains", "not_contains":
			_keys(input, ["op", "target", "value"], path, node_id)
			_validate_membership(input, path, node_id)
		"equals", "not_equals", "greater_or_equal", "less_or_equal", "at_least", "at_most":
			_keys(input, ["op", "target", "value"], path, node_id)
			if not input.get("target") is String or not _variables.has(input.target):
				_error("unknown_variable", "La comparación usa una variable no declarada.", path + ".target", node_id)
			else:
				_value(input.target, input.get("value"), false, path + ".value", node_id)
				if input.op not in ["equals", "not_equals"] and _variables[input.target].type != "int":
					_error("incompatible_type", "Las comparaciones de orden requieren enteros.", path, node_id)
		_:
			_error("unknown_condition", "Operador de condición no reconocido.", path + ".op", node_id)


func _is_always(input: Variant) -> bool:
	return input is Dictionary and input.size() == 1 and input.get("op") is String and input.op == "always"


func _validate_membership(condition: Dictionary, path: String, node_id: String) -> void:
	if not condition.get("target") is String or condition.target not in COLLECTIONS:
		_error("unknown_collection", "Colección no reconocida.", path + ".target", node_id)
		return
	if not _identifier(condition.get("value"), path + ".value", node_id):
		return
	match condition.target:
		"evidence":
			if condition.value not in _evidence:
				_error("unknown_evidence", "Evidencia no declarada.", path, node_id)
		"events", "consumed_events":
			if condition.value not in _events:
				_error("unknown_event", "Evento no declarado.", path, node_id)
		"executed_actions":
			_references.append({"kind": "option", "value": condition.value, "property": path, "node_id": node_id})
		"applied_once_keys":
			_references.append({"kind": "once_key", "value": condition.value, "property": path, "node_id": node_id})


func _effects(input: Variant, path: String, node_id: String) -> void:
	if not input is Array:
		_error("invalid_effect", "Los efectos deben ser un array.", path, node_id)
		return
	for effect: Variant in input:
		if not effect is Dictionary:
			_error("invalid_effect", "Cada efecto debe ser un objeto.", path, node_id)
			continue
		if effect.has("once_key") and _identifier(effect.once_key, path + ".once_key", node_id):
			_once_keys[effect.once_key] = true
		match effect.get("op"):
			"set", "add_clamped":
				_keys(effect, ["op", "target", "value", "once_key"], path, node_id)
				if not effect.get("target") is String or not _variables.has(effect.target):
					_error("unknown_variable", "El efecto usa una variable no declarada.", path + ".target", node_id)
				elif effect.op == "set":
					_value(effect.target, effect.get("value"), true, path + ".value", node_id)
				elif _variables[effect.target].type != "int" or not is_integer(effect.get("value")):
					_error("incompatible_type", "add_clamped requiere variable y delta enteros.", path, node_id)
			"add_to_set":
				_keys(effect, ["op", "target", "value", "once_key"], path, node_id)
				if not effect.get("target") is String or effect.target != "evidence" or not effect.get("value") is String or effect.get("value") not in _evidence:
					_error("unknown_evidence", "Solo se pueden registrar evidencias declaradas en evidence.", path, node_id)
			"mark_once":
				_keys(effect, ["op", "value", "once_key"], path, node_id)
				if _identifier(effect.get("value"), path + ".value", node_id):
					_once_keys[effect.value] = true
			"emit_event":
				_keys(effect, ["op", "event_id", "payload", "once_key"], path, node_id)
				if not effect.get("event_id") is String or effect.get("event_id") not in _events:
					_error("unknown_event", "Evento no declarado.", path + ".event_id", node_id)
				if not effect.get("payload", {}) is Dictionary or not _json_value(effect.get("payload", {})):
					_error("invalid_payload", "payload debe ser un objeto de datos JSON finitos.", path + ".payload", node_id)
			_:
				_error("unknown_effect", "Operación de efecto no reconocida.", path + ".op", node_id)


func _value(variable_name: String, value: Variant, check_bounds: bool, path: String, node_id: String = "") -> void:
	var definition: Dictionary = _variables[variable_name]
	var valid: bool = false
	match definition.type:
		"int":
			valid = is_integer(value)
			if valid and check_bounds:
				valid = is_integer(definition.get("min")) and is_integer(definition.get("max"))
				if valid:
					valid = value >= definition.min and value <= definition.max
		"bool":
			valid = value is bool
		"string":
			valid = value is String
			if valid and definition.has("allowed_values"):
				valid = definition.allowed_values is Array and value in definition.allowed_values
	if not valid:
		_error("incompatible_type", "Valor incompatible con la declaración de " + variable_name + ".", path, node_id)


func _destination(value: Variant, path: String, node_id: String) -> void:
	if _identifier(value, path, node_id):
		_edges[node_id].append(value)
		_references.append({"kind": "node", "value": value, "property": path, "node_id": node_id})


func _validate_references() -> void:
	for reference: Dictionary in _references:
		var valid: bool = false
		match reference.kind:
			"node": valid = _nodes.has(reference.value)
			"option": valid = _options.has(reference.value)
			"once": valid = _once_keys.has(reference.value) or _options.has(reference.value)
			"once_key": valid = _once_keys.has(reference.value)
		if not valid:
			_error("invalid_reference", "Referencia no declarada: " + reference.value, reference.property, reference.node_id)


func _analyze_graph(initial_node: String) -> void:
	var reachable: Dictionary = _walk([initial_node], _edges)
	var reverse_edges: Dictionary = {}
	var ending_nodes: Array = []
	for node_id: String in _nodes:
		reverse_edges[node_id] = []
		if _nodes[node_id].type == "ending":
			ending_nodes.append(node_id)
	for node_id: String in _edges:
		for target: String in _edges[node_id]:
			reverse_edges[target].append(node_id)
	var can_finish: Dictionary = _walk(ending_nodes, reverse_edges)
	for node_id: String in _nodes:
		if not reachable.has(node_id):
			_warning("unreachable_node", "Nodo inalcanzable desde initial_node.", "id", node_id)
		if reachable.has(node_id) and not can_finish.has(node_id):
			_error("no_exit_path", "No hay ruta estructural hacia un desenlace.", "next/options", node_id)
		if _nodes[node_id].type == "transition" and not _has_transition_exit(node_id):
			_error("automatic_cycle", "Cadena automática cerrada sin salida a diálogo o final.", "next", node_id)


func _has_transition_exit(initial_node: String) -> bool:
	var pending: Array = [initial_node]
	var visited: Dictionary = {}
	while not pending.is_empty():
		var node_id: String = pending.pop_back()
		if visited.has(node_id):
			continue
		visited[node_id] = true
		if _nodes[node_id].type != "transition":
			return true
		pending.append_array(_edges[node_id])
	return false


func _walk(initial_nodes: Array, graph: Dictionary) -> Dictionary:
	var pending: Array = initial_nodes.duplicate()
	var visited: Dictionary = {}
	while not pending.is_empty():
		var node_id: String = pending.pop_back()
		if not visited.has(node_id):
			visited[node_id] = true
			pending.append_array(graph[node_id])
	return visited


func _catalog(input: Variant, path: String) -> Array[String]:
	var identifiers: Array[String] = []
	if not input is Array:
		_error("invalid_type", "Se requiere un array de identificadores.", path)
		return identifiers
	for value: Variant in input:
		if _identifier(value, path):
			if value in identifiers:
				_error("duplicate_id", "Identificador duplicado: " + value, path)
			identifiers.append(value)
	return identifiers


func _keys(object: Dictionary, allowed: Array, path: String, node_id: String = "") -> void:
	for key: Variant in object:
		if key not in allowed:
			_error("unknown_property", "Propiedad no reconocida: " + str(key), path + "." + str(key), node_id)


func _identifier(value: Variant, path: String, node_id: String = "") -> bool:
	if not value is String or _identifier_pattern.search(value) == null:
		_error("invalid_identifier", "Se requiere un ID ASCII en minúsculas y snake_case.", path, node_id)
		return false
	return true


func _string(value: Variant, path: String, node_id: String = "") -> bool:
	if not value is String or value.strip_edges().is_empty():
		_error("invalid_type", "Se requiere texto no vacío.", path, node_id)
		return false
	return true


static func is_integer(value: Variant) -> bool:
	if typeof(value) not in [TYPE_INT, TYPE_FLOAT]:
		return false
	return is_finite(float(value)) and absf(float(value)) <= MAX_SAFE_INTEGER and float(value) == floorf(float(value))


func _json_value(value: Variant, depth: int = 0) -> bool:
	if depth >= MAX_CONDITION_DEPTH:
		return false
	match typeof(value):
		TYPE_NIL, TYPE_BOOL, TYPE_STRING, TYPE_INT:
			return true
		TYPE_FLOAT:
			return is_finite(value)
		TYPE_ARRAY:
			for child: Variant in value:
				if not _json_value(child, depth + 1):
					return false
			return true
		TYPE_DICTIONARY:
			for key: Variant in value:
				if not key is String or not _json_value(value[key], depth + 1):
					return false
			return true
	return false


func _error(code: String, message: String, path: String, node_id: String = "") -> void:
	_errors.append({"source": _source, "node_id": node_id, "property": path, "code": code, "message": message})


func _warning(code: String, message: String, path: String, node_id: String = "") -> void:
	_warnings.append({"source": _source, "node_id": node_id, "property": path, "code": code, "message": message})


func _report() -> Dictionary:
	return {"ok": _errors.is_empty(), "errors": _errors.duplicate(true), "warnings": _warnings.duplicate(true)}
