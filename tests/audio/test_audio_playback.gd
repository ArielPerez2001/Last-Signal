extends "res://tests/save/save_test_support.gd"

const Playback = preload("res://scripts/systems/audio_playback_controller.gd")
const Loader = preload("res://scripts/narrative/narrative_loader.gd")


func _run() -> void:
	var physical = Playback.new()
	root.add_child(physical)
	_check(not physical.play().ok, "play without stream is controlled")
	var record: Dictionary = Loader.load_file("res://data/audio/audio_analysis_demo.json").data.audio_analysis.recordings[0]
	_check(physical.load_recording(record).ok and physical.get_view().state == "STOPPED", "real stream loaded without autoplay")
	_check(physical.play().ok, "real stream starts")
	await create_timer(0.3).timeout
	var position: float = physical.get_view().position
	_check(position > 0.1, "position advances before active filter change")
	_check(physical.set_filter("ambiente").ok and physical.get_view().state == "PLAYING" and absf(physical.get_view().position - position) < 0.15, "filter switch during playback preserves position and active state")
	await create_timer(0.2).timeout
	_check(physical.get_view().position > position + 0.1 and physical.player.max_polyphony == 1, "new variant continues without overlapping player")
	physical.pause()
	position = physical.get_view().position
	_check(physical.set_filter("voces").ok and physical.player.stream_paused and absf(physical.get_view().position - position) < 0.01, "paused filter switch keeps physical pause")
	_check(not physical.seek(NAN).ok and physical.get_view().position == position, "non-finite seek leaves position intact")
	_check(physical.seek(999).ok and physical.get_view().position == 12, "large seek bounded by duration")
	_check(physical.seek(-100).ok and physical.get_view().position == 0, "negative seek bounded by start")
	physical.clear()
	_check(physical.get_view().state == "EMPTY" and physical.player.stream == null, "clear stops and unloads the only player")
	print("PLAYBACK_DRIVER ", AudioServer.get_driver_name(), " human_listening=not_verified")
	# Stop/free the test player and let the native mixer release its voices.
	physical.free()
	await create_timer(0.2).timeout
	_finish("audio_playback")
