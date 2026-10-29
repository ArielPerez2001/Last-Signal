extends "res://tests/save/save_test_support.gd"

const Map = preload("res://scripts/systems/map_manager.gd")
const Dispatch = preload("res://scripts/systems/dispatch_manager.gd")
const Loader = preload("res://scripts/narrative/narrative_loader.gd")
const Validator = preload("res://scripts/narrative/narrative_validator.gd")
const PATH: String = "res://data/maps/dispatch_demo.json"


func _run() -> void:
	var engine = Narrative.new()
	_check(engine.load_case(PATH), "01 valid operational map")
	var map = Map.new(engine)
	var dispatch = Dispatch.new(engine)
	_check(map.get_map().is_empty(), "no active session has no operational view")
	_check(engine.start_case(), "technical session starts")
	_check(map.get_visible_locations().size() == 2 and map.get_map().districts.size() == 3, "03 known locations and noncanonical sectors")
	_check(not map.get_location("dsp_dock").ok and map.get_location("dsp_dock").data.is_empty(), "hidden location reveals no details")
	_check(dispatch.get_incident("dsp_port") == dispatch.get_incident("missing"), "04 hidden and unknown incident indistinguishable")
	_check(dispatch.get_incidents().is_empty(), "incidents require narrative report")
	_check(dispatch.get_units(true).size() == 2, "06 initial patrol and ambulance available")
	_check(engine.select_choice("dsp_report"), "05 report unlocks two incidents")
	_check(dispatch.get_incidents(true).size() == 2, "two active incidents after real narrative action")
	var before: Dictionary = engine.get_state_snapshot()
	var location: Dictionary = map.get_location("dsp_urban")
	location.data.name = "changed"
	_check(map.get_location("dsp_urban").data.name != "changed" and engine.get_state_snapshot() == before, "queries return detached data without effects")
	_check(engine.select_choice("dsp_verify") and engine.select_choice("dsp_new_port"), "verified alternative reveals port without false-alarm assignment")
	_check(map.get_visible_locations().size() == 3 and dispatch.get_incident("dsp_port").data.status == "ACTIVE" and dispatch.get_incident("dsp_alarm").data.status == "REPORTED", "verification reserves patrol and reveals information")
	before = engine.get_state_snapshot()
	_check(not engine.load_case("res://data/maps/missing_dispatch_test.json") and engine.get_state_snapshot() == before, "unknown map load preserves active session")
	_test_catalog()
	_finish("map_manager")


func _test_catalog() -> void:
	var valid: Dictionary = Loader.load_file(PATH).data
	var validator = Validator.new()
	_check(validator.validate(valid).ok, "catalog valid")
	for field: String in ["map_id", "title", "districts", "locations", "units", "incidents", "event_rules"]:
		var bad: Dictionary = valid.duplicate(true)
		bad.operations.erase(field)
		_check(not validator.validate(bad).ok, "02 missing catalog field: " + field)
	for group: String in ["districts", "locations", "units", "incidents", "event_rules"]:
		for malformed: Variant in [null, true, "invalid", [null]]:
			var bad: Dictionary = valid.duplicate(true)
			bad.operations[group] = malformed
			_check(not validator.validate(bad).ok, "malformed operational collection")
		var bad: Dictionary = valid.duplicate(true)
		bad.operations[group].append(bad.operations[group][0].duplicate(true))
		_check(not validator.validate(bad).ok, "duplicate operational IDs")
	for position: Variant in [[-1, 0], [0, 2], [true, 0.5], [0.2], "bad"]:
		var bad: Dictionary = valid.duplicate(true)
		bad.operations.locations[0].position = position
		_check(not validator.validate(bad).ok, "invalid normalized position")
	for edit: Array in [["units", "unit_type", "FIRE"], ["units", "initial_status", "BUSY"], ["incidents", "location_id", "missing"], ["incidents", "priority", "EXTREME"], ["incidents", "status_variable", "missing"], ["locations", "district_id", "missing"], ["event_rules", "to_unit_status", "AVAILABLE"], ["event_rules", "unit_id", "missing"]]:
		var bad: Dictionary = valid.duplicate(true)
		bad.operations[edit[0]][0][edit[1]] = edit[2]
		_check(not validator.validate(bad).ok, "invalid state/reference/type: " + edit[1])
	var bad: Dictionary = valid.duplicate(true)
	bad.initial_state.variables.patrol_01_assignment = "dsp_med"
	_check(not validator.validate(bad).ok, "initial dangling assignment rejected")
	bad = valid.duplicate(true)
	bad.nodes[0].options[0].effects.append({"op": "set", "target": "patrol_01_status", "value": "BUSY"})
	_check(not validator.validate(bad).ok, "dialogue cannot bypass operational ownership")
	bad = valid.duplicate(true)
	bad.operations.event_rules[0].effects = [{"op": "execute_code"}]
	_check(not validator.validate(bad).ok, "arbitrary event code rejected")
	bad = valid.duplicate(true)
	bad.operations.locations[0].visible_when = {"op": "equals", "target": "missing", "value": true}
	_check(not validator.validate(bad).ok, "existing condition validator checks map conditions")
	bad = valid.duplicate(true)
	bad.operations.event_rules[0].id = "dsp_report"
	_check(not validator.validate(bad).ok, "global action collision rejected")
