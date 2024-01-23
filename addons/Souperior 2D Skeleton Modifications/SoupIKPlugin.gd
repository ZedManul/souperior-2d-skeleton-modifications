@tool
extends EditorPlugin

var apply_and_record_inspector_plugin

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
	
	#region Load Property State Managers
	add_custom_type("SoupStateComponent", "Node", 
			preload("Animatinators/Statinators/soup_state_component.gd"), 
			preload("Animatinators/Statinators/Icons/icon_bone_state_component.png"))
	add_custom_type("SoupStateComponentGroup", "Node", 
			preload("Animatinators/Statinators/soup_state_component_group.gd"), 
			preload("Animatinators/Statinators/Icons/icon_bone_state.png"))
	add_custom_type("SoupStateVariant", "Node", 
			preload("Animatinators/Statinators/soup_state_variant.gd"), 
			preload("Animatinators/Statinators/Icons/icon_bone_state_component.png"))
	add_custom_type("SoupStateTransform", "Node", 
			preload("Animatinators/Statinators/soup_state_transform.gd"), 
			preload("Animatinators/Statinators/Icons/icon_bone_state_component.png"))
	add_custom_type("SoupStateSprite", "Node", 
			preload("Animatinators/Statinators/soup_state_sprite.gd"), 
			preload("Animatinators/Statinators/Icons/icon_bone_state_component.png"))
	add_custom_type("SoupStateAnimatedSprite", "Node", 
			preload("Animatinators/Statinators/soup_state_animatedsprite.gd"), 
			preload("Animatinators/Statinators/Icons/icon_bone_state_component.png"))
	add_custom_type("SoupStateInator", "Node", 
			preload("Animatinators/Statinators/soup_state_inator.gd"), 
			preload("Animatinators/Statinators/Icons/icon_state.png"))
	add_custom_type("SoupStateAngleFixInator", "Node", 
			preload("Animatinators/Statinators/soup_state_angle_fixinator.gd"), 
			preload("Animatinators/Statinators/Icons/icon_state_angle_fixer.png"))
	#endregion
	
	apply_and_record_inspector_plugin = preload(
		"Animatinators/Statinators/Buttons/soupy_apply_record_buttons.gd"
	).new()
	add_inspector_plugin(apply_and_record_inspector_plugin)


func _exit_tree():
	remove_inspector_plugin(apply_and_record_inspector_plugin)
	
	#region Unload Property State Managers
	remove_custom_type("SoupStateAngleFixInator")
	remove_custom_type("SoupStateInator")
	remove_custom_type("SoupStateAnimatedSprite")
	remove_custom_type("SoupStateSprite")
	remove_custom_type("SoupStateTransform")
	remove_custom_type("SoupStateVariant")
	remove_custom_type("SoupStateComponentGroup")
	remove_custom_type("SoupStateComponent")
	#endregion
	
	#region Unload Modifications
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
	
	#region 
	remove_custom_type("SoupSecondOrderEasing")
	remove_custom_type("SoupSecondOrderEasingG")
	remove_custom_type("SoupSecondOrderEasingNoG")
	#endregion 
