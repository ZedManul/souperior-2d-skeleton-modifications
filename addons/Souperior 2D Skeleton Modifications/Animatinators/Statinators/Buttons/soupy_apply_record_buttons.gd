extends EditorInspectorPlugin

var button_scene = preload("soupy_apply_record_buttons.tscn")

func _can_handle(object: Object) -> bool:
	return object is SoupStateComponent

func _parse_begin(object: Object) -> void:
	var buttons = button_scene.instantiate()
	add_custom_control(buttons)
	
