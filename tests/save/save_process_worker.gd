extends "res://tests/save/save_test_support.gd"


func _run() -> void:
	var args: PackedStringArray = OS.get_cmdline_user_args()
	if args.size() != 2 or not args[1].begins_with("user://save_tests/") or args[1] != args[1].simplify_path():
		_check(false, "worker requires isolated test path")
		_finish("save_process_worker")
		return
	test_directory = args[1]
	var engine = Narrative.new()
	_check(engine.load_case(CASE_PATH), "worker loads compatible content")
	var manager = Saves.new(engine, test_directory)
	if args[0] == "write":
		_check(engine.start_case(), "writer starts a new session")
		_check(engine.select_choice("test_prepare"), "worker commits a choice")
		_check(engine.consume_event(engine.get_pending_events()[0].id), "worker consumes event")
		_check(manager.save_current_session().ok, "worker writes state")
	elif args[0] == "read":
		_check(manager.load_saved_session().ok, "new process restores disk state")
		_check(engine.get_current_node().id == "test_n02", "new process cursor")
		_check(engine.get_state_snapshot().variables.signal == 1 and engine.get_state_snapshot().variables.prepared, "new process logical types and values")
		_check(engine.get_state_snapshot().evidence == ["test_e01"] and engine.get_pending_events().is_empty(), "new process evidence and consumed event")
		_check(engine.select_choice("test_continue") and engine.select_choice("test_finish"), "restored process can continue")
		_check(engine.get_ending_id() == "test_success", "restored process reaches same ending")
	else:
		_check(false, "unknown worker operation")
	_finish("save_process_worker")
