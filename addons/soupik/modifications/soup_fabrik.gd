@tool
@icon("res://addons/soupik/icons/icon_fabrik.png")
class_name SoupFABRIK
extends SoupMod
## "Souperior" modification for Skeleton2D; Reaches for at itself or a target with a chain of bones


## The start of the chain
@export var chain_root: Bone2D:
	set(value):
		chain_root = value
		get_bone_nodes()
		if Engine.is_editor_hint():
			update_configuration_warnings()

## End of the chain 
@export var chain_tip: Bone2D:
	set(value):
		chain_tip = value
		get_bone_nodes()
		if Engine.is_editor_hint():
			update_configuration_warnings()

## Optional target node; otherwise targets the IK node itself
@export var target_node: Node2D

## How many passes the FABRIK does PER FRAME;
## This should work just fine at 1, but if you feel like the chain moves to the target too slow, you can increase it;
## Although I do not recommend to do so, as it effectively multiplies the amount of computations per frame.
@export var iterations: int = 1:
	set(new_value):
		iterations = clampi(new_value,1,16)

@export_group("Deterministic")
## Whether or not the result position should depend on previous position
@export_custom(PROPERTY_HINT_GROUP_ENABLE, "") var determenistic: bool = false
@export_range(-180, 180, 0.1, "radians_as_degrees") var bias_offset: float = 0.0
@export var bias_rotation_reference: Node2D



var bone_nodes: Array[Bone2D]
var base_point: Vector2
var joint_points: PackedVector2Array
var limb_lengths: PackedFloat32Array

func _get_configuration_warnings():
	var warn_msg: Array[String] = []
	if !chain_root:
		warn_msg.append("Chain root not set!")
	if !chain_tip:
		warn_msg.append("Chain tip not set!")
	return warn_msg


func _process_loop(delta) -> void:
	if !(
			bone_nodes.size()>0
			and enable_check()
		):
		return
	scale_orient = sign(bone_nodes[0].global_transform.determinant())
	handle_ik(delta)


## make and apply IK calculations
func handle_ik(delta: float) -> void:
	_initialize_calculation_variables(delta)
	_preposition()
	for i: int in iterations:
		backward_pass()
		forward_pass()
	apply_chain_to_bones(delta)


##  if deterministic, put chain into known state before calculating
func _preposition() -> void:
	if !determenistic: return
	var pole_vector: Vector2 = Vector2.from_angle(global_rotation + bias_offset * scale_orient)
	if target_node:
		pole_vector = Vector2.from_angle(target_node.global_rotation + bias_offset * scale_orient)
	if bias_rotation_reference:
		pole_vector = Vector2.from_angle(bias_rotation_reference.global_rotation + bias_offset * scale_orient)
	
	for i:int in range(1,joint_points.size()):
		joint_points[i] = joint_points[i-1] + pole_vector * limb_lengths[i-1]


## [not intended for access]
## first half of mathemagic happens here
func backward_pass() -> void:
	joint_points[-1] = global_position
	if target_node:
		joint_points[-1] = target_node.global_position
	
	for i: int in range(joint_points.size() - 1, 0, -1):
		var this_bone:Bone2D = bone_nodes[i-1] 
		var a:Vector2 = joint_points[i]
		var b:Vector2 = joint_points[i - 1]
		var angle:float = a.angle_to_point(b)
		joint_points[i - 1] = a + Vector2(limb_lengths[i - 1], 0).rotated(angle)


## [not intended for access]
## second half of mathemagic happens here
func forward_pass() -> void:
	joint_points[0] = base_point
	for i: int in range(joint_points.size() - 1):
		
		var a:Vector2 = joint_points[i]
		var b:Vector2 = joint_points[i + 1]
		var angle:float = a.angle_to_point(b)
		
		joint_points[i + 1] = a + Vector2(limb_lengths[i], 0).rotated(angle)


## [Not intended for access]
## Charging up the mathemagical ritual
func _initialize_calculation_variables(delta: float) -> void:
	base_point = bone_nodes[0].global_position
	
	#region Joint points and lengths
	joint_points.clear()
	limb_lengths.clear()
	for i: Bone2D in bone_nodes:
		joint_points.append(i.global_position)
		limb_lengths.append(i.get_length())
	
	# calculate the chain tip
	joint_points.append(
			bone_nodes[-1].global_position \
			+ Vector2.from_angle(
					bone_nodes[-1].global_rotation \
					- bone_nodes[-1].get_bone_angle()
				) * bone_nodes[-1].get_length()
		)
	#endregion


## [not intended for access]
## Writes the point chain data to bone node positions
func apply_chain_to_bones(delta) -> void:
	var _strength = get_inherited_strength()
	for i:int in bone_nodes.size():
		var target_rotation =  \
						joint_points[i].angle_to_point(
									joint_points[i + 1]
								)
		target_rotation -= bone_nodes[i].get_bone_angle() * scale_orient
		if bone_nodes[i] is SoupBone2D:
			bone_nodes[i].set_target_rotation(lerp_angle(bone_nodes[i].angle_to_global(bone_nodes[i].target_rotation), target_rotation, _strength))
		else:
			bone_nodes[i].global_rotation = lerp_angle(bone_nodes[i].global_rotation, target_rotation, _strength)


func get_bone_nodes() -> void:
	bone_nodes.clear()
	if chain_root and chain_tip: 
		var i: Node = chain_tip
		while i is Bone2D:
			bone_nodes.push_front(i)
			if i == chain_root: return
			i = i.get_parent()
	bone_nodes.clear()


func _draw_gizmo() -> void:
	if target_node: draw_set_transform(to_local(target_node.global_position),target_node.global_rotation+global_rotation)
	draw_strength(strength_gizmo_scale)
	draw_target()
