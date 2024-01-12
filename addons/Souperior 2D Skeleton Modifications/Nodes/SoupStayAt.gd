@tool
@icon("Icons/customStayAtIcon.png")
extends SoupMod
class_name SoupStayAt

@export var target: Node2D
@export var Enabled: bool = false:
	set(new_value):
		Enabled = new_value
		fix_easing()

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
		fix_easing()
#endregion 

#region Easing
@export_category("Easing")
## Toggles Easing:
##
## This sort of easing is rather advanced 
## and may be unwanted on some modifications
@export var UseEasing: bool = false:
	set(new_value):
		UseEasing = new_value
		fix_easing()
## Easing Resource:
##
## Defines easing behaviour
@export var Easing: SoupySecondOrderEasing: 
	set(new_value):
		if !new_value:
			Easing = null
			return
		Easing = new_value.duplicate(true)
		if !Bone:
			return
		fix_easing()
#endregion

func _ready() -> void:
	fix_easing()

func _process(delta: float) -> void:
	if !(Enabled and target and parent_enable_check()):
		return
	var resultPos: Vector2 = target.global_position
	if Easing and UseEasing:
		Easing.update(delta,target.global_position)
		resultPos = Easing.state
	var fixedPos: Vector2 = ModStack.apply_bone_position_mod(Bone, PositionGlobalToLocal(resultPos, Bone.get_parent()))
	if fixedPos and Easing and UseEasing:
		Easing.state = PositionLocalToGlobal(fixedPos, Bone.get_parent())

func fix_easing():
	if !(Easing and Bone and target):
		return
	Easing.initialize_variables(target.global_position)



