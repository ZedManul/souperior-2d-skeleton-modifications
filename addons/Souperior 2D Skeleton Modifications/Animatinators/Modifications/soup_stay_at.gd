@tool
@icon("Icons/icon_stay_at.png")
class_name SoupStayAt
extends SoupMod
## "Souperior" modification for Skeleton2D; 
## Moves bone's global position to a target_node global position;
## Can be used as a jiggle modifier for the bone's position!

## Target node for the modification;
## The bone tries to stay at the global position of this node;
## To avoid unintended behaviour, make sure this node is NOT a child of the to-be-modified bone.
@export var target_node: Node2D

## If true, the modifications are applied.
@export var enabled: bool = false

## The to-be-modified bone node.
@export var bone_node: Bone2D


func process_loop(delta: float) -> void:
	if !(
			enabled 
			and target_node 
			and bone_node
			and _parent_enable_check() 
		):
		return
	var result_position: Vector2 = target_node.global_position

	var fixed_position: Vector2 = \
	_mod_stack.apply_bone_position_mod(
			bone_node, 
			position_global_to_local(
				result_position, bone_node.get_parent()
			)
		)
	
