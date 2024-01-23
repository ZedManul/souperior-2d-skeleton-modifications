extends EditorInspectorPlugin

var button_scene = preload("soupy_apply_record_buttons.tscn")
var _object = null

func _can_handle(object: Object) -> bool:
	return object is SoupStateComponent

func _parse_begin(object: Object) -> void:
	_object = object
	var buttons = button_scene.instantiate()
	add_custom_control(buttons)
	buttons.get_node("%Apply Btn").connect("pressed",_on_apply_pressed)
	buttons.get_node("%Record Btn").connect("pressed",_on_record_pressed)


func _on_apply_pressed() -> void:
	_object.apply()

func _on_record_pressed() -> void:
	_object.record()
