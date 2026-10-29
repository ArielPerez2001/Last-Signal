extends "res://tests/dispatch/test_dispatch_integration.gd"

var calls_panel: Control
var app: Control
var console_panel: Control


func _run() -> void:
	create_timer(180).timeout.connect(func() -> void:
		_expect(false, "timeout at " + stage)
		_finish()
	)
	if not await _prepare_main():
		_finish()
		return
	app = current_scene
	console_panel = app.console
	calls_panel = console_panel.panels[&"calls"]
	var panel = console_panel.panels[&"map"]
	var archive = console_panel.panels[&"evidence"]
	var audio = console_panel.panels[&"audio"]
	app.official_directory = "user://save_tests/c001_ui_%d_%d" % [OS.get_process_id(),Time.get_ticks_usec()]
	app.refresh_official_save()
	_expect(app.main_menu.continue_button.disabled, "No official save")
	await _shot("menu")
	await _click(app.main_menu.get_node("Content/Actions/NewGame"))
	_expect(app.current_screen == &"console" and calls_panel.controller.get_view().state == "INCOMING", "Official incoming from menu")
	_expect(not calls_panel.get_node("Development").visible and calls_panel.controller.saves.get_paths().main.begins_with("user://save_tests/"), "Official UI has no demo commands; isolated test slot")
	await _shot("incoming")
	_expect(calls_panel.controller.retry_save().ok,"Persist incoming")
	var incoming: Dictionary = calls_panel.controller.engine.get_state_snapshot()
	calls_panel.configure_development_storage("user://save_tests/c001_preanswer_%d" % Time.get_ticks_usec())
	app._open_menu()
	await _click(app.main_menu.continue_button)
	_expect(calls_panel.controller.get_view().state=="INCOMING" and calls_panel.controller.engine.get_state_snapshot()==incoming,"Continue preserves unanswered call")
	_expect(not calls_panel.answer_button.visible and calls_panel.get_node("CurrentText").visible,"Incoming introduction directly offers the real answer; no duplicate responder")
	await step(1); await step(1); await step(1); await step(1); await step(1); await step(1); await step(1)
	_expect(calls_panel.controller.engine.get_current_node().id == "c001_n10", "Reach research hub")
	await _shot("contradiction")
	_expect(calls_panel.options.get_children().filter(func(item: Button) -> bool: return item.visible).size() <= 3,"Hub starts with few primary choices")
	_expect(console_panel.get_node("Guidance/Action").visible,"Current objective offers a relevant next action")
	var history_state: Dictionary = calls_panel.controller.engine.get_state_snapshot()
	await _click(calls_panel.get_node("HistoryToggle"))
	_expect(calls_panel.history_scroll.visible,"History explicitly consultable")
	calls_panel.history_scroll.scroll_vertical = 0
	await _click(calls_panel.get_node("HistoryToggle"))
	_expect(history_state == calls_panel.controller.engine.get_state_snapshot(),"History consultation has no effects")
	await step(3)
	_expect(console_panel.active_section == &"audio", "N13 opens real analyzer")
	await _click(_metadata(audio.get_node("Recordings"),"recording_id","c001_g01"))
	_expect(audio.playback.get_view().state == "TEXT", "Explicit pending audio")
	await _click(_metadata(audio.get_node("Player/Filters"),"filter_id","voces"))
	await _click(_metadata(audio.get_node("Player/Segments"),"segment_id","c001_g01_s02"))
	_expect(not audio.get_node("Player/Transport").visible and not audio.get_node("Player/Register").visible,"Pending audio has one consultation action, no dead transport")
	_expect(not audio.get_node("Player/Accessible").text.contains("No abra al pasillo"),"Transcript opens on explicit reading")
	await _click(audio.get_node("Player/ReadText"))
	_expect(archive.evidence.get_detail("c001_e03").ok and audio.playback.player.stream == null,"Text route adds approved evidence without audio")
	_expect(root.get_visible_rect().encloses(audio.get_node("Player/Accessible").get_global_rect()),"Consultation reveals the complete transcript")
	await _shot("transcript")
	await _click(console_panel.get_node("ActionDock/Buttons/Return"))
	var before: Dictionary = calls_panel.controller.engine.get_state_snapshot()
	await _click(console_panel.navigation.buttons[&"map"])
	_expect(calls_panel.controller.engine.get_state_snapshot()==before,"Map tab itself is a pure navigation action")
	_expect(panel.map_manager.get_visible_locations().size()==2 and panel.dispatch.get_units().size()==1,"Only two approved accesses and R1")
	await _shot("map")
	await _tap(_metadata(panel.get_node("Canvas"),"location_id","c001_l02"))
	_expect(panel.pending.get("unit_id")=="c001_r1" and panel.pending.get("incident_id")=="c001_i02","Single resource/incident selected automatically")
	_expect(calls_panel.controller.engine.get_state_snapshot()==before,"Destination selection is still pure")
	_expect(root.get_visible_rect().encloses(panel.get_node("Confirmation/Confirm").get_global_rect()) and root.get_visible_rect().encloses(panel.get_node("Confirmation/Cancel").get_global_rect()),"Destination automatically reveals both confirmation actions")
	await _shot("confirmation")
	await _click(panel.get_node("Confirmation/Cancel"))
	_expect(before == calls_panel.controller.engine.get_state_snapshot(), "Cancel no dispatch")
	await _click(_metadata(panel.get_node("Locations"),"location_id","c001_l02"))
	await _click(panel.get_node("Confirmation/Confirm"))
	_expect(panel.dispatch.get_unit_status("c001_r1").data.status == "ASSIGNED", "Official assignment")
	before = calls_panel.controller.engine.get_state_snapshot()
	panel._confirm()
	_expect(before == calls_panel.controller.engine.get_state_snapshot(), "Double confirm pure")
	# Close UI/controller and restore from the main menu into fresh real managers.
	_expect(calls_panel.controller.retry_save().ok,"Flush assigned checkpoint")
	calls_panel.development_enabled = true
	calls_panel.configure_development_storage("user://save_tests/c001_empty_%d" % Time.get_ticks_usec())
	app._open_menu()
	await _settle()
	_expect(not app.main_menu.continue_button.disabled,"Compatible official save enables Continue")
	await _click(app.main_menu.continue_button)
	_expect(calls_panel.controller.engine.get_state_snapshot() == before,"Continue restores assignment exactly")
	await _click(console_panel.navigation.buttons[&"map"])
	await _shot("restored")
	await _click(_metadata(panel.get_node("Events"),"event_id","c001_u02"))
	_expect(console_panel.active_section == &"calls" and calls_panel.controller.engine.get_current_node().id=="c001_n20","Part atomically advances and returns to dialogue")
	await step(1)
	await _click(console_panel.navigation.buttons[&"evidence"])
	_expect(console_panel.active_section == &"evidence", "Direct archive tab offers hypotheses")
	await relate_ui(archive,"c001_q01",["c001_e01","c001_e02"])
	await relate_ui(archive,"c001_q02",["c001_e03","c001_e04","c001_e06"])
	_expect(archive.deductions.get_confirmed().size()==2,"Two/three-source hypotheses confirmed through GUI")
	await _shot("deduction")
	console_panel.content_scroll.scroll_vertical = 480
	await _settle()
	var reading_position: int = console_panel.content_scroll.scroll_vertical
	var reading_state: Dictionary = calls_panel.controller.engine.get_state_snapshot()
	await _click(console_panel.navigation.buttons[&"map"])
	await _click(console_panel.navigation.buttons[&"evidence"])
	_expect(console_panel.content_scroll.scroll_vertical == reading_position and calls_panel.controller.engine.get_state_snapshot() == reading_state,"Tab changes preserve reading position and narrative state")
	_expect(console_panel.navigation.buttons[&"calls"].get_node("Content/ActiveMarker").text=="NUEVO","New conversation response is signalled outside Calls")
	await _click(console_panel.get_node("ActionDock/Buttons/Return"))
	before = calls_panel.controller.engine.get_state_snapshot()
	for section: StringName in [&"audio", &"map", &"evidence", &"calls"]:
		await _click(console_panel.navigation.buttons[section])
	_expect(before == calls_panel.controller.engine.get_state_snapshot(),"All navigation read-only")
	await step(9)
	await _shot("revelation")
	await step(1); await step(1); await step(1); await step(3)
	_expect(calls_panel.controller.engine.get_current_node().text.contains("puerta junto al baño"),"Q02 gives precise instruction")
	_expect(not calls_panel.controller.engine.get_current_node().text.contains("confianza ="),"Internal emotion numbers hidden")
	await _shot("critical")
	await step(1)
	_expect(calls_panel.controller.engine.get_state_snapshot().variables.resultado=="A","GUI reaches A")
	await _shot("ending_a")
	for index: int in range(4): await step(1)
	_expect(calls_panel.controller.engine.get_current_node().id=="c001_n37","Basic narrative resolution")
	await _shot("resolution")
	await step(1)
	_expect(app.current_screen==&"menu","Approved final choice returns to menu")
	before = calls_panel.controller.engine.get_state_snapshot()
	await _click(app.main_menu.get_node("Content/Actions/NewGame"))
	_expect(app._confirmation.visible and before==calls_panel.controller.engine.get_state_snapshot(),"Replacement asks before mutating")
	app._confirmation.get_cancel_button().pressed.emit()
	app._confirmation.hide()
	_expect(before==calls_panel.controller.engine.get_state_snapshot(),"Cancel replacement preserves completed case")
	await _click(app.main_menu.continue_button)
	await _click(console_panel.navigation.buttons[&"evidence"])
	_expect(archive.get_node("Relate").disabled and archive.evidence.get_discovered().size()==before.evidence.size(),"Closed archive read-only")
	await _shot("closed_archive")
	app._open_menu()
	await _click(app.main_menu.get_node("Content/Actions/NewGame"))
	app._confirmation.hide()
	app._confirmation.confirmed.emit()
	await _settle()
	_expect(calls_panel.controller.get_view().state=="INCOMING" and calls_panel.controller.engine.get_state_snapshot().evidence.is_empty(),"Confirmed new game resets official case")
	# Unrecoverable save stays intact and Continue is disabled.
	_expect(calls_panel.controller.retry_save().ok,"Save initial checkpoint")
	var path: String = calls_panel.controller.saves.get_paths().main
	calls_panel.configure_development_storage("user://save_tests/c001_empty2_%d" % Time.get_ticks_usec())
	var broken = FileAccess.open(path, FileAccess.WRITE)
	broken.store_string("{broken"); broken.close()
	app._open_menu()
	await _settle()
	_expect(app.main_menu.continue_button.disabled and FileAccess.get_file_as_string(path)=="{broken","Invalid save not replaced or offered")
	if failures.is_empty(): print("CASE001 GUI PASS checks=",checks," window=",root.size," renderer=",DisplayServer.get_name())
	_finish()


func step(number: int) -> void:
	await _click(console_panel.navigation.buttons[&"calls"])
	var id: String = calls_panel.controller.engine.get_current_node().id + "_o%02d" % number
	var button: Button = _choice(calls_panel,id)
	if button == null:
		_expect(false,"Missing GUI choice " + id)
		return
	if not button.is_visible_in_tree() and calls_panel.get_node("MoreOptions").visible:
		await _click(calls_panel.get_node("MoreOptions"))
	await _click(button)
	if console_panel.active_section == &"calls" and calls_panel.controller.get_view().state == "CONNECTED":
		_expect(calls_panel.get_node("CurrentText").is_visible_in_tree() and calls_panel.get_node("CurrentText").text == calls_panel.controller.engine.get_current_node().text,"Current intervention matches its choices independently of historical scroll")


func relate_ui(archive, id: String, evidence_ids: Array) -> void:
	var picker: OptionButton = archive.get_node("HypothesisPicker")
	await _click(picker)
	_expect(picker.get_popup().visible,"Hypothesis selector opens")
	picker.get_popup().hide()
	for index: int in range(1,picker.item_count):
		if picker.get_item_metadata(index)==id:
			picker.select(index)
			picker.item_selected.emit(index)
			await _settle()
			break
	for selected: String in evidence_ids:
		await _click(archive.cards[selected].get_node("Content/Actions/Select"))
	_expect(root.get_visible_rect().encloses(console_panel.get_node("ActionDock/Buttons/Confirm").get_global_rect()),"Confirmation stays visible while selecting sources")
	if id == "c001_q02":
		await _shot("deduction_selection")
	await _click(console_panel.get_node("ActionDock/Buttons/Confirm"))
	_expect(archive.result.ok and archive.result.data.id==id,"Selected hypothesis " + id)
	_expect(archive.selected_ids.is_empty(),"Confirmed relation clears temporary selection")
