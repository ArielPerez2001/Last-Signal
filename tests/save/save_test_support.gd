extends SceneTree

const Narrative = preload("res://scripts/narrative/narrative_engine.gd")
const Saves = preload("res://scripts/systems/save_manager.gd")
const CASE_PATH: String = "res://data/cases/test_narrative.json"
var checks: int = 0
var failures: Array[String] = []
var test_directory: String = ""


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	_finish("support")


func _new_directory(label: String) -> String:
	# Tests cannot accept production paths, even through CLI arguments.
	var directory: String = "user://save_tests/" + label + "_%d_%d" % [OS.get_process_id(), Time.get_ticks_usec()]
	_check(directory.begins_with("user://save_tests/") and directory == directory.simplify_path(), "isolated canonical test path")
	_check(DirAccess.make_dir_recursive_absolute(directory) == OK, "create isolated test directory")
	return directory


func _engine():
	var engine = Narrative.new()
	_check(engine.load_case(CASE_PATH) and engine.start_case(), "technical case starts")
	return engine


func _write(path: String, value: Variant) -> void:
	_check(path.begins_with("user://save_tests/") and path == path.simplify_path(), "test writes stay isolated")
	var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	_check(file != null, "test fixture can be written")
	if file != null:
		file.store_string(value if value is String else JSON.stringify(value, "", true, true))
		file.close()


func _document(path: String) -> Dictionary:
	var parser: JSON = JSON.new()
	_check(parser.parse(FileAccess.get_file_as_string(path)) == OK and parser.data is Dictionary, "saved document parses")
	return parser.data if parser.data is Dictionary else {}


func _check(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures.append(message)


func _finish(label: String) -> void:
	if failures.is_empty():
		print("PASS ", label, " checks=", checks, " isolated_path=", test_directory)
		quit(0)
	else:
		for failure: String in failures:
			push_error("FAIL " + failure)
		quit(1)
