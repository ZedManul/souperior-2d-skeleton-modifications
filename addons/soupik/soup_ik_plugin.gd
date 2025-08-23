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
	
	#region Load Misc
	add_custom_type("SoupGroup", "Node", 
			preload("modifications/soup_group.gd"), 
			preload("icons/icon_modification_group.png"))
	#endregion
	
	#region Load modifications
	add_custom_type("SoupBone2D", "Bone2D", 
			preload("modifications/soup_bone.gd"), 
			preload("icons/icon_soup_bone.png"))
	add_custom_type("SoupFABRIK", "Node", 
			preload("modifications/soup_fabrik.gd"), 
			preload("icons/icon_fabrik.png"))
	add_custom_type("SoupTwoBoneIK", "Node", 
			preload("modifications/soup_two_bone_ik.gd"), 
			preload("icons/icon_two_bone_ik.png"))
	add_custom_type("SoupLookAt", "Node", 
			preload("modifications/soup_look_at.gd"), 
			preload("icons/icon_look_at.png"))
	add_custom_type("SoupStayAt", "Node", 
			preload("modifications/soup_stay_at.gd"), 
			preload("icons/icon_stay_at.png"))
	#endregion
	
	
	
	add_custom_type("SoupArmatureGenerator", "Node", 
			preload("utility/armature_generator.gd"), 
			preload("icons/icon_armature_gen.png")) 

func _exit_tree():
	
	
	#region Unload modifications
	remove_custom_type("SoupFABRIK")
	remove_custom_type("SoupTwoBoneIK")
	remove_custom_type("SoupLookAt")
	remove_custom_type("SoupStayAt")
	remove_custom_type("SoupBone2D")
	#endregion
	
	#region Unload Misc
	remove_custom_type("SoupGroup")
	#endregion
	
	#region Unload Resources
	remove_custom_type("ZMPhysEasingParams")
	remove_custom_type("ZMPhysEasingRotationalParams")
	remove_custom_type("ZMConstraintData")
	#endregion 
