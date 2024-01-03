@tool
@icon("customStackIcon.png")
extends Node
class_name SoupStack


## Skeleton affected by the modification stack
@onready @export var Skeleton: Skeleton2D = find_skeledaddy()

## if true, the modifications are applied
@export var Enabled: bool = true

func apply_modification(modification: SoupMod.ModificationRequest) -> void:
	var bone = Skeleton.get_bone(modification.boneIndex)
	bone.transform = modification.requestTransform

func find_skeledaddy() -> Skeleton2D:
	var foundNode: Node = self
	for i in 1000:
		foundNode = foundNode.get_parent()
		if foundNode is Skeleton2D:
			return foundNode
			break
		elif foundNode == get_tree().root:
			break
	return null
