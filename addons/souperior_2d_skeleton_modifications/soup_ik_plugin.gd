@tool
extends EditorPlugin

func _enter_tree():
	#region Load easing
	add_custom_type("ZMPhysEasingVec2", "Resource", 
			preload("easing/zm_phys_easing_vec2.gd"), 
			preload("easing/icon_easing_vec2.png"))
	#endregion
	
	#region Load Misc
	add_custom_type("SoupGroup", "Node", 
			preload("animatinators/soup_group.gd"), 
			preload("animatinators/icons/icon_group.png"))
	#endregion
	
	#region Load modifications
	add_custom_type("SoupFABRIK", "Node", 
			preload("animatinators/modifications/soup_fabrik.gd"), 
			preload("animatinators/modifications/icons/icon_fabrik.png"))
	add_custom_type("SoupTwoBoneIK", "Node", 
			preload("animatinators/modifications/soup_two_bone_ik.gd"), 
			preload("animatinators/modifications/icons/icon_two_bone_ik.png"))
	add_custom_type("SoupLookAt", "Node", 
			preload("animatinators/modifications/soup_look_at.gd"), 
			preload("animatinators/modifications/icons/icon_look_at.png"))
	#endregion

func _exit_tree():
	#region Unload modifications
	remove_custom_type("SoupFABRIK")
	remove_custom_type("SoupTwoBoneIK")
	remove_custom_type("SoupLookAt")
	remove_custom_type("SoupStayAt")
	remove_custom_type("SoupyModification")
	#endregion
	
	#region Unload Misc
	remove_custom_type("SoupBoneEnhancer")
	remove_custom_type("SoupGroup")
	#endregion
	
	#region Unload easing
	remove_custom_type("ZMPhysEasingVec2")
	remove_custom_type("ZMPhysEasingVec2G")
	#endregion 
