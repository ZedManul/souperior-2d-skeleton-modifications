@tool
@icon("Icons/icon_look_at.png")
class_name SoupLookAt
extends SoupMod




## "Souperior" modification for Skeleton2D; Points bone angle at the target.

## Target node for the modification;
## The bone is pointed towards this;
## To avoid unintended behaviour, make sure this node is NOT a child of the to-be-modified bone.
@export var target_node: Node2D

## If true, the modification is calculated and applied.
@export var enabled: bool = false

## Offset angle from target, in radians.

## Offset angle from target, in degrees; used for export.
@export_range(-180,180,0.001,"or_greater", "or_less") \
		 var angle_offset_degrees: float = 0:
	set(new_value):
		angle_offset_degrees = wrapf(new_value,-180,180)
		_angle_offset = deg_to_rad(angle_offset_degrees)

## The to-be-modified bone node.
@export var bone_node: Bone2D

@export var ease_rotation: bool = false

## Easing
@export var easing: ZMPhysEasingAngular:
	set(value):
		if value == null:
			easing = null
			return
		easing = value.duplicate(true)
		easing.initialize_variables(_target_vector.angle())


var _angle_offset: float = 0
var _target_vector: Vector2 = Vector2.RIGHT

func process_loop(delta) -> void:
	if !(
			enabled 
			and target_node 
			and bone_node 
			and _parent_enable_check()
		):
		return
	_scale_orient = sign(bone_node.global_transform.determinant())
	_handle_look_at(delta)


## [not intended for access]
## Handles the modification.
func _handle_look_at(delta) -> void:
	if !(_mod_stack is SoupStack):
		return
	var skeleton: Skeleton2D = _mod_stack.skeleton
	_target_vector = target_node.global_position - bone_node.global_position
	
	var target_rotation = _target_vector.angle() \
			- bone_node.get_bone_angle() + _angle_offset * _scale_orient
	if easing != null and ease_rotation:
		easing.update(delta, target_rotation)
		target_rotation = easing.state
	bone_node.global_rotation = target_rotation
	
