@tool
@icon("customLookAtIcon.png")
extends Node
class_name SoupLookAt

## "Souperior" custom modification for Skeleton2D; Points bone angle at the target.

## The skeleton this modification affects
@onready @export var Skeleton: Skeleton2D = find_skeledaddy()
## Target node for the modification
@export_node_path("Node2D") var TargetNode: NodePath
## if true, the modification is calculated and applied
@export var Enabled: bool = false:
	set(new_value):
		Enabled=new_value
		if Skeleton is Skeleton2D:
			if Enabled:
				handle_lookAt()
	get:
		return Enabled

## Easing value for the modification. 
## Smoothes modification's reaction to changes. 
## At 0 the modification snaps to the target
## At 1 the modification does not react to the target at all
@export_range(0, 1, 0.01, "or_greater", "or_less") var Easing: float = 0:
	set(new_value):
		Easing=clampf(new_value,0,1)
	get:
		return Easing

@export_category("Bones")
#region Bone 
@export var BoneIdx: int = -1:
	set(new_value):
		BoneIdx=new_value
		if Skeleton is Skeleton2D:
			if (BoneIdx>=0)and(BoneIdx<Skeleton.get_bone_count()):
				if (Bone != Skeleton.get_bone(BoneIdx).get_path()):
					Bone = Skeleton.get_bone(BoneIdx).get_path()
					return
		if Bone:
			Bone = ""
	get:
		return BoneIdx
@export_node_path("Bone2D") var Bone: NodePath:
	set(new_value):
		Bone=new_value
		if (Skeleton is Skeleton2D):
			if Bone:
				if BoneIdx != get_node(Bone).get_index_in_skeleton():
					BoneIdx = get_node(Bone).get_index_in_skeleton()
	get:
		return Bone
#endregion 
var TargetVector: Vector2


func _process(delta) -> void:
	if Enabled and TargetNode:
		handle_lookAt()

func handle_lookAt() -> void:
	var boneNode: Bone2D = get_node(Bone)
	TargetVector \
	= get_node(TargetNode).global_position - boneNode.global_position
	
	var isFlipped: int = int(sign(Skeleton.scale).x!=sign(Skeleton.scale).y)
	var isInverted: int = int(sign(Skeleton.scale).y==-1)
	var boneAngle: float
	
	if !isFlipped:
		boneAngle \
			= TargetVector.angle() \
			- boneNode.get_bone_angle() \
			- boneNode.get_parent().global_rotation
	else:
		boneAngle \
			= flip_angle(TargetVector.angle() \
			- boneNode.get_parent().global_rotation) \
			- boneNode.get_bone_angle() + PI
	
	var bonePos: Vector2 = boneNode.position 
	var jointTransform: Transform2D = Transform2D( boneAngle, bonePos).interpolate_with(boneNode.transform, Easing)
	boneNode.transform = jointTransform


func flip_angle(a: float) -> float:
	return PI - a

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


