@tool
@icon("res://addons/soupik/icons/icon_armature_gen.png")
class_name ArmatureGenerator
extends EditorPlugin

@export_tool_button("Generate", "ToolBoneSelect") var button_function = button_action

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

@export_group("Generate Forward Kinematics Rig")
@export_custom(PROPERTY_HINT_GROUP_ENABLE,"") var gen_fk_rig: bool = false
@export var rig_node: SoupMod
@export var fk_prefix: String = ""
@export var fk_suffix: String = "FK"

@export_storage var current_bone_list: Array[Bone2D]
@export_storage var current_rt_list: Array[RemoteTransform2D]
@export_storage var current_fk_list: Array[SoupBoneControl]

func _get_configuration_warnings():
	var warn_msg: Array[String] = []
	if !skeleton: 
		warn_msg.append("Skeleton node not set!")
	if !sprite_root: 
		warn_msg.append("Sprite subtree root not set!")
	return warn_msg

func button_action() -> void:
	var undoredo = get_undo_redo()
	undoredo.create_action("Generate Armature")
	undoredo.add_do_method(self, &"generate_armature")
	undoredo.add_undo_method(self, &"ungenerate_armature")
	undoredo.commit_action()

func generate_armature() -> void:
	if !sprite_root or !skeleton:
		return
	var sprite_list: Array[Node2D] 
	sprite_list.append_array(find_all_type_in_tree(sprite_root, "Sprite2D"))
	sprite_list.append_array(find_all_type_in_tree(sprite_root, "AnimatedSprite2D"))
	
	current_bone_list.clear()
	current_rt_list.clear()
	current_fk_list.clear()
	
	print("Growing New Bones...")
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
		current_bone_list.append(bone_node)
		
		var rt_node = RemoteTransform2D.new()
		bone_node.add_child.call_deferred(rt_node)
		await get_tree().node_added
		rt_node.owner = get_tree().edited_scene_root
		rt_node.name = rt_prefix + i.name + rt_suffix
		rt_node.remote_path = rt_node.get_path_to(i)
		current_rt_list.append(rt_node)
		
		if !gen_fk_rig: continue
		
		var fk_node = SoupBoneControl.new()
		rig_node.add_child.call_deferred(fk_node)
		await get_tree().node_added
		fk_node.owner = get_tree().edited_scene_root
		fk_node.name = fk_prefix + i.name + fk_suffix
		fk_node.global_transform = bone_node.global_transform
		fk_node.bone_node = bone_node
		fk_node.control_position = false
		fk_node.control_rotation = true
		fk_node.inherit_bone_position = true
		current_fk_list.append(fk_node)

	
	print("Bones Grown :)")


func ungenerate_armature() -> void:
	if !sprite_root or !skeleton:
		return
	
	for i in current_bone_list:
		i.queue_free()
	
	for i in current_rt_list:
		i.queue_free()
	
	for i in current_fk_list:
		i.queue_free()



func find_all_type_in_tree(root: Node, type: String) -> Array[Node]:
	var res: Array[Node]
	for i: Node in root.get_children():
		if i.is_class(type): 
			res.push_back(i)
		res.append_array(find_all_type_in_tree(i, type))
	return res
