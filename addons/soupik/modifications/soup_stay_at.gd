@tool
@icon("res://addons/soupik/icons/icon_stay_at.png")
class_name SoupStayAt
extends SoupMod

## "Souperior" modification for Skeleton2D; Moves bone to match target's position

## Target node for the modification;
## The bone copies that node;
## To avoid unintended behaviour, make sure this node is NOT a child of the to-be-modified bone.
@export var target_node: Node2D: 
	set(value):
		target_node = value
		if Engine.is_editor_hint():
			update_configuration_warnings()

## If true, the modification is calculated and applied.
@export var enabled: bool = false


## The to-be-modified bone node.
@export var bone_node: Bone2D: 
	set(value):
		bone_node = value
		if Engine.is_editor_hint():
			update_configuration_warnings()



var target_position: Vector2 = Vector2.ZERO

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
	handle_stay_at(delta)


## [not intended for access]
## Handles the modification.
func handle_stay_at(delta) -> void:
	target_position = target_node.global_position
	if bone_node is SoupBone2D: 
		bone_node.set_target_position(target_position)
	else:
		bone_node.global_position = target_position
	
