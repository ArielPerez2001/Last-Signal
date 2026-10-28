extends RefCounted


static func apply(effects: Array, state: Dictionary, definitions: Dictionary, scope: String, pending: Array[Dictionary]) -> String:
	for effect_index: int in range(effects.size()):
		var effect: Dictionary = effects[effect_index]
		var effect_key: String = scope + ":" + str(effect_index)
		var once_key: String = effect.get("once_key", "")
		if effect_key in state.applied_effects or (not once_key.is_empty() and once_key in state.applied_once_keys):
			continue
		match effect.op:
			"set":
				state.variables[effect.target] = int(effect.value) if definitions[effect.target].type == "int" else effect.value
			"add_clamped":
				var definition: Dictionary = definitions[effect.target]
				state.variables[effect.target] = clampi(int(state.variables[effect.target]) + int(effect.value), int(definition.min), int(definition.max))
			"add_to_set":
				if effect.value not in state.evidence:
					state.evidence.append(effect.value)
					pending.append({"kind": "evidence", "id": effect.value})
			"mark_once":
				if effect.value not in state.applied_once_keys:
					state.applied_once_keys.append(effect.value)
			"emit_event":
				var event: Dictionary = {
					"id": effect_key,
					"event_id": effect.event_id,
					"payload": effect.get("payload", {}).duplicate(true),
				}
				state.events.append(event)
				pending.append({"kind": "event", "event": event})
			_:
				return "Efecto no reconocido: " + str(effect.op)
		state.applied_effects.append(effect_key)
		if not once_key.is_empty() and once_key not in state.applied_once_keys:
			state.applied_once_keys.append(once_key)
	return ""
