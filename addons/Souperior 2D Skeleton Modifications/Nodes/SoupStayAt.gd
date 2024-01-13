@tool
@icon("Icons/customStayAtIcon.png")
extends SoupMod
class_name SoupStayAt
## "Souperior" modification for Skeleton2D; 
## Moves bone's global position to a target global position;
## Can be used as a jiggle modifier for the bone's position!

## Target node for the modification;
## The bone tries to stay at the global position of this node;
## /!\ To avoid unintended behaviour, make sure this node is NOT a child of the to-be-modified bone.
@export var target: Node2D
@export var Enabled: bool = false:
	set(new_value):
		Enabled = new_value
		fix_easing()

@export_category("Bones")
#region Bone 
## Index of the to-be-modified bone in the skeleton.
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
## The to-be-modified bone node.
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
## If true, easing is appied;
## Required for the effect to feel "jiggly".
@export var UseEasing: bool = false:
	set(new_value):
		UseEasing = new_value
		fix_easing()
## Easing Resource;
## Defines easing behaviour.
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

## Updates the internal variables of the easing resource to match the current wanted state;
## Prevents weird behaviour on bone change, scene reload, or any other situation that may cause the easing internals to become outdated.
func fix_easing():
	if !(Easing and Bone and target):
		return
	Easing.initialize_variables(target.global_position)



