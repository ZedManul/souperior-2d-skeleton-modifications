@tool
extends EditorPlugin


func _enter_tree() -> void:
	#region Load Resources
	add_custom_type("ZMPhysEasingParams", "Resource",
			preload("resources/zm_easing_params.gd"), 
			preload("icons/icon_easing_params.png"))
	
	add_custom_type("ZMPhysEasingRotationalParams", "Resource",
			preload("resources/zm_easing_rotational_params.gd"), 
			preload("icons/icon_easing_angular.png"))
			
	add_custom_type("ZMConstraintData", "Resource",
			preload("resources/zm_constraint_data.gd"), 
			preload("icons/icon_modification.png"))
	#endregion
	
	
	#region Load modifications
	add_custom_type("SoupBone2D", "Bone2D", 
			preload("modifications/soup_bone.gd"), 
			preload("icons/icon_soup_bone.png"))
	add_custom_type("SoupFABRIK", "Node2D", 
			preload("modifications/soup_fabrik.gd"), 
			preload("icons/icon_fabrik.png"))
	add_custom_type("SoupTwoBoneIK", "Node2D", 
			preload("modifications/soup_two_bone_ik.gd"), 
			preload("icons/icon_two_bone_ik.png"))
	add_custom_type("SoupLookAt", "Node2D", 
			preload("modifications/soup_look_at.gd"), 
			preload("icons/icon_look_at.png"))
	add_custom_type("SoupBoneControl", "Node2D", 
			preload("modifications/soup_bone_control.gd"), 
			preload("icons/icon_stay_at.png"))
	#endregion
	
	
	
	add_custom_type("SoupArmatureGenerator", "EditorPlugin", 
			preload("utility/armature_generator.gd"), 
			preload("icons/icon_armature_gen.png")) 

func _exit_tree():
	
	
	#region Unload modifications
	remove_custom_type("SoupFABRIK")
	remove_custom_type("SoupTwoBoneIK")
	remove_custom_type("SoupLookAt")
	remove_custom_type("SoupBoneControl")
	remove_custom_type("SoupBone2D")
	#endregion
	
	
	#region Unload Resources
	remove_custom_type("ZMPhysEasingParams")
	remove_custom_type("ZMPhysEasingRotationalParams")
	remove_custom_type("ZMConstraintData")
	#endregion 
