@tool
@icon("res://addons/soupik/icons/icon_stay_at.png")
class_name SoupBoneControl
extends SoupMod

## "Souperior" modification for Skeleton2D; Moves bone to match its own or a target's position and/or angle.

## If true, target node's rotation and scale will be imparted onto the bone. 
@export var control_rotation: bool

## If true, target node's position will be imparted onto the bone. 
@export var control_position: bool

## Only has effect if Control Position is set to false; Makes itself or the target node inherit position from the bone.
@export var inherit_bone_position: bool

## The to-be-modified bone node.
@export var bone_node: Bone2D: 
	set(value):
		bone_node = value
		if Engine.is_editor_hint():
			update_configuration_warnings()

## Optional target node; otherwise targets the IK node itself.
@export var target_node: Node2D


@export_storage var target_position: Vector2 = Vector2.ZERO
@export_storage var target_rotation: float = 0.0

func _get_configuration_warnings():
	var warn_msg: Array[String] = []
	if !bone_node:
		warn_msg.append("Bone not set!")
	return warn_msg


func _process_loop(delta) -> void:
	if !(
			bone_node 
			and enable_check()
		):
		return
	scale_orient = sign(bone_node.global_transform.determinant())
	var _strength: = get_inherited_strength()
	handle_position_control(_strength)
	handle_rotation_control(_strength)


## [not intended for access]
## Handles position modification.
func handle_position_control(str: float) -> void:
	var _target: Node2D = self
	if target_node: _target = target_node
	if !control_position:
		if !inherit_bone_position: return
		_target.global_position = bone_node.global_position
		return
	
	if bone_node is SoupBone2D: 
		bone_node.set_target_position(bone_node.get_parent().to_global(bone_node.target_position).lerp(_target.global_position, str))
	else:
		bone_node.global_position = bone_node.global_position.lerp(_target.global_position, str)



## [not intended for access]
## Handles rotation modification.
func handle_rotation_control(str: float) -> void:
	if !control_rotation: return
	
	target_rotation = global_rotation
	var bone_rotat:float = bone_node.global_rotation
	bone_node.global_transform.x = Vector2(global_transform.x)
	bone_node.global_transform.y = Vector2(global_transform.y)
	if target_node: 
		target_rotation = target_node.global_rotation
		bone_node.global_transform.x = Vector2(target_node.global_transform.x)
		bone_node.global_transform.y = Vector2(target_node.global_transform.y)
	bone_node.global_rotation = bone_rotat
	if bone_node is SoupBone2D: 
		bone_node.set_target_rotation(lerp_angle(bone_node.angle_to_global(bone_node.target_rotation), target_rotation, str))
	else:
		bone_node.global_rotation = lerp_angle(bone_node.global_rotation, target_rotation, str)
