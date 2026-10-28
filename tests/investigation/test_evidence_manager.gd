extends "res://tests/save/save_test_support.gd"

const Evidence = preload("res://scripts/systems/evidence_manager.gd")
const Validator = preload("res://scripts/narrative/narrative_validator.gd")
const Loader = preload("res://scripts/narrative/narrative_loader.gd")
const INVESTIGATION_PATH: String = "res://data/cases/investigation_demo.json"


func _run() -> void:
	test_directory = _new_directory("evidence")
	var engine = Narrative.new()
	_check(engine.load_case(INVESTIGATION_PATH), "01 validated catalog loads")
	var evidence = Evidence.new(engine)
	_check(engine.get_investigation_catalog().evidence.size() == 5, "five definitions available internally")
	_check(evidence.get_discovered().is_empty(), "no discoveries before answering")
	_check(not evidence.get_detail("inv_e01").ok and evidence.get_detail("inv_e01").data.is_empty(), "05 hidden evidence reveals no content")
	_check(engine.start_case() and engine.select_choice("inv_testimony"), "03 narrative effect discovers evidence")
	_check(evidence.get_discovered().size() == 1, "one discovered record")
	var notifications: Array[String] = []
	evidence.evidence_discovered.connect(func(id: String) -> void: notifications.append(id))
	_check(engine.select_choice("inv_repeat") and engine.select_choice("inv_repeat"), "04 repeated acquisition routes are valid")
	_check(engine.get_state_snapshot().evidence == ["inv_e01"] and notifications.is_empty(), "no repeated evidence or discovery signal")
	var before: Dictionary = engine.get_state_snapshot()
	var detail: Dictionary = evidence.get_detail("inv_e01")
	_check(detail.ok and detail.data.source.contains("declaración"), "06 title description category and source available")
	_check(not detail.data.has("importance"), "internal importance never exposed to player")
	detail.data.description = "tampered"
	_check(evidence.get_detail("inv_e01").data.description != "tampered", "details detached")
	_check(evidence.get_categories() == [{"id": "testimony", "title": "Testimonios"}], "only discovered categories exposed")
	_check(engine.get_state_snapshot() == before, "queries preserve narrative state")
	_check(not evidence.discover_from_action("unknown").ok, "unknown registration route rejected")
	_check(evidence.discover_from_action("inv_read_transcript").code == "LOCKED", "authorized route enforces requirements")
	_check(evidence.get_available_actions().is_empty(), "unavailable source titles not exposed before their prerequisite")
	_check(engine.select_choice("inv_document") and engine.select_choice("inv_log"), "three narrative discoveries")
	_check(evidence.discover_from_action("inv_read_transcript").ok and evidence.discover_from_action("inv_read_comparison").ok, "two authorized non-dialogue routes")
	_check(evidence.get_discovered().size() == 5 and evidence.get_categories().size() == 5, "all five categories supported centrally")
	_check(notifications == ["inv_e02", "inv_e03", "inv_e04", "inv_e05"], "notifications distinguish actual new discoveries")
	before = engine.get_state_snapshot()
	_check(evidence.discover_from_action("inv_read_transcript").code == "ALREADY_DISCOVERED", "action cannot award twice")
	_check(engine.get_state_snapshot() == before, "repeated external action leaves revision and journals unchanged")
	_check(evidence.get_discovered("audio").size() == 1, "category filtering")
	_check(evidence.get_detail("inv_e02").data.asset_available, "validated existing texture supported")
	_check(not evidence.get_detail("inv_e04").data.asset_available, "missing optional resource is safe")
	_test_catalog_validation()
	evidence.dispose()
	_finish("evidence_manager")


func _test_catalog_validation() -> void:
	var valid: Dictionary = Loader.load_file(INVESTIGATION_PATH).data
	var validator = Validator.new()
	_check(validator.validate(valid).ok, "catalog valid")
	var changed: Dictionary = valid.duplicate(true)
	changed.investigation.evidence[1].id = "inv_e01"
	_check(not validator.validate(changed).ok, "02 duplicate evidence definition rejected")
	for field: String in ["id", "title", "description", "category", "source", "importance"]:
		changed = valid.duplicate(true)
		changed.investigation.evidence[0].erase(field)
		_check(not validator.validate(changed).ok, "missing essential catalog field: " + field)
	for field: String in ["title", "description", "source", "category", "importance", "order", "related_asset"]:
		for bad: Variant in [null, [], {}, true]:
			changed = valid.duplicate(true)
			changed.investigation.evidence[0][field] = bad
			_check(not validator.validate(changed).ok, "malformed evidence value: " + field)
	changed = valid.duplicate(true)
	changed.investigation.evidence[0].category = "unknown"
	_check(not validator.validate(changed).ok, "unknown category rejected")
	changed = valid.duplicate(true)
	changed.investigation.evidence.pop_back()
	_check(not validator.validate(changed).ok, "missing catalog record rejected")
	for path: String in ["user://private.png", "res://assets/../private.png", "res://scripts/ui/calls_panel.gd"]:
		changed = valid.duplicate(true)
		changed.investigation.evidence[0]["related_asset"] = path
		_check(not validator.validate(changed).ok, "unsafe resource path refused")
	changed = valid.duplicate(true)
	changed.investigation.evidence[0]["related_asset"] = "res://assets/ui/icons/missing_optional_test.svg"
	var report: Dictionary = validator.validate(changed)
	_check(report.ok and report.warnings.any(func(warning: Dictionary) -> bool: return warning.code == "missing_optional_asset"), "optional absent texture warns without invalidating text")
