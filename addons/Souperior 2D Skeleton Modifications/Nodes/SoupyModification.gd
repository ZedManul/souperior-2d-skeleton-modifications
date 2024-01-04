@tool
@icon("customModificationIcon.png")
extends Node
class_name SoupMod

## Parent node for modification stacks.
##
## Not intended for actual use.

@onready var ModStack: SoupStack = find_stack()
@onready var SubStack: Node = get_parent()
@onready var requests: Array[ModificationRequest] = []

func _ready() -> void:
	await get_tree().process

func parent_enable_check() -> bool:
	if !(ModStack is SoupStack):
		return false
	if (SubStack is SoupSubStack):
		return (ModStack.Enabled) #and (SubStack.Enabled)
	else:
		return ModStack.Enabled

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

class ModificationRequest:
	var boneIndex: int = -1
	var requestTransform: Transform2D = Transform2D.IDENTITY
	func _init(inputIndex: int, inputTransform: Transform2D) -> void:
		boneIndex = inputIndex
		requestTransform = inputTransform
	
	func override(inputIndex: int, inputTransform: Transform2D) -> void:
		boneIndex = inputIndex
		requestTransform = inputTransform
