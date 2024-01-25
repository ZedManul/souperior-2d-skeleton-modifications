extends EditorInspectorPlugin

var _object = null

func _can_handle(object: Object) -> bool:
	return object is SoupStateAngleFixInator


func _parse_begin(object: Object) -> void:
	_object = object
	var button: Button = Button.new()
	button.text = "RECORD CURRENT"
	add_custom_control(button)
	button.pressed.connect(_on_record_pressed)


func _on_record_pressed():
	_object.record_current_state()
