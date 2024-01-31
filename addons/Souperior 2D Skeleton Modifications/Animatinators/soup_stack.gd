@tool
@icon("Icons/icon_stack.png")
class_name SoupStack
extends Node
## A skeleton's (spinal) brain;    
## All of the constraints and modifications go through this thing;
## MUST be a direct child of a Skeleton2D node.

## If true, the modifications are applied.
@export var enabled: bool = true

## [not intended for access]
## skeleton affected by the modification stack;
## Must be a direct parent to the stack node for constraints to work.
@onready var skeleton: Skeleton2D = get_parent()


func _enter_tree() -> void:
	skeleton = get_parent()


## Modifies a bone's position and applies constraints;
## Returns the resulting bone position.
func apply_bone_position_mod(bone_node: Bone2D, target_position: Vector2) -> Vector2:
	bone_node.position = apply_position_constraints(bone_node, target_position)
	return bone_node.position


## Modifies a bone's rotation and applies constraints;
## Returns the resulting bone rotation.
func apply_bone_rotation_mod(bone_node: Bone2D, target_rotation: float) -> float:
	bone_node.rotation = apply_rotation_constraints(bone_node,target_rotation)
	return bone_node.rotation


## Applies bone constraints to the current bone rotation and position.
func apply_constraints(bone_node: Bone2D) -> void:
	bone_node.rotation = apply_rotation_constraints(bone_node, bone_node.rotation)
	bone_node.position = apply_position_constraints(bone_node, bone_node.position)


## Returns resulting position from applying constraints to a given bone.
func apply_position_constraints(bone_node: Bone2D, target_position: Vector2) -> Vector2:
	var fixed_position: Vector2 = target_position
	for i in bone_node.get_children():
		if !(i is SoupConstraint):
			continue
		if !i.enabled or !i.limit_position:
			continue
		
		var pos_lim_offset: Vector2 = i.position_limit_offset
		var pos_lim_range: Vector2 = i.position_limit_range
		fixed_position -= pos_lim_offset
		fixed_position = fixed_position.rotated(-i.position_constraint_rotation)
		match i.position_constraint_shape:
		
			i.PosLimitShape.RECTANGLE:
				fixed_position = \
				fixed_position.clamp(
						-pos_lim_range,
						pos_lim_range
					)
		
			i.PosLimitShape.ELLIPSE:
				fixed_position = (fixed_position) / pos_lim_range
				if fixed_position.length_squared() <= 1:
					fixed_position = fixed_position * pos_lim_range
				else:
					fixed_position = fixed_position.normalized() * pos_lim_range
		
		fixed_position = fixed_position.rotated(i.position_constraint_rotation)
		fixed_position += pos_lim_offset
	return fixed_position


## Returns resulting rotation from applying constraints to a given bone.
func apply_rotation_constraints(bone_node: Bone2D, target_rotation: float) -> float:
	var fixed_rotation: float = target_rotation
	for i in bone_node.get_children():
		if !(i is SoupConstraint):
			continue
		if !i.enabled or !i.limit_rotation:
			continue
		
		var rotation_difference: float = angle_difference(i.rotation_limit_angle, target_rotation)
		if abs(rotation_difference) >= i.rotation_limit_range:
			fixed_rotation = i.rotation_limit_angle \
					+ sign(rotation_difference) \
					* i.rotation_limit_range
	
	return fixed_rotation
