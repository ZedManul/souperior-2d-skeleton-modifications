@tool class_name SoupBoneRest extends SoupMod

enum RestType {
	NONE,
	POSITION,
	ROTATION_SCALE_SKEW,
	FULL_TRANSFORM
}

## BoneRest provides default coordinates for modified bones.
## It is not affected by strength, and exists to prevent bone positions drifting over time due to floating point imprecision.
## Also, all bones affected by this will only be movable via modifications as long as this is enabled.

## Which bones this modification keeps track of and how it modifies them.
@export var rested_bones: Dictionary[Bone2D,RestType]

## Saved transform values for modified bones.
@export var rested_bone_transforms: Dictionary[Bone2D,Transform2D]

@export_group("Buttons")
@export_tool_button("Record Rest Transforms", "Anchor") var record_btn_func: = record_func

func record_func() -> void:
	rested_bone_transforms.clear()
	for i: Bone2D in rested_bones:
		if !i: continue
		if i is SoupBone2D:
			rested_bone_transforms[i] = i.transform.rotated(-i.transform.get_rotation()).rotated(i.target_rotation)
			rested_bone_transforms[i].origin = i.target_position
			continue
		rested_bone_transforms[i] = i.transform

@export_tool_button("Auto Select Bones", "ToolBoneSelect") var select_btn_func: = select_func

func select_func() -> void:
	rested_bones.clear()
	_check_children(self)
	record_func.call()

func _check_children(_node: Node):
	for i in _node.get_children():
		if i is SoupBoneControl:
			rested_bones[i.bone_node] = RestType.FULL_TRANSFORM
		if i is SoupLookAt:
			rested_bones[i.bone_node] = RestType.FULL_TRANSFORM
		if i is SoupTwoBoneIK:
			rested_bones[i.joint_one_bone_node] = RestType.FULL_TRANSFORM
			rested_bones[i.joint_two_bone_node] = RestType.FULL_TRANSFORM
		if i is SoupFABRIK:
			for j in i.bone_nodes:
				rested_bones[j] = RestType.FULL_TRANSFORM
		
		_check_children(i)



func _process_loop(_delta):
	if !enable_check(): return
	
	for i: Bone2D in rested_bone_transforms.keys():
		if !i: continue
		if i is SoupBone2D:
			if rested_bones[i] == RestType.POSITION or rested_bones[i] == RestType.FULL_TRANSFORM:
				(i as SoupBone2D).target_position = rested_bone_transforms[i].get_origin()
			if rested_bones[i] == RestType.ROTATION_SCALE_SKEW or rested_bones[i] == RestType.FULL_TRANSFORM:
				(i as SoupBone2D).target_rotation = rested_bone_transforms[i].get_rotation()
				i.scale = rested_bone_transforms[i].get_scale()
				i.skew = rested_bone_transforms[i].get_skew()
			continue
		if rested_bones[i] == RestType.POSITION or rested_bones[i] == RestType.FULL_TRANSFORM:
			i.transform.origin = rested_bone_transforms[i].get_origin()
		if rested_bones[i] == RestType.ROTATION_SCALE_SKEW or rested_bones[i] == RestType.FULL_TRANSFORM:
			i.transform.x = rested_bone_transforms[i].x
			i.transform.y = rested_bone_transforms[i].y
