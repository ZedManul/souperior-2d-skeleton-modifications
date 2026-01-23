@tool
@icon("res://addons/soupik/icons/icon_look_at.png")
class_name SoupLookAt
extends SoupMod

## "Souperior" modification for Skeleton2D; Points bone at itself or a target.


## Offset angle from target.
@export_range(-180, 180, 0.1, "radians_as_degrees") var angle_offset: float = 0.0

## The to-be-modified bone node.
@export var bone_node: Bone2D: 
	set(value):
		bone_node = value
		if Engine.is_editor_hint():
			update_configuration_warnings()

## Optional target node; otherwise targets the IK node itself.
@export var target_node: Node2D


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
	handle_look_at(delta)


## [not intended for access]
## Handles the modification.
func handle_look_at(delta) -> void:
	var target_vector = global_position - bone_node.global_position
	if target_node:
		target_vector = target_node.global_position - bone_node.global_position
	var target_rotation = target_vector.angle() \
			- (bone_node.get_bone_angle() - angle_offset) * scale_orient
			
	var _strength = get_inherited_strength()
	if bone_node is SoupBone2D: 
		bone_node.set_target_rotation(lerp_angle(bone_node.angle_to_global(bone_node.target_rotation), target_rotation, _strength))
	else:
		bone_node.global_rotation = lerp_angle(bone_node.global_rotation, target_rotation, _strength)


func _draw_gizmo() -> void:
	if target_node: draw_set_transform(to_local(target_node.global_position),target_node.global_rotation+global_rotation)
	draw_strength(strength_gizmo_scale)
	draw_target()
