@tool
@icon("Icons/icon_state.png")
class_name SoupStateInator
extends Node
## Not necessary, but the intended use is to store multiple property state components in one tidy place;

## Emitted when apply_state() function is called.
signal state_applied(new_state_node: SoupStateComponentGroup )

## Applies a child "state group" node.
func apply_state(state_name: StringName) -> void:
	var state_node: SoupStateComponentGroup
	for i: Node in get_children():
		if i.name == state_name:
			state_node = i
	if !(state_node is SoupStateComponentGroup):
		return
	state_node.apply()
	state_applied.emit(state_node)
