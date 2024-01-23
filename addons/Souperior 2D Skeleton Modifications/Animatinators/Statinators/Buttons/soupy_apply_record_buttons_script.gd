@tool
extends HBoxContainer

@onready var apply_button: Button = get_child(0)
@onready var record_button: Button = get_child(1)
@onready var editor_inspector: EditorInspector = get_parent().get_parent()

func _ready() -> void:
	apply_button.button_down.connect(_on_apply_pressed)
	record_button.button_down.connect(_on_record_pressed)


func _on_apply_pressed():
	var state_component_node = editor_inspector.get_edited_object() 
	if state_component_node is SoupStateComponent:
		state_component_node.apply()


func _on_record_pressed():
	var state_component_node = editor_inspector.get_edited_object() 
	if state_component_node is SoupStateComponent:
		state_component_node.record()
