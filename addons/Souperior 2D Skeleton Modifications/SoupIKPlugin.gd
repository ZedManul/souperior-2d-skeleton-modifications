@tool
extends EditorPlugin


func _enter_tree():
	add_custom_type("SecondOrderEasing", "Resource", preload("Resources/SecondOrderEasing.gd"), preload("Resources/customEasingIcon.png"))
	add_custom_type("SoupStack", "Node", preload("Nodes/SoupStack.gd"), preload("Nodes/Icons/customStackIcon.png"))
	add_custom_type("SoupSubStack", "Node", preload("Nodes/SoupSubStack.gd"), preload("Nodes/Icons/customSubStackIcon.png"))
	add_custom_type("SoupConstraint", "Node", preload("Nodes/SoupConstraint.gd"), preload("Nodes/Icons/customConstraintIcon.png"))
	add_custom_type("SoupTwoBoneIK", "Node", preload("Nodes/SoupTwoBoneIK.gd"), preload("Nodes/Icons/customIKIcon.png"))
	add_custom_type("SoupLookAt", "Node", preload("Nodes/SoupLookAt.gd"), preload("Nodes/Icons/customLookAtIcon.png"))
	add_custom_type("SoupStayAt", "Node", preload("Nodes/SoupStayAt.gd"), preload("Nodes/Icons/customStayAtIcon.png"))
	add_custom_type("SoupJiggle", "Node", preload("Nodes/SoupJiggle.gd"), preload("Nodes/Icons/customJiggleIcon.png"))



func _exit_tree():
	remove_custom_type("SoupTwoBoneIK")
	remove_custom_type("SoupLookAt")
	remove_custom_type("SoupStayAt")
	remove_custom_type("SoupJiggle")
	remove_custom_type("SoupyModification")
	remove_custom_type("SoupBoneEnhancer")
	remove_custom_type("SoupSubStack")
	remove_custom_type("SoupStack")
	remove_custom_type("SecondOrderEasing")
