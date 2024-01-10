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
@export var Enabled: bool = false:
	set(new_value):
		Enabled = new_value
		if Enabled:
			initialize_request(0, BoneIdx, SoupStack.Modification.ANGLE)
		else:
			free_request(0,BoneIdx)

@export_category("Bones")
#region Bone 
@export var BoneIdx: int = -1:
	set(new_value):
		BoneIdx=new_value
		if !(ModStack is SoupStack):
			return
		var Skeleton: Skeleton2D = ModStack.Skeleton
		if Skeleton is Skeleton2D:
			BoneIdx=clampi(new_value,0,Skeleton.get_bone_count()-1)
			initialize_request(0, BoneIdx, SoupStack.Modification.ANGLE)
			if (Bone != Skeleton.get_bone(BoneIdx)):
				Bone = Skeleton.get_bone(BoneIdx)
				return
		else:
			Bone = null

@export var Bone: Bone2D:
	set(new_value):
		Bone=new_value
		if !(ModStack is SoupStack):
			return
		if (ModStack.Skeleton is Skeleton2D):
			if Bone:
				if BoneIdx != Bone.get_index_in_skeleton():
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
		if new_value is SoupySecondOrderEasing: 
			Easing = new_value.duplicate(true)
		else: 
			Easing = null

func _process(delta) -> void:
	#print_debug(requests)
	if Enabled and TargetNode and parent_enable_check():
		handle_lookAt(delta)
		ModStack.execute_bone_modifications(BoneIdx)

func handle_lookAt(delta) -> void:
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
	var jointTransform: Transform2D = Transform2D(boneAngle, bonePos)
	if UseEasing and (Easing is SoupySecondOrderEasing):
		Easing.update(delta,jointTransform.x)
		jointTransform = Transform2D(Easing.state.angle(),bonePos)
	requests[0].modStruct.suggestedState = jointTransform

func flip_angle(a: float) -> float:
	return PI - a

func stack_hook_initialization():
	if Enabled:
		initialize_request(0, BoneIdx, SoupStack.Modification.ANGLE)

func _enter_tree() -> void:
	stack_hook_initialization()
