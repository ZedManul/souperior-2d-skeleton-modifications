@tool
extends EditorPlugin


func _enter_tree():
	add_custom_type("SoupSecondOrderEasing", "Resource", preload("Resources/soup_second_order_easing.gd"), preload("Resources/icon_easing.png"))
	add_custom_type("SoupSecondOrderEasingG", "Resource", preload("Resources/soup_second_order_easing_g.gd"), preload("Resources/icon_easing.png"))
	add_custom_type("SoupSecondOrderEasingNoG", "Resource", preload("Resources/soup_second_order_easing_no_g.gd"), preload("Resources/icon_easing.png"))
	add_custom_type("SoupStack", "Node", preload("Nodes/soup_stack.gd"), preload("Nodes/Icons/icon_stack.png"))
	add_custom_type("SoupSubStack", "Node", preload("Nodes/soup_sub_stack.gd"), preload("Nodes/Icons/icon_sub_stack.png"))
	add_custom_type("SoupConstraint", "Node", preload("Nodes/soup_constraint.gd"), preload("Nodes/Icons/icon_constraint.png"))
	add_custom_type("SoupTwoBoneIK", "Node", preload("Nodes/soup_two_bone_ik.gd"), preload("Nodes/Icons/icon_two_bone_ik.png"))
	add_custom_type("SoupLookAt", "Node", preload("Nodes/soup_look_at.gd"), preload("Nodes/Icons/icon_look_at.png"))
	add_custom_type("SoupStayAt", "Node", preload("Nodes/soup_stay_at.gd"), preload("Nodes/Icons/icon_stay_at.png"))
	add_custom_type("SoupJiggle", "Node", preload("Nodes/soup_jiggle.gd"), preload("Nodes/Icons/icon_jiggle.png"))


func _exit_tree():
	remove_custom_type("SoupTwoBoneIK")
	remove_custom_type("SoupLookAt")
	remove_custom_type("SoupStayAt")
	remove_custom_type("SoupJiggle")
	remove_custom_type("SoupyModification")
	remove_custom_type("SoupBoneEnhancer")
	remove_custom_type("SoupSubStack")
	remove_custom_type("SoupStack")
	remove_custom_type("SoupSecondOrderEasing")
	remove_custom_type("SoupSecondOrderEasingG")
	remove_custom_type("SoupSecondOrderEasingNoG")
