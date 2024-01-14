@tool
@icon("Icons/icon_look_at.png")
class_name SoupLookAt
extends SoupMod

## "Souperior" modification for Skeleton2D; Points bone angle at the target.

## Target node for the modification;
## The bone is pointed towards this;
## (!)->  To avoid unintended behaviour, make sure this node is NOT a child of the to-be-modified bone.
@export var target_node: Node2D

## If true, the modification is calculated and applied.
@export var enabled: bool = false

@export_category("Bones")

## The to-be-modified bone node.
@export var bone_node: Bone2D

@export_category("easing")

## If true, easing is appied.
@export var use_easing: bool = false

## Easing Resource;
## Defines the easing behaviour.
@export var easing: SoupySecondOrderEasingNoG: 
	set(new_value):
		if !new_value:
			easing = null
			return
		easing = new_value.duplicate(true)


func _process(delta) -> void:
	if !(
			enabled 
			and target_node 
			and bone_node 
			and _parent_enable_check()
		):
		return
	_handle_look_at(delta)


## [not intended for access]
## Handles the modification.
func _handle_look_at(delta) -> void:
	if !(_mod_stack is SoupStack):
		return
	var skeleton: Skeleton2D = _mod_stack.skeleton
	var target_vector: Vector2 = target_node.global_position - bone_node.global_position
	
	var result_rotation = \
	rotation_global_to_local(
			target_vector.angle() \
			* sign(bone_node.global_scale.y)\
			- bone_node.get_bone_angle(),
			bone_node.get_parent()
		)
	
	if use_easing and easing:
		easing.update(delta,Vector2.RIGHT.rotated(result_rotation))
		result_rotation = easing.state.angle()
	
	var fixed_rotation: float = _mod_stack.apply_bone_rotation_mod(bone_node,result_rotation)
	if fixed_rotation and easing and use_easing:
		easing.state = Vector2.RIGHT.rotated(fixed_rotation)


