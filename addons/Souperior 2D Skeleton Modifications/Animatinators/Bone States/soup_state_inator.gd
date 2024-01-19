@tool
@icon("Icons/icon_state_bone.png")
class_name SoupStateInator
extends Node

signal state_applied(new_state_node: SoupState )


func load_state(state_name: String) -> void:
	var state_node: SoupState
	for i: Node in get_children():
		if i.name == state_name:
			state_node = i
	if !(state_node is SoupState):
		return
	state_node.apply()
	state_applied.emit(state_node)


