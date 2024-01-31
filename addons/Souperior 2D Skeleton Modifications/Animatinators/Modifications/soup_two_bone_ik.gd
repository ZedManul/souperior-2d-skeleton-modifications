@tool
@icon("Icons/icon_two_bone_ik.png")
class_name SoupTwoBoneIK
extends SoupMod

## "Souperior" custom modification for Skeleton2D; 
## Affects two bones to end at a target, if possible.

## Target node for the modification;
## Defines the point which the bones try to reach;
## To avoid unintended behaviour, make sure this node is NOT a child of the to-be-modified bones.
@export var target_node: Node2D

## If true, the modification is calculated and applied.
@export var enabled: bool = false

## Flips the bend direction.
@export var flip_bend_direction: bool = false

## softness slows down the bones as the chain straightens;
## With 0 softness, IK bones may move very quickly just before the target goes out of range, 
## which is usually undesirable
@export_range(0, 1, 0.01, "or_greater", "or_less") var softness: float = 0:
	set(new_value):
		softness=clampf(new_value,0,1)

@export_category("Bones")

## Bone node which will be modified to act as the first joint.
@export var joint_one_bone_node: Bone2D

## Bone node which will be modified to act as the first joint;
## Must be a child of the first joint bone for the modification to work properly;
## Do NOT affect this bone by any other modifications.
@export var joint_two_bone_node: Bone2D

## (OPTIONAL) A child node of the second node marking the end of the chain;
## Without a chain tip, the modification instead will use second bone's length and angle.
@export var chain_tip: Node2D = null

#region Easing
@export_category("Easing")
@export_group("Joint One")

## If true, easing is appied to the first joint.
@export var use_easing_on_first_joint: bool = false

## Easing Resource;
## Defines easing behaviour for the first joint.
@export var first_joint_easing: SoupySecondOrderEasingNoG:
	set(new_value):
		if !new_value:
			first_joint_easing = null
			return
		first_joint_easing = new_value.duplicate(true)

@export_group("Joint Two")

## If true, easing is appied to the second joint.
@export var use_easing_on_second_joint: bool = false

## Easing Resource;
## Defines easing behaviour for the second joint.
@export var second_joint_easing: SoupySecondOrderEasingNoG:
	set(new_value):
		if !new_value:
			second_joint_easing = null
			return
		second_joint_easing = new_value.duplicate(true)
#endregion

## [not intended for access]
## Used for calculations.
var _target_vector: Vector2

## [not intended for access]
## Used for calculations.
var _first_bone_vector: Vector2

## [not intended for access]
## Used for calculations.
var _second_bone_vector: Vector2


func _process(delta) -> void:
	if !(
			enabled 
			and target_node 
			and joint_one_bone_node
			and joint_two_bone_node
			and _parent_enable_check()
		):
		return
	
	_handle_ik(delta)


## [not intended for access]
## Handles the modification.
func _handle_ik(delta: float) -> void:
	if !(_mod_stack is SoupStack):
		return
	var skeleton: Skeleton2D = _mod_stack.skeleton
	_target_vector = _calculate_target_vector()
	var distance: float = _target_vector.length()
	
	_first_bone_vector = _vectorize_first_bone()
	_second_bone_vector = _vectorize_second_bone()
	
	#region Angle calculation modifiers
	var bend_direction_coefficient: int = (int(!flip_bend_direction)*2 - 1)
	#endregion
	
	#initializing calculation result variables
	var bone_rotation: float = (_target_vector.angle() \
	- joint_one_bone_node.get_parent().global_rotation) \
	* sign(joint_one_bone_node.global_scale.y) \
	+ bend_direction_coefficient * _calculate_first_joint_rotation() \
	- _first_bone_vector.angle()
	
	if use_easing_on_first_joint and first_joint_easing:
		first_joint_easing.update(delta,Vector2.RIGHT.rotated(bone_rotation))
		bone_rotation = first_joint_easing.state.angle()
	
	var fixed_rotation: float = _mod_stack.apply_bone_rotation_mod(joint_one_bone_node,bone_rotation)
	if fixed_rotation and first_joint_easing and use_easing_on_first_joint:
		first_joint_easing.state = Vector2.RIGHT.rotated(fixed_rotation)
	#region handling second joint
	bone_rotation = _calculate_second_joint_rotation()\
	* sign(joint_one_bone_node.global_scale.y) \
	- _second_bone_vector.angle()
	
	
	
	if use_easing_on_second_joint and second_joint_easing:
		second_joint_easing.update(delta,Vector2.RIGHT.rotated(bone_rotation))
		bone_rotation = second_joint_easing.state.angle()
	fixed_rotation = _mod_stack.apply_bone_rotation_mod(joint_two_bone_node,bone_rotation)
	if fixed_rotation and second_joint_easing and use_easing_on_second_joint:
		second_joint_easing.state = Vector2.RIGHT.rotated(fixed_rotation)
	#endregion


func _vectorize_first_bone() -> Vector2:
	return joint_two_bone_node.position * abs(joint_one_bone_node.global_scale)

func _vectorize_second_bone() -> Vector2:
	if chain_tip:
		return chain_tip.position * abs(joint_two_bone_node.global_scale)
	
	return Vector2(
			joint_two_bone_node.get_length(),
			0
			).rotated(joint_two_bone_node.get_bone_angle()) * abs(joint_two_bone_node.global_scale)

## [not intended for access]
## Handles additional calculations to account for softness.
func _calculate_target_vector() -> Vector2:
	var raw_vector: Vector2 = target_node.global_position - joint_one_bone_node.global_position
	var bone_length_difference: float = abs(_first_bone_vector.length() - _second_bone_vector.length())
	
	var full_length: float \
	= (_first_bone_vector.length() + _second_bone_vector.length()) \
	- bone_length_difference
	var distance_ratio: float = (raw_vector.length()-bone_length_difference)/full_length
	var result_vector: Vector2 = raw_vector
	if softness>0 and distance_ratio<(1+softness) and distance_ratio>(1-softness):
		result_vector=result_vector.normalized() * (bone_length_difference + full_length * _calculate_softness_result(distance_ratio))
	return result_vector


## [not intended for access]
## Handles even more additional calculations to account for softness.
func _calculate_softness_result(a:float):
	return -(0.25*(a-1-softness)*(a-1-softness)/softness)+1


## [not intended for access]
## The mathemagical function that basically runs the IK.
func _cos_from_sides(a: float, b: float, c: float) -> float:
	if a>0 and b>0:
		return (a*a+b*b-c*c)/(2*a*b)
	else:
		return 0.0


## [not intended for access]
## Applies mathemagic to the first joint.
func _calculate_first_joint_rotation() -> float:
	if _length_check():
		return PI \
		* int(
				_first_bone_vector.length() < \
				_second_bone_vector.length()
			)
	else:
		return acos(
				_cos_from_sides(
					_first_bone_vector.length(),
					_target_vector.length(),
					_second_bone_vector.length()
				)
			)


## [not intended for access]
## Applies mathemagic to the second joint
func _calculate_second_joint_rotation() -> float:
	return (
			target_node.global_position 
			- joint_two_bone_node.global_position
		).angle() - joint_one_bone_node.global_rotation 


## Checks if the distance to the target node is reachable with the current setup.
func _length_check() -> bool:
	return (_target_vector.length()<0.001) or _target_vector.length() < \
	abs(
			_first_bone_vector.length() \
			- _second_bone_vector.length()
		)


