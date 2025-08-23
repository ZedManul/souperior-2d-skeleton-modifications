@tool
@icon("res://addons/soupik/icons/icon_armature_gen.png")
class_name ArmatureGenerator
extends Node

@export_tool_button("Generate", "ToolBoneSelect") var gen_function = generate_armature

@export var skeleton: Skeleton2D: 
	set(value):
		skeleton = value
		if Engine.is_editor_hint():
			update_configuration_warnings()

@export var sprite_root: Node: 
	set(value):
		sprite_root = value
		if Engine.is_editor_hint():
			update_configuration_warnings()

@export_enum("Bone2D", "SoupBone2D") var bone_type: int = 0

@export_group("Bone Naming")
@export var bone_prefix: String = ""
@export var bone_suffix: String = "Bone"

@export_group("Remote Transform Naming")
@export var rt_prefix: String = ""
@export var rt_suffix: String = "RT"

func _get_configuration_warnings():
	var warn_msg: Array[String] = []
	if !skeleton: 
		warn_msg.append("Skeleton node not set!")
	if !sprite_root: 
		warn_msg.append("Sprite subtree root not set!")
	return warn_msg

func generate_armature() -> void:
	if !sprite_root or !skeleton:
		return
	var sprite_list: Array[Node2D] 
	sprite_list.append_array(find_all_type_in_tree(sprite_root, "Sprite2D"))
	sprite_list.append_array(find_all_type_in_tree(sprite_root, "AnimatedSprite2D"))
	
	var current_bone_list: Array[String]
	
	print_debug("Dissolving Excess Bones...")
	for i: Node in skeleton.get_children():
		if i is Bone2D:
			i.queue_free()
			await get_tree().node_removed
	
	print_debug("Growing New Bones...")
	for i: Node2D in sprite_list:
		var bone_name = bone_prefix + i.name + bone_suffix
		var bone_node: Bone2D
		if bone_type == 0:
			bone_node = Bone2D.new()
		else:
			bone_node = SoupBone2D.new()
		bone_node.set_autocalculate_length_and_angle(false)
		bone_node.rest = Transform2D.IDENTITY
		skeleton.add_child.call_deferred(bone_node)
		await get_tree().node_added
		bone_node.owner = get_tree().edited_scene_root
		bone_node.name = bone_name
		bone_node.global_transform = i.global_transform
		
		var rt_node = RemoteTransform2D.new()
		bone_node.add_child.call_deferred(rt_node)
		await get_tree().node_added
		rt_node.owner = get_tree().edited_scene_root
		rt_node.name = rt_prefix + i.name + rt_suffix
		rt_node.remote_path = rt_node.get_path_to(i)
	
	print_debug("Bones Grown :)")
	



func find_all_type_in_tree(root: Node, type: String) -> Array[Node]:
	var res: Array[Node]
	for i: Node in root.get_children():
		if i.is_class(type): 
			res.push_back(i)
		res.append_array(find_all_type_in_tree(i, type))
	return res
