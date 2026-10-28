extends "res://scripts/systems/save_manager.gd"

var fail_write_suffix: String = ""
var fail_rename_suffix: String = ""
var corrupt_temporary: bool = false


func _write_text(path: String, text: String) -> Error:
	if not fail_write_suffix.is_empty() and path.ends_with(fail_write_suffix):
		return ERR_FILE_CANT_WRITE
	return super._write_text(path, "{" if corrupt_temporary else text)


func _rename_file(from: String, to: String) -> Error:
	if not fail_rename_suffix.is_empty() and to.ends_with(fail_rename_suffix):
		return ERR_FILE_CANT_WRITE
	return super._rename_file(from, to)
