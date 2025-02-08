@tool
@icon("res://addons/soupik/icons/icon_look_at.png")
class_name SoupLookAt
extends SoupMod

## "Souperior" modification for Skeleton2D; Points bone angle at the target.

## Target node for the modification;
## The bone is pointed towards this;
## To avoid unintended behaviour, make sure this node is NOT a child of the to-be-modified bone.
@export var target_node: Node2D: 
	set(value):
		target_node = value
		if Engine.is_editor_hint():
			update_configuration_warnings()

## If true, the modification is calculated and applied.
@export var enabled: bool = false

## Offset angle from target, in radians.

## Offset angle from target, in degrees; used for export.
@export_range(-180,180,0.001,"or_greater", "or_less") \
		 var angle_offset_degrees: float = 0:
	set(new_value):
		angle_offset_degrees = wrapf(new_value,-180,180)
		angle_offset = deg_to_rad(angle_offset_degrees)

## The to-be-modified bone node.
@export var bone_node: Bone2D: 
	set(value):
		bone_node = value
		if Engine.is_editor_hint():
			update_configuration_warnings()

@export_enum("LOOK_AT", "MIMIC_ANGLE") var look_at_mode: int = 0



var angle_offset: float = 0
var target_vector: Vector2 = Vector2.RIGHT

func _get_configuration_warnings():
	var warn_msg: Array[String] = []
	if !bone_node:
		warn_msg.append("Bone not set!")
	if !target_node: 
		warn_msg.append("Target node not set!")
	return warn_msg


func _process_loop(delta) -> void:
	if !(
			enabled 
			and target_node 
			and bone_node 
			and parent_enable_check()
		):
		return
	scale_orient = sign(bone_node.global_transform.determinant())
	handle_look_at(delta)


## [not intended for access]
## Handles the modification.
func handle_look_at(delta) -> void:
	
	var target_rotation = target_node.global_rotation
	if look_at_mode == 0:
		target_vector = target_node.global_position - bone_node.global_position
		target_rotation = target_vector.angle() \
			- (bone_node.get_bone_angle() - angle_offset) * scale_orient
	if bone_node is SoupBone2D: 
		bone_node.set_target_rotation(target_rotation)
	else:
		bone_node.global_rotation = target_rotation
	
