@tool
@icon("Icons/customModificationIcon.png")
extends Node
class_name SoupMod
## Base node for "Souperior" modifications;
## Does nothing by itself; dont put this in your tree.

## The modification stack this node belongs to.
@onready var ModStack: SoupStack = find_stack()

## The modification sub-stack this node belongs to.
@onready var SubStack: Node = get_parent()


func _enter_tree() -> void:
	SubStack = get_parent()
	ModStack = find_stack()


## Returns [position] relative to the [parentNode] from [global_pos].
func PositionGlobalToLocal( global_pos: Vector2, parentNode: Node2D) -> Vector2:
	return (global_pos - parentNode.global_position)\
	.rotated(-parentNode.global_rotation)\
	/parentNode.global_scale


## Returns [rotation] relative to the [parentNode] from [global_rot].
func AngleGlobalToLocal( global_rot: float, parentNode: Node2D) -> float:
	return (global_rot - parentNode.global_rotation*sign(parentNode.global_scale.y))


## Returns [global_position] from [position] relative to the [parentNode].
func PositionLocalToGlobal( position: Vector2, parentNode: Node2D) -> Vector2:
	return (position*parentNode.global_scale).rotated(parentNode.global_rotation)\
	 + parentNode.global_position


## Returns [global_rotation] from [rotation] relative to the [parentNode].
func AngleLocalToGlobal( angle: float, parentNode: Node2D) -> float:
	return (angle + parentNode.global_rotation*sign(parentNode.global_scale.y))


## Returns [global_rotation] from [rotation] relative to the [parentNode].
func find_stack() -> SoupStack:
	var foundNode: Node = get_parent()
	for i in 1000:
		if foundNode is SoupStack:
			return foundNode
		elif foundNode is SoupSubStack:
			foundNode = foundNode.get_parent()
			continue
		elif foundNode == get_tree().root:
			break
	return null


## Checks if parent stack structures are enabled.
func parent_enable_check() -> bool:
	if !(ModStack is SoupStack):
		return false
	if (SubStack is SoupSubStack):
		return (ModStack.Enabled) and (SubStack.Enabled)
	else:
		return ModStack.Enabled
