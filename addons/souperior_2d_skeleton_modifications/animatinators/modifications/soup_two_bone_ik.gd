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
@export var flip_bend_direction: bool = false:
	set(value):
		flip_bend_direction = value
		_bend_direction_coefficient = (int(!flip_bend_direction)*2 - 1)


## softness slows down the bones as the chain straightens;
## With 0 softness, IK bones may move very quickly just before the target goes out of range, 
## which is usually undesirable
@export_range(0, 1, 0.01, "or_greater", "or_less") var softness: float = 0:
	set(new_value):
		softness=clampf(new_value,0,1)

#region bone export
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
#endregion

#region easing export
@export_category("Easing")

@export var ease_rotation: bool = false

@export var easing: ZMPhysEasingAngular:
	set(value):
		if value == null:
			easing = null
			_bone_one_easing = null
			_bone_two_easing = null
			return
		
		easing = value.duplicate(true)
		easing.initialize_variables(_target_vector.angle())
		if !easing.constants_changed.is_connected(_on_easing_constants_changed):
			easing.constants_changed.connect(_on_easing_constants_changed)
		_bone_one_easing = easing
		_bone_two_easing = easing

func _on_easing_constants_changed(_k1: float, _k2: float, _k3: float) -> void: 
	_bone_one_easing.k1 = _k1
	_bone_one_easing.k2 = _k2
	_bone_one_easing.k3 = _k3
	_bone_two_easing.k1 = _k1
	_bone_two_easing.k2 = _k2
	_bone_two_easing.k3 = _k3



var _bone_one_easing: ZMPhysEasingAngular:
	set(value):
		if value == null:
			_bone_one_easing = null
			return
		_bone_one_easing = value.duplicate(true)
		_bone_one_easing.initialize_variables(_first_bone_vector.angle())


var _bone_two_easing: ZMPhysEasingAngular:
	set(value):
		if value == null:
			_bone_two_easing = null
			return
		_bone_two_easing = value.duplicate(true)
		_bone_two_easing.initialize_variables(_second_bone_vector.angle())
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

var _bend_direction_coefficient: int = 1

func process_loop(delta) -> void:
	if !(
			enabled 
			and target_node 
			and joint_one_bone_node
			and joint_two_bone_node
			and _parent_enable_check()
		):
		return
	
	_scale_orient = sign(joint_one_bone_node.global_transform.determinant())
	_target_vector = _calculate_target_vector()
	_first_bone_vector = _vectorize_first_bone()
	_second_bone_vector = _vectorize_second_bone()
	
	_handle_ik(delta)


## [not intended for access]
## Handles the modification.
func _handle_ik(delta: float) -> void:
	var target_rotation = _calculate_first_joint_rotation()
	if _bone_one_easing != null and ease_rotation:
		_bone_one_easing.update(delta, target_rotation)
		target_rotation = _bone_one_easing.state
	joint_one_bone_node.global_rotation = target_rotation
	
	target_rotation = _calculate_second_joint_rotation() 
	if _bone_two_easing != null and ease_rotation:
		_bone_two_easing.update(delta, target_rotation)
		target_rotation = _bone_two_easing.state
	joint_two_bone_node.global_rotation = target_rotation


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
	var raw_vector: Vector2 = target_node.global_position \
							- joint_one_bone_node.global_position
	var bone_length_difference: float = abs(_first_bone_vector.length() \
										- _second_bone_vector.length())
	
	var full_length: float = \
			(_first_bone_vector.length() + _second_bone_vector.length()) \
			- bone_length_difference
	var distance_ratio: float = \
			(raw_vector.length() - bone_length_difference) / full_length
	var result_vector: Vector2 = raw_vector
	if softness>0 and distance_ratio<(1+softness) and distance_ratio>(1-softness):
		result_vector = result_vector.normalized() \
				* (bone_length_difference \
				+ full_length * _calculate_softness_result(distance_ratio))
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
			) + _target_vector.angle()
	else:
		return acos(
					_cos_from_sides(
						_first_bone_vector.length(),
						_target_vector.length(),
						_second_bone_vector.length()
					)
				) * _bend_direction_coefficient * _scale_orient + (
			target_node.global_position 
			- joint_one_bone_node.global_position
		).angle() \
		- _first_bone_vector.angle()\
		+ PI * int (_scale_orient < 0)


## [not intended for access]
## Applies mathemagic to the second joint
func _calculate_second_joint_rotation() -> float:
	return (
				target_node.global_position 
				- joint_two_bone_node.global_position
			).angle() \
			- _second_bone_vector.angle() \
			+ PI * int (_scale_orient < 0)


## Checks if the distance to the target node is reachable with the current setup.
func _length_check() -> bool:
	return (_target_vector.length()<0.001) or _target_vector.length() < \
	abs(
			_first_bone_vector.length() \
			- _second_bone_vector.length()
		)
