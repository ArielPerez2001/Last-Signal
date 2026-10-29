extends SceneTree

const Controller = preload("res://scripts/systems/call_controller.gd")
const Validator = preload("res://scripts/narrative/narrative_validator.gd")
const Narrative = preload("res://scripts/narrative/narrative_engine.gd")
const Failing = preload("res://tests/save/failing_save_manager.gd")
const AudioCatalog = preload("res://scripts/systems/audio_catalog_validator.gd")
const Dispatch = preload("res://scripts/systems/dispatch_manager.gd")
const Deductions = preload("res://scripts/systems/deduction_manager.gd")
var checks: int = 0
var source: Dictionary


func _initialize() -> void:
	call_deferred("_run")


func check(value: bool, label: String) -> void:
	checks += 1
	if not value:
		push_error(label)
		quit(1)
		assert(value,label)


func reject(change: Callable, label: String) -> void:
	var data: Dictionary = source.duplicate(true)
	change.call(data)
	check(not Validator.new().validate(data).ok,label)


func _run() -> void:
	source = JSON.parse_string(FileAccess.get_file_as_string(Controller.OFFICIAL_PATH))
	var report: Dictionary = Validator.new().validate(source)
	check(report.ok and report.warnings.is_empty(),"Official graph valid without absent-resource pretence " + str(report))
	var empty_engine = Narrative.new()
	check(empty_engine.load_case(Controller.OFFICIAL_PATH),"Load before start")
	var unstarted = Deductions.new(empty_engine)
	check(unstarted.get_hypotheses().is_empty() and not unstarted.relate_hypothesis("c001_q01",[]).ok,"Unstarted/failed restore has no active hypotheses")
	reject(func(data: Dictionary) -> void: data.nodes.append(data.nodes[0].duplicate(true)),"Duplicate node")
	reject(func(data: Dictionary) -> void: data.nodes[0].options[0].id=data.nodes[1].options[0].id,"Duplicate choice")
	reject(func(data: Dictionary) -> void: data.nodes[0].options[0].next="missing_node","Missing transition")
	reject(func(data: Dictionary) -> void: data.nodes[0].speaker_id="missing_speaker","Missing character")
	reject(func(data: Dictionary) -> void: data.nodes[0].text_variants=[{"condition":{"op":"equals","target":"missing","value":1},"text":"Invalid"}],"Unknown condition variable")
	reject(func(data: Dictionary) -> void: data.nodes[0].text_rows=[{"condition":{"op":"always"},"text":""}],"Empty dynamic row")
	reject(func(data: Dictionary) -> void: data.nodes[0].text_variants="invalid","Invalid text variants type")
	reject(func(data: Dictionary) -> void: data.nodes[0].panel_id="unsupported","Unknown panel")
	reject(func(data: Dictionary) -> void: data.connection_action="c001_q01","Connection must reference action, not deduction")
	reject(func(data: Dictionary) -> void: data.investigation.actions[0].internal="yes","Internal flag must be boolean")
	reject(func(data: Dictionary) -> void: data.operations.units[0].unit_type="FIRE_TRUCK","No invented fire services")
	reject(func(data: Dictionary) -> void: data.operations.event_rules[0].next="missing","Unknown report destination")
	reject(func(data: Dictionary) -> void: data.operations.event_rules[0].erase("from_node"),"Next requires contextual report")
	reject(func(data: Dictionary) -> void: data.operations.event_rules[0].from_node="missing","Unknown report source")
	reject(func(data: Dictionary) -> void: data.operations.event_rules[2].target_incident_id="c001_i01","No reposition to same incident")
	reject(func(data: Dictionary) -> void: data.operations.event_rules[2].to_unit_status="AVAILABLE","Reposition cannot free R1")
	reject(func(data: Dictionary) -> void: data.nodes[0].entry_effects=[{"op":"set","target":"r1_status","value":"AVAILABLE"}],"No authored binding writes")
	reject(func(data: Dictionary) -> void: data.operations.closed_when={"op":"equals","target":"missing","value":true},"Closed condition validated")
	reject(func(data: Dictionary) -> void: data.audio_analysis.recordings[0].variants[0].available=true,"Empty audio path cannot be advertised playable")
	reject(func(data: Dictionary) -> void: data.audio_analysis.recordings[0].variants[0].audio_path="C:/absent.wav","No absolute audio paths")
	reject(func(data: Dictionary) -> void: data.audio_analysis.discovery_rules[0].discovery_mode="tts","No unknown audio mode")
	reject(func(data: Dictionary) -> void: data.audio_analysis.discovery_rules[0].erase("discovery_mode"),"Zero listen requires explicit consultation")
	reject(func(data: Dictionary) -> void: data.investigation.deductions[0].required_evidence.append("missing"),"Deduction references")
	for record: Dictionary in source.audio_analysis.recordings:
		for variant: Dictionary in record.variants:
			check(not variant.available and variant.audio_path.is_empty(),"Pending assets declared")
	var directory: String = "user://save_tests/c001_fault_%d_%d" % [OS.get_process_id(),Time.get_ticks_usec()]
	var calls = Controller.new(directory,Failing)
	check(calls.prepare_call(Controller.OFFICIAL_PATH).ok,"Official prepare")
	check(calls.answer_call().ok,"Official answer")
	calls.saves.set_autosave_enabled(false)
	var initial: Dictionary = calls.engine.get_state_snapshot()
	check(calls.saves.save_current_session().ok,"Initial durable save")
	var cold_menu: Control = load("res://scenes/core/main.tscn").instantiate()
	cold_menu.official_directory = directory
	root.add_child(cold_menu)
	await process_frame
	check(not cold_menu.main_menu.continue_button.disabled,"Cold menu detects compatible official checkpoint")
	cold_menu.free()
	check(calls.select_choice("c001_n01_o01",initial.revision).ok,"Advance")
	var before: Dictionary = calls.engine.get_state_snapshot()
	calls.saves.fail_write_suffix="slot_01.tmp"
	check(not calls.saves.save_current_session().ok,"Injected write failure reported")
	check(before==calls.engine.get_state_snapshot(),"Failure preserves memory")
	check(calls.saves.validate_save().data.document.session==initial,"Failure preserves durable checkpoint")
	calls.saves.fail_write_suffix=""
	check(calls.retry_save().ok,"Retry same snapshot")
	check(before==calls.engine.get_state_snapshot(),"Retry no narrative effects")
	var tampered: Dictionary = before.duplicate(true)
	tampered.evidence.append("c001_e07")
	check(not calls.engine.restore_state_snapshot(tampered),"Impossible evidence rejected")
	check(before==calls.engine.get_state_snapshot(),"Rejected restore preserves active state")
	var main_path: String = calls.saves.get_paths().main
	var corrupted = FileAccess.open(main_path,FileAccess.WRITE)
	corrupted.store_string("{invalid"); corrupted.close()
	check(calls.saves.validate_save().code=="backup_available","Compatible backup available")
	check(calls.saves.load_saved_session().code=="restored_backup","Backup restores")
	check(calls.engine.get_state_snapshot()==initial,"Exact old checkpoint")
	check(FileAccess.get_file_as_string(main_path)=="{invalid","Recovery conserves original corrupt file")
	check(not calls.engine.load_case("res://data/cases/case_001/absent.json"),"Missing content controlled")
	check(calls.engine.get_state_snapshot()==initial,"Failed content load preserves session")
	var operations = Dispatch.new(calls.engine)
	check(not operations.process_event("c001_u02","c001_r1","c001_i02").ok,"No early report")
	check(not operations.dispatch_unit("missing","c001_i01").ok,"Unknown resource rejected")
	calls.dispose()
	print("CASE001 VALIDATION PASS ",checks," assertions")
	quit(0)
