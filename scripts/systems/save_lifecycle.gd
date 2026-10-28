extends Node

# Optional adapter: add explicitly alongside a future runtime, not as an autoload.
# It never selects/loads a case, opens UI, or closes the application itself.
var save_manager: RefCounted


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS


func _notification(what: int) -> void:
	if save_manager == null or not save_manager.get_status().data.autosave_enabled:
		return
	if what in [NOTIFICATION_APPLICATION_PAUSED, NOTIFICATION_APPLICATION_FOCUS_OUT, NOTIFICATION_WM_CLOSE_REQUEST]:
		save_manager.flush_pending_save()
	elif what in [NOTIFICATION_APPLICATION_RESUMED, NOTIFICATION_APPLICATION_FOCUS_IN]:
		if save_manager.get_status().data.dirty:
			save_manager.request_autosave()


func prepare_controlled_exit() -> Dictionary:
	if save_manager == null:
		return {"ok": true, "code": "no_manager", "message": "No hay gestor conectado.", "data": {}}
	if not save_manager.get_status().data.autosave_enabled:
		return {"ok": true, "code": "autosave_disabled", "message": "El guardado automático está desactivado.", "data": {}}
	return save_manager.flush_pending_save()
