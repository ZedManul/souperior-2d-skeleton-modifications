@tool
extends EditorPlugin

var armature_generator_control

func _enter_tree() -> void:
	#region Load easing
	add_custom_type("ZMPhysEasingParams", "Resource", 
			preload("easing/zm_phys_easing_parameters.gd"), 
			preload("icons/easing/icon_easing_params.png")) ## TODO: Add icon
	add_custom_type("ZMPhysEasingScalar", "Resource", 
			preload("easing/zm_phys_easing_scalar.gd"), 
			preload("icons/easing/icon_easing_vec2.png")) ## TODO: Add icon
	add_custom_type("ZMPhysEasingWrapped", "Resource", 
			preload("easing/zm_phys_easing_wrapped.gd"), 
			preload("icons/easing/icon_easing_wrapped.png")) ## TODO: Add icon
	add_custom_type("ZMPhysEasingAngular", "Resource", 
			preload("easing/zm_phys_easing_angular.gd"), 
			preload("icons/easing/icon_easing_angular.png")) ## TODO: Add icon
	add_custom_type("ZMPhysEasingVec2", "Resource", 
			preload("easing/zm_phys_easing_vec2.gd"), 
			preload("icons/easing/icon_easing_vec2.png"))
	#endregion
	
	#region Load Misc
	add_custom_type("SoupGroup", "Node", 
			preload("modifications/soup_group.gd"), 
			preload("icons/icon_modification_group.png"))
	#endregion
	
	#region Load modifications
	add_custom_type("SoupFABRIK", "Node", 
			preload("modifications/soup_fabrik.gd"), 
			preload("icons/icon_fabrik.png"))
	add_custom_type("SoupTwoBoneIK", "Node", 
			preload("modifications/soup_two_bone_ik.gd"), 
			preload("icons/icon_two_bone_ik.png"))
	add_custom_type("SoupLookAt", "Node", 
			preload("modifications/soup_look_at.gd"), 
			preload("icons/icon_look_at.png"))
	#endregion
	
	
	
	add_custom_type("SoupArmatureGenerator", "Node", 
			preload("utility/armature_generator.gd"), 
			preload("icons/icon_armature_gen.png")) ## TODO: Add icon
	armature_generator_control = preload(
		"res://addons/soupik/utility/buttons/generate_armature_button.gd"
		).new()
	add_inspector_plugin(armature_generator_control)

func _exit_tree():
	
	remove_inspector_plugin(armature_generator_control)
	
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
	remove_custom_type("ZMPhysEasingAngular")
	remove_custom_type("ZMPhysEasingWrapped")
	remove_custom_type("ZMPhysEasingScalar")
	remove_custom_type("ZMPhysEasingEasingParams")
	#endregion 
