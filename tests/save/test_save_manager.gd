extends "res://tests/save/save_test_support.gd"

const FailingSaves = preload("res://tests/save/failing_save_manager.gd")
const Lifecycle = preload("res://scripts/systems/save_lifecycle.gd")


func _run() -> void:
	test_directory = _new_directory("manager")
	var engine = _engine()
	var manager = Saves.new(engine, test_directory)
	var paths: Dictionary = manager.get_paths()
	var initial: Dictionary = engine.get_state_snapshot()
	_check(not manager.has_save().data.exists, "06 missing save")
	_check(manager.load_saved_session().code == "missing_save", "missing load has structured result")
	_check(engine.get_state_snapshot() == initial, "missing load preserves active state")
	_check(manager.save_current_session().ok, "01 create valid primary")
	_check(manager.has_save().data.exists and manager.validate_save().ok, "saved file exists and validates")
	_check(not manager.has_save().data.backup_exists, "first save does not invent prior backup")
	_check(engine.select_choice("test_prepare"), "progress before second save")
	_check(engine.consume_event(engine.get_pending_events()[0].id), "event acknowledgment is persisted")
	var progressed: Dictionary = engine.get_state_snapshot()
	_check(manager.save_current_session().ok, "12 consecutive save")
	_check(manager.has_save().data.backup_exists, "previous checkpoint backed up")
	_check(manager.validate_save(true).data.document.session == initial, "backup contains previous complete state after typed JSON validation")
	var fresh = Narrative.new()
	_check(fresh.load_case(CASE_PATH), "fresh content loads without starting or entering nodes")
	var fresh_manager = Saves.new(fresh, test_directory)
	var notices: Array[String] = []
	fresh.state_changed.connect(func(_state: Dictionary) -> void: notices.append("state"))
	fresh.evidence_registered.connect(func(_id: String) -> void: notices.append("evidence"))
	fresh.event_requested.connect(func(_event: Dictionary) -> void: notices.append("event"))
	fresh.case_finished.connect(func(_id: String) -> void: notices.append("finished"))
	fresh.session_restored.connect(func(_state: Dictionary) -> void: notices.append("restored"))
	_check(fresh_manager.load_saved_session().ok, "02 fresh instance recovers progress")
	_check(fresh.get_state_snapshot() == progressed, "complete snapshot equals saved state")
	_check(typeof(fresh.get_state_snapshot().variables.signal) == TYPE_INT and typeof(fresh.get_state_snapshot().variables.prepared) == TYPE_BOOL, "logical types restored")
	_check(notices == ["restored"], "04 restoration is not a new effect, event, evidence or ending")
	_check(fresh.get_state_snapshot().evidence == ["test_e01"] and fresh.get_pending_events().is_empty(), "03 evidence and consumed events restored without duplication")
	_check(fresh.select_choice("test_continue") and fresh.select_choice("test_finish"), "continue after restoration")
	var finished: Dictionary = fresh.get_state_snapshot()
	_check(fresh_manager.save_current_session().ok, "14 save finished session")
	_check(fresh.restart_case() and fresh_manager.load_saved_session().ok, "restore finished after restart")
	_check(fresh.is_case_finished() and fresh.get_state_snapshot() == finished, "ending and all journals preserved")
	_check(not fresh.select_choice("test_finish"), "finished restored session rejects choices")
	_check(fresh_manager.restore_backup().ok and fresh.get_state_snapshot() == progressed, "explicit backup restores earlier state without writing")
	_write(paths.main, "{")
	var corrupt_bytes: String = FileAccess.get_file_as_string(paths.main)
	var backup_bytes: String = FileAccess.get_file_as_string(paths.backup)
	_check(fresh_manager.load_saved_session().code == "restored_backup", "08 corrupt primary falls back to backup")
	_check(FileAccess.get_file_as_string(paths.main) == corrupt_bytes and FileAccess.get_file_as_string(paths.backup) == backup_bytes, "recovery leaves both originals untouched")
	_check(fresh.get_state_snapshot() == progressed, "fallback restores exact previous snapshot")
	_check(fresh_manager.get_save_metadata().data.recovered_from_backup, "metadata reports backup recovery")
	_check(fresh_manager.save_current_session().ok, "explicit subsequent save can repair primary with valid backup")
	_check(FileAccess.get_file_as_string(paths.backup) == backup_bytes, "corrupt primary never replaces valid backup")
	_test_queries(fresh, fresh_manager)
	_test_failures(fresh, fresh_manager)
	_test_delete(fresh, fresh_manager)
	await _test_autosave()
	_test_process_restart()
	_finish("save_manager")


func _test_queries(engine, manager) -> void:
	var paths: Dictionary = manager.get_paths()
	var main_bytes: String = FileAccess.get_file_as_string(paths.main)
	var backup_bytes: String = FileAccess.get_file_as_string(paths.backup)
	var state: Dictionary = engine.get_state_snapshot()
	var result: Dictionary = manager.get_last_result()
	for iteration: int in range(8):
		_check(manager.has_save().ok and manager.get_save_metadata().data.valid and manager.validate_save().ok, "16 pure existence, metadata and validation queries")
	_check(engine.get_state_snapshot() == state, "queries preserve session")
	_check(FileAccess.get_file_as_string(paths.main) == main_bytes and FileAccess.get_file_as_string(paths.backup) == backup_bytes, "queries preserve file bytes")
	_check(manager.get_last_result() == result, "queries do not change last operation")
	var detached: Dictionary = manager.validate_save()
	detached.data.document.session.variables.signal = 99
	_check(manager.validate_save().data.document.session == state, "query copies detached")


func _test_failures(engine, manager) -> void:
	var paths: Dictionary = manager.get_paths()
	var original: String = FileAccess.get_file_as_string(paths.main)
	var original_state: Dictionary = engine.get_state_snapshot()
	var failing = FailingSaves.new(engine, test_directory)
	failing.fail_write_suffix = "slot_01.tmp"
	_check(not failing.save_current_session().ok, "11 temporary write failure")
	_check(FileAccess.get_file_as_string(paths.main) == original, "write failure preserves last primary")
	failing.fail_write_suffix = "slot_01.bak.tmp"
	_check(not failing.save_current_session().ok, "backup temporary write failure")
	_check(FileAccess.get_file_as_string(paths.main) == original, "backup write failure preserves primary")
	failing.fail_write_suffix = ""
	failing.corrupt_temporary = true
	_check(not failing.save_current_session().ok, "corrupt temporary detected by reread")
	_check(FileAccess.get_file_as_string(paths.main) == original, "temporary verification failure preserves primary")
	failing.corrupt_temporary = false
	for suffix: String in ["slot_01.bak", "slot_01.json"]:
		failing.fail_rename_suffix = suffix
		_check(not failing.save_current_session().ok, "rename failure controlled: " + suffix)
		_check(manager.validate_save().ok, "last valid checkpoint remains recoverable")
	_check(engine.get_state_snapshot() == original_state, "all file failures preserve memory")
	failing.fail_rename_suffix = ""
	_check(failing.save_current_session().ok, "retry succeeds without replaying effects")
	var reentry: Array[Dictionary] = []
	var alias_manager = Saves.new(engine, test_directory.replace("save_tests", "SAVE_TESTS")) if OS.has_feature("windows") else null
	manager.operation_completed.connect(func(_result: Dictionary) -> void:
		reentry.append(manager.save_current_session())
		reentry.append(failing.save_current_session())
		if alias_manager != null:
			reentry.append(alias_manager.save_current_session())
	)
	_check(manager.save_current_session().ok, "normal save with observer")
	_check(reentry.size() == (3 if alias_manager != null else 2) and reentry.all(func(result: Dictionary) -> bool: return result.code == "busy"), "same and different managers, including Windows case aliases, reject concurrent reentry")
	manager.operation_completed.disconnect(manager.operation_completed.get_connections()[0].callable)
	var blocked_path: String = _new_directory("blocked").path_join("file")
	_write(blocked_path, "file obstructs directory")
	_check(not Saves.new(engine, blocked_path.path_join("child")).save_current_session().ok, "real filesystem directory failure controlled")
	for path: String in ["res://saves", "user://", "user://save_tests/../saves", "user://save_tests\\bad"]:
		_check(not Saves.new(engine, path).has_save().ok, "noncanonical save directory refused")


func _test_delete(engine, manager) -> void:
	var paths: Dictionary = manager.get_paths()
	var unrelated: String = test_directory.path_join("unrelated.json")
	_write(unrelated, "keep")
	var state: Dictionary = engine.get_state_snapshot()
	_check(manager.delete_save().ok, "13 explicit primary delete")
	_check(not FileAccess.file_exists(paths.main) and FileAccess.file_exists(paths.backup), "backup preserved by default")
	_check(manager.load_saved_session().code == "restored_backup", "preserved backup remains intentionally recoverable")
	_check(manager.delete_save(true).ok, "explicit deletion includes backup")
	_check(not manager.has_save().data.exists and not manager.has_save().data.backup_exists, "both requested checkpoints removed")
	_check(FileAccess.get_file_as_string(unrelated) == "keep", "unrelated file preserved")
	_check(engine.get_state_snapshot() == state, "deleting disk state does not restart memory")
	_check(not manager.get_status().data.autosave_enabled, "deletion disarms automatic recreation")


func _test_autosave() -> void:
	var directory: String = _new_directory("autosave")
	var engine = _engine()
	var manager = Saves.new(engine, directory)
	manager.set_autosave_enabled(true)
	_check(manager.request_autosave().ok, "autosave of existing session can be requested")
	await process_frame
	await process_frame
	_check(manager.get_status().data.writes == 1, "initial checkpoint persisted")
	_check(engine.select_choice("test_prepare"), "19 stable choice triggers autosave")
	manager.request_autosave()
	manager.request_autosave()
	_check(manager.get_status().data.writes == 1, "no write inside narrative callback")
	await process_frame
	await process_frame
	_check(manager.get_status().data.writes == 2, "redundant requests coalesced into one write")
	_check(manager.validate_save().data.document.session == engine.get_state_snapshot(), "autosave contains committed state")
	_check(engine.consume_event(engine.get_pending_events()[0].id), "event acknowledgment dirties autosave")
	await process_frame
	await process_frame
	_check(manager.get_status().data.writes == 3, "consumption saved without new narrative effects")
	var lifecycle = Lifecycle.new()
	lifecycle.save_manager = manager
	root.add_child(lifecycle)
	for notification_id: int in [Node.NOTIFICATION_APPLICATION_PAUSED, Node.NOTIFICATION_APPLICATION_FOCUS_OUT, Node.NOTIFICATION_WM_CLOSE_REQUEST, Node.NOTIFICATION_APPLICATION_RESUMED, Node.NOTIFICATION_APPLICATION_FOCUS_IN]:
		lifecycle.notification(notification_id)
	await process_frame
	_check(manager.get_status().data.writes == 3, "clean lifecycle notifications do not write")
	_check(engine.select_choice("test_continue"), "progress immediately before background")
	lifecycle.notification(Node.NOTIFICATION_APPLICATION_PAUSED)
	_check(manager.get_status().data.writes == 4, "dirty background notification flushes stable state")
	await process_frame
	_check(manager.get_status().data.writes == 4, "queued callback does not duplicate background flush")
	_check(engine.select_choice("test_finish"), "final transaction with transition")
	await process_frame
	await process_frame
	_check(manager.get_status().data.writes == 5 and manager.get_save_metadata().data.finished, "ending and transition produce one complete save")
	_check(manager.load_saved_session().ok, "restore while autosave connected")
	await process_frame
	_check(manager.get_status().data.writes == 5, "restore does not auto-rewrite slot")
	manager.set_autosave_enabled(false)
	lifecycle.queue_free()
	var failing = FailingSaves.new(engine, _new_directory("auto_failure"))
	failing.fail_write_suffix = "slot_01.tmp"
	failing.set_autosave_enabled(true)
	failing.request_autosave()
	await process_frame
	await process_frame
	_check(not failing.get_last_result().ok and failing.get_status().data.dirty, "failed autosave retained for retry")
	failing.fail_write_suffix = ""
	failing.request_autosave()
	await process_frame
	await process_frame
	_check(failing.get_last_result().ok and not failing.get_status().data.dirty, "explicit retry persists current state")
	failing.set_autosave_enabled(false)
	_check(engine.restart_case(), "restart after persisted ending")
	manager.set_autosave_enabled(true)
	manager.request_autosave()
	_check(manager.delete_save(true).ok, "explicit deletion cancels queued autosave")
	await process_frame
	_check(not manager.has_save().data.exists, "queued callback cannot recreate deleted slot")
	var disabled_lifecycle = Lifecycle.new()
	disabled_lifecycle.save_manager = manager
	root.add_child(disabled_lifecycle)
	disabled_lifecycle.notification(Node.NOTIFICATION_APPLICATION_PAUSED)
	_check(disabled_lifecycle.prepare_controlled_exit().code == "autosave_disabled", "disabled lifecycle respects explicit deletion")
	_check(not manager.has_save().data.exists, "background and exit do not recreate deleted slot")
	disabled_lifecycle.queue_free()
	var manual = Saves.new(engine, _new_directory("manual_flush"))
	_check(manual.flush_pending_save().ok and manual.has_save().data.exists, "manual flush detects unsaved session without signal subscription")


func _test_process_restart() -> void:
	var directory: String = _new_directory("process")
	for operation: String in ["write", "read"]:
		var output: Array = []
		var exit_code: int = OS.execute(OS.get_executable_path(), ["--headless", "--path", ProjectSettings.globalize_path("res://"), "--script", "res://tests/save/save_process_worker.gd", "--", operation, directory], output, true)
		_check(exit_code == 0, "05 separate process " + operation + ": " + str(output))
