@tool
@icon("Icons/icon_modification.png")
class_name SoupMod
extends Node
## Base node for "Souperior" modifications;
## Does nothing by itself; dont put this in your tree.

## The modification stack this node belongs to.
@onready var _mod_stack: SoupStack = _find_stack()

## The modification sub-stack this node belongs to.
@onready var _mod_sub_stack: Node = get_parent()


func _enter_tree() -> void:
	_mod_sub_stack = get_parent()
	_mod_stack = _find_stack()


## Returns [position] relative to the [parent_node] from [global_pos].
func position_global_to_local(global_pos: Vector2, parent_node: Node2D) -> Vector2:
	return (global_pos - parent_node.global_position)\
			.rotated( -parent_node.global_rotation) \
			/ parent_node.global_scale


## Returns [rotation] relative to the [parent_node] from [global_rot].
func rotation_global_to_local(global_rot: float, parent_node: Node2D) -> float:
	return global_rot - parent_node.global_rotation \
			* sign(parent_node.global_scale.y)


## Returns [global_position] from [position] relative to the [parent_node].
func position_local_to_global(position: Vector2, parent_node: Node2D) -> Vector2:
	return (position * parent_node.global_scale)\
			.rotated(parent_node.global_rotation)\
	 		+ parent_node.global_position


## Returns [global_rotation] from [rotation] relative to the [parent_node].
func rotation_local_to_global(rotation: float, parent_node: Node2D) -> float:
	return rotation + parent_node.global_rotation \
			* sign(parent_node.global_scale.y)


## Fetches the modification stack this node belongs to.
func _find_stack() -> SoupStack:
	var found_node: Node = get_parent()
	for i in 1000:
		if found_node is SoupStack:
			return found_node
		elif found_node is SoupSubStack:
			found_node = found_node.get_parent()
			continue
		elif found_node == get_tree().root:
			break
	return null


## Checks if parent stack structures are enabled.
func _parent_enable_check() -> bool:
	if !(_mod_stack is SoupStack):
		return false
	if (_mod_sub_stack is SoupSubStack):
		return (
				_mod_stack.enabled 
				and _mod_sub_stack.enabled
				and _mod_sub_stack.parent_enabled
				)
	else:
		return _mod_stack.enabled
