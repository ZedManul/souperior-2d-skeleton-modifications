@tool
@icon("Icons/customModificationIcon.png")
extends Node
class_name SoupStackPart

@onready var ModStack: SoupStack = find_stack()
@onready var SubStack: Node = get_parent()

func find_stack() -> SoupStack:
	var foundNode: Node = get_parent()
	for i in 1000:
		if foundNode is SoupStack:
			return foundNode
		elif foundNode is SoupSubStack:
			foundNode = foundNode.get_parent()
			continue
		elif foundNode == get_tree().root:
			break
	return null
