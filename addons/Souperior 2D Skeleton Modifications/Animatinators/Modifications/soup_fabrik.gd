@tool
@icon("Icons/icon_fabrik.png")
class_name SoupFABRIK
extends SoupMod
## "Souperior" modification for Skeleton2D; Reaches for the target with a chain of bones;
## You can constraint the bone angles in this chain, but the behaviour may be unintuitive.

## Target node for the modification;
## The bone is pointed towards this;
## To avoid unintended behaviour, make sure this node is NOT a child of a to-be-modified bone.
@export var target_node: Node2D

## Pole node for the modification;
## The chain tries to angle towards this;
## To avoid unintended behaviour, make sure this node is NOT a child of a to-be-modified bone.
@export var pole_node: Node2D

## If true, the modification is calculated and applied.
@export var enabled: bool = false

## The to-be-modified bone nodes.
@export var bone_nodes: Array[Bone2D]

## How many passes the FABRIK does PER FRAME;
## This should work just fine at 1, but if you feel like the chain moves to the target too slow, you can increase it;
## Although I do not recommend to do so, as it effectively multiplies the amount of computations per frame.
@export var iterations: int = 1:
	set(new_value):
		iterations = clampi(new_value,1,16)

var _base_point: Vector2
var _target_point: Vector2
var _joint_points: PackedVector2Array
var _limb_lengths: PackedFloat32Array


func process_loop(delta) -> void:
	if !(
			enabled 
			and target_node 
			and bone_nodes.size()>0
			and _parent_enable_check()
		):
		return
	
	handle_ik(delta)


## make and apply IK calculations
func handle_ik(delta: float) -> void:
	_initialize_calculation_variables(delta)
	if pole_node:
		handle_pole()
	for i:int in iterations:
		_backward_pass()
		_forward_pass()
	_apply_chain_to_bones()

func handle_pole() -> void:
	var pole_vector: Vector2 = (pole_node.global_position - _base_point).normalized()
	for i:int in range(1,_joint_points.size()):
		_joint_points[i] = _joint_points[i-1] + pole_vector * _limb_lengths[i-1]


## [not intended for access]
## first half of mathemagic happens here
func _backward_pass() -> void:
	_joint_points[-1] = _target_point
	for i: int in range(_joint_points.size() - 1, 0, -1):
		var this_bone:Bone2D = bone_nodes[i-1] 
		var a:Vector2 = _joint_points[i]
		var b:Vector2 = _joint_points[i - 1]
		var angle:float = a.angle_to_point(b)
		
		if (i < _joint_points.size() - 1):
			angle = _mod_stack.apply_rotation_constraints(
					this_bone, 
					wrapf(
							angle \
							- this_bone.get_bone_angle() \
							- this_bone.get_parent().global_rotation,
							-PI, PI
						)
				) \
				+ this_bone.get_bone_angle() \
				+ this_bone.get_parent().global_rotation
		
		_joint_points[i - 1] = a + Vector2(_limb_lengths[i - 1], 0).rotated(angle)


## [not intended for access]
## second half of mathemagic happens here
func _forward_pass() -> void:
	_joint_points[0] = _base_point
	for i: int in range(_joint_points.size() - 1):
		
		var a:Vector2 = _joint_points[i]
		var b:Vector2 = _joint_points[i + 1]
		var angle:float = a.angle_to_point(b)
		
		_joint_points[i + 1] = a + Vector2(_limb_lengths[i], 0).rotated(angle)


## [Not intended for access]
## Charging up the mathemagical ritual
func _initialize_calculation_variables(delta: float) -> void:
	_base_point = bone_nodes[0].global_position
	
	_target_point = target_node.global_position
	
	#region Joint points and lengths
	_joint_points.clear()
	_limb_lengths.clear()
	for i: Bone2D in bone_nodes:
		_joint_points.append(i.global_position)
		_limb_lengths.append(i.get_length())
	
	# calculate the chain tip
	_joint_points.append(
			bone_nodes[-1].global_position \
			+ Vector2.from_angle(
					bone_nodes[-1].global_rotation \
					- bone_nodes[-1].get_bone_angle()
				) * bone_nodes[-1].get_length()
		)
	#endregion



## [not intended for access]
## Writes the virtual chain data to the bone nodes
func _apply_chain_to_bones() -> void:
	for i:int in bone_nodes.size():
		_mod_stack.apply_bone_rotation_mod(
				bone_nodes[i],
				rotation_global_to_local(
						(
							_joint_points[i].angle_to_point(
									_joint_points[i + 1]
								) 
						) * sign(bone_nodes[i].global_scale.y)
						- bone_nodes[i].get_bone_angle(),
						bone_nodes[i].get_parent()
					) 
					
			)
