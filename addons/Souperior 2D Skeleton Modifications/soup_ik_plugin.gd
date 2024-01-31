@tool
extends EditorPlugin

func _enter_tree():
	#region Load Easing
	add_custom_type("SoupSecondOrderEasing", "Resource", 
			preload("Easing/soup_second_order_easing.gd"), 
			preload("Easing/icon_easing.png"))
	add_custom_type("SoupSecondOrderEasingG", "Resource", 
			preload("Easing/soup_second_order_easing_g.gd"), 
			preload("Easing/icon_easing.png"))
	add_custom_type("SoupSecondOrderEasingNoG", "Resource", 
			preload("Easing/soup_second_order_easing_no_g.gd"), 
			preload("Easing/icon_easing.png"))
	#endregion
	
	#region Load Misc
	add_custom_type("SoupStack", "Node", 
			preload("Animatinators/soup_stack.gd"), 
			preload("Animatinators/Icons/icon_stack.png"))
	add_custom_type("SoupSubStack", "Node", 
			preload("Animatinators/soup_sub_stack.gd"), 
			preload("Animatinators/Icons/icon_sub_stack.png"))
	add_custom_type("SoupConstraint", "Node", 
			preload("Animatinators/soup_constraint.gd"), 
			preload("Animatinators/Icons/icon_constraint.png"))
	#endregion
	
	#region Load Modifications
	add_custom_type("SoupFABRIK", "Node", 
			preload("Animatinators/Modifications/soup_fabrik.gd"), 
			preload("Animatinators/Modifications/Icons/icon_fabrik.png"))
	add_custom_type("SoupTwoBoneIK", "Node", 
			preload("Animatinators/Modifications/soup_two_bone_ik.gd"), 
			preload("Animatinators/Modifications/Icons/icon_two_bone_ik.png"))
	add_custom_type("SoupLookAt", "Node", 
			preload("Animatinators/Modifications/soup_look_at.gd"), 
			preload("Animatinators/Modifications/Icons/icon_look_at.png"))
	add_custom_type("SoupStayAt", "Node", 
			preload("Animatinators/Modifications/soup_stay_at.gd"), 
			preload("Animatinators/Modifications/Icons/icon_stay_at.png"))
	add_custom_type("SoupJiggle", "Node", 
			preload("Animatinators/Modifications/soup_jiggle.gd"), 
			preload("Animatinators/Modifications/Icons/icon_jiggle.png"))
	#endregion

func _exit_tree():
	#region Unload Modifications
	remove_custom_type("SoupFABRIK")
	remove_custom_type("SoupTwoBoneIK")
	remove_custom_type("SoupLookAt")
	remove_custom_type("SoupStayAt")
	remove_custom_type("SoupJiggle")
	remove_custom_type("SoupyModification")
	#endregion
	
	#region Unload Misc
	remove_custom_type("SoupBoneEnhancer")
	remove_custom_type("SoupSubStack")
	remove_custom_type("SoupStack")
	#endregion
	
	#region Unload Easing
	remove_custom_type("SoupSecondOrderEasing")
	remove_custom_type("SoupSecondOrderEasingG")
	remove_custom_type("SoupSecondOrderEasingNoG")
	#endregion 
