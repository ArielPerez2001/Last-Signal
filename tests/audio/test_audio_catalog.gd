extends "res://tests/save/save_test_support.gd"

const Validator = preload("res://scripts/narrative/narrative_validator.gd")
const AudioCatalog = preload("res://scripts/systems/audio_catalog_validator.gd")
const Loader = preload("res://scripts/narrative/narrative_loader.gd")
const PATH: String = "res://data/audio/audio_analysis_demo.json"


func _run() -> void:
	var valid: Dictionary = Loader.load_file(PATH).data
	var validator = Validator.new()
	_check(validator.validate(valid).ok, "01 schema 3 technical case loads")
	_check(valid.audio_analysis.recordings.size() == 1 and valid.audio_analysis.recordings[0].segments.size() == 3, "recording and three segments")
	for variant: Dictionary in valid.audio_analysis.recordings[0].variants:
		var stream: AudioStream = AudioCatalog.resolve_stream(variant.audio_path)
		_check(stream != null and absf(stream.get_length() - 12.0) <= 0.001, "05 synchronized real stream: " + variant.filter_id)
	for bad: Variant in [null, true, [], "invalid"]:
		var changed: Dictionary = valid.duplicate(true)
		changed.audio_analysis = bad
		_check(not validator.validate(changed).ok, "02 malformed catalog rejected")
	for group: String in ["recordings", "discovery_rules"]:
		var changed: Dictionary = valid.duplicate(true)
		changed.audio_analysis[group] = [null]
		_check(not validator.validate(changed).ok, "non-object " + group)
	for field: String in ["recording_id", "title", "description", "case_id", "unlocked_by", "duration", "variants", "segments"]:
		var changed: Dictionary = valid.duplicate(true)
		changed.audio_analysis.recordings[0].erase(field)
		_check(not validator.validate(changed).ok, "required recording field: " + field)
	for field: String in ["duration", "variants", "segments", "waveform", "unlocked_by"]:
		for bad: Variant in [null, true, "wrong"]:
			var changed: Dictionary = valid.duplicate(true)
			changed.audio_analysis.recordings[0][field] = bad
			_check(not validator.validate(changed).ok, "invalid type in " + field)
	for field: String in ["segment_id", "start_time", "end_time", "title", "accessible_information"]:
		var changed: Dictionary = valid.duplicate(true)
		changed.audio_analysis.recordings[0].segments[0].erase(field)
		_check(not validator.validate(changed).ok, "required segment field: " + field)
	for bounds: Array in [[-1, 4], [4, 4], [5, 2], [8, 13]]:
		var changed: Dictionary = valid.duplicate(true)
		changed.audio_analysis.recordings[0].segments[0].start_time = bounds[0]
		changed.audio_analysis.recordings[0].segments[0].end_time = bounds[1]
		_check(not validator.validate(changed).ok, "invalid segment bounds")
	for field: String in ["id", "recording_id", "evidence_id", "segment_id", "filter_id", "min_listen_seconds", "once_only"]:
		var changed: Dictionary = valid.duplicate(true)
		changed.audio_analysis.discovery_rules[0].erase(field)
		_check(not validator.validate(changed).ok, "required discovery field: " + field)
	for group: String in ["variants", "segments"]:
		var changed: Dictionary = valid.duplicate(true)
		changed.audio_analysis.recordings[0][group].append(changed.audio_analysis.recordings[0][group][0].duplicate(true))
		_check(not validator.validate(changed).ok, "duplicate " + group)
	var changed: Dictionary = valid.duplicate(true)
	changed.audio_analysis.recordings.append(changed.audio_analysis.recordings[0].duplicate(true))
	_check(not validator.validate(changed).ok, "duplicate recording")
	changed = valid.duplicate(true)
	changed.audio_analysis.discovery_rules.append(changed.audio_analysis.discovery_rules[0].duplicate(true))
	_check(not validator.validate(changed).ok, "duplicate discovery rule")
	for field: String in ["recording_id", "evidence_id", "segment_id", "filter_id", "event_id"]:
		changed = valid.duplicate(true)
		changed.audio_analysis.discovery_rules[0][field] = "missing"
		_check(not validator.validate(changed).ok, "unknown rule reference: " + field)
	for path: String in ["user://private.wav", "res://assets/../private.wav", "res://scripts/ui/audio_panel.gd", "C:/private.wav"]:
		changed = valid.duplicate(true)
		changed.audio_analysis.recordings[0].variants[0].audio_path = path
		_check(not validator.validate(changed).ok, "unsafe stream path refused")
	changed = valid.duplicate(true)
	changed.audio_analysis.recordings[0].duration = 11
	_check(not validator.validate(changed).ok, "variant duration mismatch rejected")
	changed = valid.duplicate(true)
	changed.audio_analysis.recordings[0].variants[1].audio_path = "res://assets/audio/demo/absent_test.wav"
	var report: Dictionary = validator.validate(changed)
	_check(report.ok and report.warnings.any(func(issue: Dictionary) -> bool: return issue.code == "missing_audio_variant"), "06 missing variant degrades with warning")
	changed = valid.duplicate(true)
	changed.audio_analysis.recordings[0].unlocked_by = {"op": "equals", "target": "undeclared", "value": true}
	_check(not validator.validate(changed).ok, "existing condition validator rejects unknown variable")
	changed = valid.duplicate(true)
	changed.audio_analysis.discovery_rules[0].id = "aud_unlock"
	_check(not validator.validate(changed).ok, "rule ID cannot collide with dialogue")
	changed = valid.duplicate(true)
	changed.audio_analysis.discovery_rules[0]["effects"] = [{"op": "execute_code"}]
	_check(not validator.validate(changed).ok, "arbitrary effects rejected")
	_check(AudioCatalog.find_segment(valid.audio_analysis.recordings[0], "aud_s02").start_time == 4, "07 exact segment bounds")
	_check(AudioCatalog.find_segment(valid.audio_analysis.recordings[0], "missing").is_empty(), "08 unknown segment controlled")
	_finish("audio_catalog")
