extends Node

signal changed(view: Dictionary)
signal progressed(view: Dictionary)
signal finished(mode: String)
signal playback_error(report: Dictionary)

const Catalog = preload("res://scripts/systems/audio_catalog_validator.gd")
var player: AudioStreamPlayer
var _record: Dictionary = {}
var _filter: String = ""
var _segment: String = ""
var _position: float = 0.0
var _heard: float = 0.0
var _previous_position: float = 0.0
var _state: String = "EMPTY"
var _error: String = ""


func _ready() -> void:
	player = AudioStreamPlayer.new()
	player.max_polyphony = 1
	add_child(player)
	player.finished.connect(_on_finished)


func load_recording(record: Dictionary) -> Dictionary:
	clear()
	_record = record.duplicate(true)
	for variant: Dictionary in _record.get("variants", []):
		if variant.get("available", true) and Catalog.resolve_stream(variant.get("audio_path", "")) != null:
			return set_filter(variant.filter_id)
	return _fail("No hay una variante de audio disponible para esta grabación.")


func clear() -> void:
	if player != null:
		player.stop()
		player.stream = null
	_record = {}
	_filter = ""
	_segment = ""
	_position = 0.0
	_previous_position = 0.0
	_heard = 0.0
	_state = "EMPTY"
	_error = ""
	_publish()


func set_filter(filter_id: String) -> Dictionary:
	if _record.is_empty() or player == null:
		return _fail("Seleccione una grabación disponible.")
	var variant: Dictionary = Catalog.find_variant(_record, filter_id)
	if variant.is_empty() or not variant.get("available", true):
		return _fail("El filtro no está disponible.", false)
	var stream: AudioStream = Catalog.resolve_stream(variant.audio_path)
	if stream == null or stream.get_length() <= 0 or absf(stream.get_length() - _record.duration) > Catalog.DURATION_TOLERANCE:
		return _fail("El recurso del filtro falta o su duración es incompatible.", false)
	if filter_id == _filter and player.stream != null:
		return _ok()
	_sync_position()
	var old_state: String = _state
	player.stop()
	player.stream = stream.duplicate()
	if player.stream is AudioStreamWAV:
		player.stream.loop_mode = AudioStreamWAV.LOOP_DISABLED
	elif player.stream is AudioStreamOggVorbis or player.stream is AudioStreamMP3:
		player.stream.loop = false
	_filter = filter_id
	_heard = 0.0
	_previous_position = _position
	_error = ""
	_state = old_state if old_state in ["PLAYING", "PAUSED", "ENDED"] else "STOPPED"
	if _state in ["PLAYING", "PAUSED"]:
		player.play(_position)
		player.stream_paused = _state == "PAUSED"
	_publish()
	return _ok()


func play() -> Dictionary:
	if player == null or player.stream == null:
		return _fail("No hay audio cargado.")
	if _state == "PLAYING":
		return _ok()
	if _state == "PAUSED":
		player.stream_paused = false
	else:
		if _state == "ENDED":
			_position = _bounds().x
			_heard = 0.0
		player.stream_paused = false
		player.play(_position)
	_previous_position = _position
	_state = "PLAYING"
	_error = ""
	_publish()
	return _ok()


func play_full() -> Dictionary:
	if _segment != "":
		_segment = ""
		_heard = 0.0
		_publish()
	return play()


func play_segment(segment_id: String) -> Dictionary:
	var segment: Dictionary = Catalog.find_segment(_record, segment_id)
	if segment.is_empty():
		return _fail("El segmento no existe.", false)
	if player == null or player.stream == null:
		return _fail("No hay audio cargado.")
	player.stop()
	_segment = segment_id
	_position = float(segment.start_time)
	_heard = 0.0
	_state = "STOPPED"
	return play()


func pause() -> Dictionary:
	if _state == "PLAYING":
		_sync_position()
		player.stream_paused = true
		_state = "PAUSED"
		_publish()
	return _ok()


func stop() -> Dictionary:
	if player != null:
		player.stop()
	_position = _bounds().x
	_previous_position = _position
	_heard = 0.0
	_state = "STOPPED" if not _record.is_empty() and player != null and player.stream != null else "EMPTY"
	_publish()
	return _ok()


func replay() -> Dictionary:
	stop()
	return play()


func seek(seconds: float) -> Dictionary:
	if not is_finite(seconds) or player == null or player.stream == null:
		return _fail("No se puede buscar esa posición.", false)
	var bounds: Vector2 = _bounds()
	_position = clampf(seconds, bounds.x, bounds.y)
	_previous_position = _position
	_heard = 0.0
	if _state in ["PLAYING", "PAUSED"]:
		player.seek(_position)
	else:
		_state = "STOPPED"
	_publish()
	return _ok()


func get_view() -> Dictionary:
	return {"recording_id": _record.get("recording_id", ""), "filter_id": _filter, "segment_id": _segment, "state": _state, "position": _position, "duration": float(_record.get("duration", 0)), "listened_seconds": _heard, "error": _error}


func _process(delta: float) -> void:
	if _state != "PLAYING":
		return
	_sync_position()
	var advanced: float = _position - _previous_position
	# A seek/filter/reset changes the baseline before this callback. Large gaps
	# never count as listening; neither a timer nor a slider grants a clue.
	if advanced > 0 and advanced < 0.25:
		_heard += minf(advanced, delta + 0.02)
	_previous_position = _position
	progressed.emit(get_view())
	if _position >= _bounds().y - 0.025:
		_end()


func _sync_position() -> void:
	if player != null and _state == "PLAYING" and player.playing:
		_position = clampf(player.get_playback_position() + AudioServer.get_time_since_last_mix(), _bounds().x, _bounds().y)


func _bounds() -> Vector2:
	var segment: Dictionary = Catalog.find_segment(_record, _segment)
	return Vector2(float(segment.start_time), float(segment.end_time)) if not segment.is_empty() else Vector2(0, float(_record.get("duration", 0)))


func _on_finished() -> void:
	if _state == "PLAYING":
		_position = _bounds().y
		_end()


func _end() -> void:
	player.stop()
	_position = _bounds().y
	_state = "ENDED"
	_publish()
	finished.emit("segment" if not _segment.is_empty() else "recording")


func _notification(what: int) -> void:
	if what in [NOTIFICATION_APPLICATION_PAUSED, NOTIFICATION_APPLICATION_FOCUS_OUT]:
		pause()


func _ok() -> Dictionary:
	return {"ok": true, "code": "OK", "message": "", "data": get_view()}


func _fail(message: String, fatal: bool = true) -> Dictionary:
	_error = message
	if fatal:
		if player != null:
			player.stop()
		_state = "ERROR"
	var report: Dictionary = {"ok": false, "code": "AUDIO_ERROR", "message": message, "data": {}}
	_publish()
	playback_error.emit(report)
	return report


func _publish() -> void:
	changed.emit(get_view())
