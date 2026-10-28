extends RefCounted


static func load_file(path: String) -> Dictionary:
	if not path.begins_with("res://") or path != path.simplify_path() or path.contains("\\") or path.get_extension() != "json":
		return _failure(path, "unauthorized_path", "Solo se permiten rutas JSON canónicas dentro de res://.")
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	if file == null:
		return _failure(path, "read_error", "No se pudo leer el archivo: " + error_string(FileAccess.get_open_error()))
	var json: JSON = JSON.new()
	var parse_error: Error = json.parse(file.get_as_text())
	if parse_error != OK:
		return _failure(path, "invalid_json", "Línea %d: %s" % [json.get_error_line(), json.get_error_message()])
	if not json.data is Dictionary:
		return _failure(path, "invalid_root", "La raíz del JSON debe ser un objeto.")
	return {"ok": true, "data": json.data, "errors": [], "warnings": []}


static func _failure(path: String, code: String, message: String) -> Dictionary:
	return {"ok": false, "data": {}, "errors": [{
		"source": path, "node_id": "", "property": "$", "code": code, "message": message,
	}], "warnings": []}
