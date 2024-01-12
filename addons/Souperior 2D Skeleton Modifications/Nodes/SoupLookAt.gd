@tool
@icon("Icons/customLookAtIcon.png")
extends SoupMod
class_name SoupLookAt

## "Souperior" custom modification for Skeleton2D; Points bone angle at the target.

## Target node for the modification;
## 
## Points the bone at it.
@export var TargetNode: Node2D

## if true, the modification is calculated and applied
@export var Enabled: bool = false

@export_category("Bones")
#region Bone 
@export var BoneIdx: int = -1:
	set(new_value):
		BoneIdx=new_value
		if !(ModStack is SoupStack):
			return
		var Skeleton: Skeleton2D = ModStack.Skeleton
		if !(Skeleton is Skeleton2D):
			Bone = null
			return
		BoneIdx=clampi(new_value,0,Skeleton.get_bone_count()-1)
		if (Bone != Skeleton.get_bone(BoneIdx)):
			Bone = Skeleton.get_bone(BoneIdx)
			return

@export var Bone: Bone2D:
	set(new_value):
		Bone=new_value
		if !(ModStack is SoupStack):
			return
		if (ModStack.Skeleton is Skeleton2D and Bone is Bone2D and BoneIdx != Bone.get_index_in_skeleton()):
			BoneIdx = Bone.get_index_in_skeleton()
		
#endregion 

var TargetVector: Vector2

@export_category("Easing")
## Toggles Easing:
##
## This sort of easing is rather advanced 
## and may be unwanted on some modifications
@export var UseEasing: bool = false
## Easing Resource:
##
## Defines easing behaviour
@export var Easing: SoupySecondOrderEasing: 
	set(new_value):
		if !(new_value is SoupySecondOrderEasing):
			Easing = null
			return
		Easing = new_value.duplicate(true)


func _process(delta) -> void:
	if Enabled and TargetNode and parent_enable_check():
		handle_lookAt(delta)

func handle_lookAt(delta) -> void:
	if !(ModStack is SoupStack):
		return
	var Skeleton: Skeleton2D = ModStack.Skeleton
	TargetVector \
	=TargetNode.global_position - Bone.global_position
	
	var resultAngle = AngleGlobalToLocal(\
	(TargetVector.angle())*sign(Bone.global_scale.y)\
	-Bone.get_bone_angle(),Bone.get_parent())
	if UseEasing and Easing:
		Easing.update(delta,Vector2.RIGHT.rotated(resultAngle))
		resultAngle = Easing.state.angle()
	
	var fixedAngle: float = ModStack.apply_bone_rotation_mod(Bone,resultAngle)
	if fixedAngle and Easing and UseEasing:
		Easing.state = Vector2.RIGHT.rotated(fixedAngle)


