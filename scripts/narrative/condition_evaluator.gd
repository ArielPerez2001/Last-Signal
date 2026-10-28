extends RefCounted


static func evaluate(condition: Dictionary, state: Dictionary) -> bool:
	var operation: String = condition.get("op", "always")
	match operation:
		"always":
			return true
		"all":
			for child: Dictionary in condition.conditions:
				if not evaluate(child, state):
					return false
			return true
		"any":
			for child: Dictionary in condition.conditions:
				if evaluate(child, state):
					return true
			return false
		"not":
			return not evaluate(condition.condition, state)
		"once_not_applied":
			return condition.value not in state.applied_once_keys and condition.value not in state.executed_actions
		"contains", "not_contains":
			var present: bool = _contains(condition, state)
			return present if operation == "contains" else not present
		"equals":
			return state.variables[condition.target] == condition.value
		"not_equals":
			return state.variables[condition.target] != condition.value
		"greater_or_equal", "at_least":
			return state.variables[condition.target] >= condition.value
		"less_or_equal", "at_most":
			return state.variables[condition.target] <= condition.value
	return false


static func _contains(condition: Dictionary, state: Dictionary) -> bool:
	if condition.target in ["events", "consumed_events"]:
		for event: Dictionary in state.events:
			if event.event_id == condition.value and (condition.target == "events" or event.id in state.consumed_events):
				return true
		return false
	return condition.value in state[condition.target]
