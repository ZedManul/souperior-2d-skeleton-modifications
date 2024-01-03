@tool
@icon("customLookAtIcon.png")
extends SoupMod
class_name SoupLookAt

## "Souperior" custom modification for Skeleton2D; Points bone angle at the target.


## Target node for the modification;
## 
## Points the bone at it.
@export var TargetNode: Node2D

## if true, the modification is calculated and applied
@export var Enabled: bool = false

## Easing value for the modification. 
## 
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
		if !(ModStack is SoupStack):
			return
		var Skeleton: Skeleton2D = ModStack.Skeleton
		if Skeleton is Skeleton2D:
			if (BoneIdx>=0)and(BoneIdx<Skeleton.get_bone_count()):
				if (Bone != Skeleton.get_bone(BoneIdx)):
					Bone = Skeleton.get_bone(BoneIdx)
					return
		if Bone:
			Bone = null
	get:
		return BoneIdx
@export var Bone: Bone2D:
	set(new_value):
		Bone=new_value
		if !(ModStack is SoupStack):
			return
		if (ModStack.Skeleton is Skeleton2D):
			if Bone:
				if BoneIdx != Bone.get_index_in_skeleton():
					BoneIdx = Bone.get_index_in_skeleton()
	get:
		return Bone
#endregion 
var TargetVector: Vector2

func _ready() -> void:
	requests.append(ModificationRequest.new(-1,Transform2D.IDENTITY))

func _process(delta) -> void:
	if Enabled and TargetNode and parent_enable_check():
		handle_lookAt()
		ModStack.apply_modification(requests[0])

func handle_lookAt() -> void:
	if !(ModStack is SoupStack):
			return
	var Skeleton: Skeleton2D = ModStack.Skeleton
	TargetVector \
	=TargetNode.global_position - Skeleton.get_bone(BoneIdx).global_position
	
	var isFlipped: int = int(sign(Skeleton.scale).x!=sign(Skeleton.scale).y)
	var isInverted: int = int(sign(Skeleton.scale).y==-1)
	var boneAngle: float
	
	if !isFlipped:
		boneAngle \
			= TargetVector.angle() \
			- Bone.get_bone_angle() \
			- Bone.get_parent().global_rotation
	else:
		boneAngle \
			= flip_angle(TargetVector.angle() \
			- Bone.get_parent().global_rotation) \
			- Bone.get_bone_angle() + PI
	
	var bonePos: Vector2 = Bone.position 
	var jointTransform: Transform2D = Transform2D( boneAngle, bonePos).interpolate_with(Bone.transform, Easing)
	requests[0].override(BoneIdx,jointTransform)

func flip_angle(a: float) -> float:
	return PI - a




