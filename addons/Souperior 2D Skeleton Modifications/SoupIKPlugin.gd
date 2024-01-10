@tool
extends EditorPlugin


func _enter_tree():
	add_custom_type("SecondOrderEasing", "Resource", preload("Resources/SecondOrderEasing.gd"), preload("Resources/customEasingIcon.png"))
	add_custom_type("SoupStack", "Node", preload("Nodes/SoupStack.gd"), preload("Nodes/customStackIcon.png"))
	add_custom_type("SoupSubStack", "Node", preload("Nodes/SoupSubStack.gd"), preload("Nodes/customSubStackIcon.png"))
	add_custom_type("SoupConstraint", "Node", preload("Nodes/SoupConstraint.gd"), preload("Nodes/customConstraintIcon.png"))
	add_custom_type("SoupTwoBoneIK", "Node", preload("Nodes/SoupTwoBoneIK.gd"), preload("Nodes/customIKIcon.png"))
	add_custom_type("SoupLookAt", "Node", preload("Nodes/SoupLookAt.gd"), preload("Nodes/customLookAtIcon.png"))



func _exit_tree():

	remove_custom_type("SoupTwoBoneIK")
	remove_custom_type("SoupLookAt")
	remove_custom_type("SoupyModification")
	remove_custom_type("SoupBoneEnhancer")
	remove_custom_type("SoupSubStack")
	remove_custom_type("SoupStack")
	remove_custom_type("SecondOrderEasing")
