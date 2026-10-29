extends SceneTree

const Narrative = preload("res://scripts/narrative/narrative_engine.gd")
const Controller = preload("res://scripts/systems/call_controller.gd")
const Dispatch = preload("res://scripts/systems/dispatch_manager.gd")
const Deductions = preload("res://scripts/systems/deduction_manager.gd")
const Audio = preload("res://scripts/systems/audio_analysis_manager.gd")
const Playback = preload("res://scripts/systems/audio_playback_controller.gd")
const Saves = preload("res://scripts/systems/save_manager.gd")
const State = preload("res://scripts/narrative/narrative_session_state.gd")
const Conditions = preload("res://scripts/narrative/condition_evaluator.gd")
var checks: int = 0
var failures: int = 0
var engine: RefCounted
var dispatch: RefCounted
var deductions: RefCounted
var observed_nodes: Dictionary = {}
var observed_choices: Dictionary = {}
var observed_evidence: Dictionary = {}
var restored_notifications: int = 0
var route_results: Array = []
var directory: String
var saves: RefCounted


func _initialize() -> void:
	call_deferred("_run")


func check(ok: bool, label: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(label)
		quit(1)
		assert(ok, label)


func choose(number: int) -> void:
	var before: Dictionary = engine.get_state_snapshot()
	var id: String = before.current_node + "_o%02d" % number
	check(engine.select_choice(id, before.revision), "Choice " + id + " " + JSON.stringify(engine.get_diagnostics()))
	observed_choices[id] = true
	checkpoint()


func checkpoint() -> void:
	var state: Dictionary = engine.get_state_snapshot()
	observed_nodes[state.current_node] = true
	for id: String in state.evidence:
		observed_evidence[id] = true
	check(engine.validate_state_snapshot(state).ok, "Replay " + state.current_node)
	check(saves.save_current_session().ok, "Save " + state.current_node)
	var second = Narrative.new()
	check(second.load_case(Controller.OFFICIAL_PATH), "Load official for checkpoint")
	var other = Saves.new(second, directory)
	second.evidence_registered.connect(func(_id: String) -> void: restored_notifications += 1)
	second.event_requested.connect(func(_event: Dictionary) -> void: restored_notifications += 1)
	check(other.load_saved_session().ok, "Restore checkpoint")
	check(second.get_state_snapshot() == state, "Exact state " + state.current_node)
	check(second.get_conversation_history() == engine.get_conversation_history(), "Exact history")
	check(restored_notifications == 0, "No repeated consequences")
	other.set_autosave_enabled(false)


func consult(option: int) -> void:
	choose(option)
	choose(1)


func deduction(number: int) -> void:
	var sets: Array = [["c001_e01", "c001_e02"], ["c001_e03", "c001_e04", "c001_e06"], ["c001_e09", "c001_e10"], ["c001_e01", "c001_e05", "c001_e08"]]
	var result: Dictionary = deductions.relate_hypothesis("c001_q%02d" % number, sets[number - 1], engine.get_state_snapshot().revision)
	check(result.ok and result.code == "VALID", "Deduction %d %s" % [number, result])
	var before: Dictionary = engine.get_state_snapshot()
	check(deductions.relate(sets[number - 1]).code == "ALREADY_DISCOVERED", "Deduction idempotent")
	check(before == engine.get_state_snapshot(), "No duplicate deduction effects")
	checkpoint()


func send(patio: bool) -> void:
	choose(6) # N10 -> approved N16, then use real operations.
	var incident: String = "c001_i02" if patio else "c001_i01"
	var result: Dictionary = dispatch.dispatch_unit("c001_r1", incident, engine.get_state_snapshot().revision)
	check(result.ok, "Dispatch R1")
	checkpoint()
	var before: Dictionary = engine.get_state_snapshot()
	check(dispatch.dispatch_unit("c001_r1", incident).code == "ALREADY_PROCESSED", "No duplicate R1")
	check(not dispatch.dispatch_unit("c001_r1", "c001_i01" if patio else "c001_i02").ok, "R1 cannot split")
	check(before == engine.get_state_snapshot(), "Rejected dispatch is pure")
	receive(patio)


func receive(patio: bool) -> void:
	var result: Dictionary = dispatch.process_event("c001_u02" if patio else "c001_u01", "c001_r1", "c001_i02" if patio else "c001_i01")
	check(result.ok, "Receive real report " + str(result))
	check(engine.get_current_node().id == ("c001_n20" if patio else "c001_n19"), "Report moves dialogue atomically")
	var received: Dictionary = engine.get_state_snapshot()
	check(dispatch.process_event("c001_u02" if patio else "c001_u01", "c001_r1", "c001_i02" if patio else "c001_i01").code == "ALREADY_PROCESSED", "Repeated report idempotent")
	check(received == engine.get_state_snapshot(), "No repeated report evidence or movement")
	checkpoint()
	choose(1)


func read_audio() -> void:
	choose(3)
	var physical = Playback.new()
	root.add_child(physical)
	var analyzer = Audio.new(engine, physical)
	check(analyzer.select_recording("c001_g01").ok, "Select pending recording")
	check(physical.get_view().state == "TEXT" and physical.player.stream == null, "No invented recording")
	check(analyzer.set_filter("voces").ok, "Text variant")
	check(analyzer.play_segment("c001_g01_s02").ok, "Select text segment")
	var before: Dictionary = engine.get_state_snapshot()
	check("c001_e03" not in before.evidence, "Selection alone grants no clue")
	check(analyzer.get_accessible_information().contains("No abra al pasillo"), "Approved transcript")
	check(analyzer.consult_selected().ok, "Consult text grants E03 through real manager")
	check("c001_e03" in engine.get_state_snapshot().evidence, "Audio evidence")
	checkpoint()
	before = engine.get_state_snapshot()
	check(analyzer.consult_selected().ok and before == engine.get_state_snapshot(), "Transcript idempotent")
	analyzer.dispose()
	physical.free()
	choose(1)


func route(index: int) -> void:
	var route_index: int = index
	var extended: bool = index in [8,9,10]
	if index == 9: index = 3
	if index == 10: index = 6
	directory = "user://save_tests/c001_flow_%d_%d_%d" % [OS.get_process_id(), Time.get_ticks_usec(), index]
	var calls = Controller.new(directory)
	check(calls.prepare_call(Controller.OFFICIAL_PATH).ok, "Prepare official")
	check(calls.get_view().state == "INCOMING", "Incoming")
	check(calls.answer_call().ok, "Answer")
	engine = calls.engine
	var initial_conditions: Dictionary = engine.get_state_snapshot().variables.duplicate(true)
	dispatch = Dispatch.new(engine)
	deductions = Deductions.new(engine)
	saves = calls.saves
	saves.set_autosave_enabled(false)
	checkpoint()
	if index == 8:
		choose(2); choose(1) # tutorial alternate
	else:
		choose(1)
	choose(2 if index in [2,5,6] else 1)
	choose(1); choose(1); choose(1)
	if index == 8:
		choose(2); choose(1) # protocol alternate N09
	else:
		choose(1)
	choose(1) # N08 -> hub
	var minimal: bool = index in [3,6,7]
	if not minimal:
		if index not in [1,8]:
			consult(1)
		if index in [1,8]:
			read_audio()
		else:
			consult(2)
	if extended:
		consult(4); consult(5)
		choose(6); choose(1) # consulting map and returning never dispatches
	send(index in [1,4,5,8])
	choose(7) # hypothesis panel
	var before: Dictionary = engine.get_state_snapshot()
	check(not deductions.relate_hypothesis("", []).ok, "Hypothesis required")
	check(not deductions.relate_hypothesis("c001_q01", ["c001_e01"]).ok, "Incomplete relation can be corrected")
	check(not deductions.relate_hypothesis("c001_q01", ["c001_e01", "c001_e02", "c001_e06"]).ok, "Extra source rejected")
	check(not deductions.relate_hypothesis("c001_q02", ["c001_e01", "c001_e04"]).ok, "Wrong hypothesis neutral")
	check(before == engine.get_state_snapshot(), "Wrong deduction pure")
	deduction(1)
	if index in [1,2,5,8]: deduction(2)
	choose(1)
	choose(9) # K01
	choose(2 if index in [2,5,6] else 1)
	choose(1); choose(1) # N22 -> N23 -> N24
	if index == 2 or extended:
		choose(1) # back hub
		if index == 2:
			consult(8) # one-time calm
			choose(6)
			check(dispatch.process_event("c001_m05", "c001_r1", "c001_i01").ok, "Reposition R1")
			checkpoint()
			receive(true)
		else:
			choose(7); deduction(3); deduction(4); choose(1)
			consult(11)
		choose(10)
	if index in [6,7]:
		choose(4)
		if index == 7:
			choose(1); choose(4) # cancel warning is safe
		choose(2)
	elif index == 3:
		choose(2)
	else:
		choose(3)
	if index == 2:
		choose(2); choose(3) # cancel prepared plan and prepare again
	var revision: int = engine.get_state_snapshot().revision
	choose(1) # K02
	var expected: String = "C" if index == 6 else ("B" if index in [3,4,5,7] else "A")
	check(engine.get_state_snapshot().variables.resultado == expected, "Ending route TR%02d" % index)
	before = engine.get_state_snapshot()
	check(not engine.select_choice("c001_n25_o01", revision), "Double critical confirmation rejected")
	check(before == engine.get_state_snapshot(), "One K02")
	check(not dispatch.dispatch_unit("c001_r1", "c001_i02").ok, "Closed dispatch")
	check(dispatch.get_unit_status("c001_r1").data.status == "CLOSED", "R1 semantic closed")
	check(dispatch.get_incidents().all(func(item: Dictionary) -> bool: return item.status == "CLOSED"), "Incidents project closed after K02")
	check(not deductions.relate_hypothesis("c001_q03", ["c001_e09", "c001_e10"]).ok, "No acquisition after K02")
	for step: int in range(5): choose(1)
	check(engine.is_case_finished() and engine.get_ending_id() == "c001_final_" + expected.to_lower(), "Terminal stable")
	route_results.append({"route": "TR%02d" % route_index, "initial_conditions": initial_conditions, "decisions": before.transaction_log.map(func(entry: Dictionary) -> String: return entry.choice_id), "ending": expected, "evidence": before.evidence, "deductions": deductions.get_confirmed().map(func(item: Dictionary) -> String: return item.id), "dispatches": before.executed_actions.filter(func(id: String) -> bool: return id.begins_with("assign_") or id in ["c001_m05", "c001_u01", "c001_u02"]), "result": "PASS"})
	check(engine.restart_case(), "Explicit engine restart")
	check(engine.get_state_snapshot().variables.confianza == 1 and engine.get_state_snapshot().evidence.is_empty(), "Restart clean")
	calls.dispose()
	print("TR%02d PASS ending %s" % [route_index, expected])


func _run() -> void:
	for index: int in range(1,11): route(index)
	var data: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(Controller.OFFICIAL_PATH))
	check(data.nodes.filter(func(node: Dictionary) -> bool: return node.type == "dialogue").size() == 38, "38 approved dialogues")
	var count: int = 0
	for node: Dictionary in data.nodes:
		if node.type == "dialogue":
			count += node.options.size()
			check(observed_nodes.has(node.id), "Dialogue coverage " + node.id)
	check(count == 57, "57 approved choices")
	check(observed_choices.size() == 57, "All 57 choices executed by representative routes")
	for id: String in data.evidence_catalog: check(observed_evidence.has(id), "Evidence coverage " + id)
	# Synthetic resolver domain, not a claim that all emotional pairs occur in the story.
	var domain: Dictionary = {"A":0,"B":0,"C":0,"invalid":0}
	for plan: String in ["servicio","refugio","pasillo"]:
		for confidence: int in range(3):
			for stress: int in range(3):
				for interpreted: bool in [false,true]:
					for patio: bool in [false,true]:
						var fixture = Narrative.new()
						check(fixture.load_case(Controller.OFFICIAL_PATH), "Resolver content")
						fixture._state = State.new(data)
						var s: Dictionary = fixture._state.data
						s.current_node = "c001_n25"; s.revision = 1; s.visit_serial = 1
						s.variables.merge({"etapa":"E","plan":plan,"comunicacion":"activa","confianza":confidence,"estres":stress,"r1_status":"BUSY","r1_assignment":"c001_i02" if patio else "c001_i01"},true)
						s.evidence = ["c001_e06"]
						if interpreted: s.executed_actions.append("c001_q02")
						var valid: bool = fixture.select_choice("c001_n25_o01",1)
						if plan == "servicio" and not patio:
							check(not valid, "Invalid service/front")
							domain.invalid += 1
						else:
							var expected: String = "A" if plan == "servicio" and interpreted and confidence >= 1 and stress <= 1 else ("C" if plan == "pasillo" and confidence == 0 and stress == 2 else "B")
							check(valid and fixture.get_state_snapshot().variables.resultado == expected, "Resolver exhaustive disjoint")
							domain[expected] += 1
	check(domain == {"A":4,"B":82,"C":4,"invalid":18}, "108 resolver combinations")
	var output: String = OS.get_environment("TEMP").path_join("ultima_senal_case001_routes.json")
	var file = FileAccess.open(output,FileAccess.WRITE)
	file.store_string(JSON.stringify({"routes":route_results,"domain":domain,"dialogue_nodes":38,"choices":57,"visited_choices":observed_choices.keys(),"checks":checks},"\t"))
	file.close()
	print("CASE001 FLOW PASS ",checks," assertions; matrix ",output)
	quit(0)
