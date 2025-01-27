extends EditorInspectorPlugin

var _object

func _can_handle(object: Object) -> bool:
	return object is ArmatureGenerator

func _parse_begin(object: Object) -> void:
	_object = object
	
	var button = Button.new()
	button.text = "Generate"
	add_custom_control(button)
	if !button.pressed.is_connected(_on_button_pressed): 
		button.pressed.connect(_on_button_pressed) 

func _on_button_pressed() -> void:
	_object.generate_armature()
