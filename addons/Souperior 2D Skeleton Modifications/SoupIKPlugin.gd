@tool
extends EditorPlugin


func _enter_tree():
	add_custom_type("SoupTwoBoneIK", "Node", preload("Nodes/SoupTwoBoneIK.gd"), preload("Nodes/customIKIcon.png"))
	add_custom_type("SoupLookAt", "Node", preload("Nodes/SoupLookAt.gd"), preload("Nodes/customLookAtIcon.png"))



func _exit_tree():
	remove_custom_type("SoupTwoBoneIK")
	remove_custom_type("SoupLookAt")
