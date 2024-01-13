@tool
@icon("Icons/customIKIcon.png")
extends SoupMod
class_name SoupTwoBoneIK

## "Souperior" custom modification for Skeleton2D; 
## Affects two bones to end at a target, if possible.

## Target node for the modification;
## Defines the point which the bones try to reach;
## /!\ To avoid unintended behaviour, make sure this node is NOT a child of the to-be-modified bones.
@export var TargetNode: Node2D
## If true, the modification is calculated and applied.
@export var Enabled: bool = false

## Flips the bend direction.
@export var FlipBendDirection: bool = false

## Softness slows down the bones as the chain straightens;
## With 0 softness, IK bones may move very quickly just before the target goes out of range, 
## which is usually undesirable
@export_range(0, 1, 0.01, "or_greater", "or_less") var Softness: float = 0:
	set(new_value):
		Softness=clampf(new_value,0,1)

@export_category("Bones")
#region Bone 1  
## Index of the bone which will be modified to act as the first joint.
@export var JointOneBoneIdx: int = -1:
	set(new_value):
		JointOneBoneIdx=new_value
		if !(ModStack is SoupStack):
			return
		var Skeleton: Skeleton2D = ModStack.Skeleton
		if !(Skeleton is Skeleton2D):
			JointOneBone = null
			return
		JointOneBoneIdx=clampi(new_value,0,Skeleton.get_bone_count()-1)

		if (JointOneBone != Skeleton.get_bone(JointOneBoneIdx)):
			JointOneBone = Skeleton.get_bone(JointOneBoneIdx)

## Bone node which will be modified to act as the first joint.
@export var JointOneBone: Bone2D:
	set(new_value):
		JointOneBone=new_value
		if !(ModStack is SoupStack):
			return
		if (ModStack.Skeleton is Skeleton2D and JointOneBone is Bone2D and JointOneBoneIdx != JointOneBone.get_index_in_skeleton()):
			JointOneBoneIdx = JointOneBone.get_index_in_skeleton()

#endregion 
#region Bone 2
## Index of the bone which will be modified to act as the second joint;
## Must be a child of the first joint bone for the modification to work properly.
@export  var JointTwoBoneIdx: int = -1:
	set(new_value):
		JointTwoBoneIdx=new_value
		if !(ModStack is SoupStack):
			JointTwoBone = null
			return
		var Skeleton: Skeleton2D = ModStack.Skeleton
		if !(Skeleton is Skeleton2D):
			return
		JointTwoBoneIdx=clampi(new_value,0,Skeleton.get_bone_count()-1)
		if (JointTwoBone != Skeleton.get_bone(JointTwoBoneIdx)):
			JointTwoBone = Skeleton.get_bone(JointTwoBoneIdx)

## Bone node which will be modified to act as the first joint;
## Must be a child of the first joint bone for the modification to work properly.
@export var JointTwoBone: Bone2D:
	set(new_value):
		JointTwoBone=new_value
		if !(ModStack is SoupStack):
			return
		if (ModStack.Skeleton is Skeleton2D and JointTwoBone is Bone2D and JointTwoBoneIdx != JointTwoBone.get_index_in_skeleton()):
			JointTwoBoneIdx = JointTwoBone.get_index_in_skeleton()
#endregion

#region Easing
@export_category("Easing")
@export_group("Joint One")
## If true, easing is appied to the first joint.
@export var UseEasingOnJointOne: bool = false
## Easing Resource;
## Defines easing behaviour for the first joint.
@export var JointOneEasing: SoupySecondOrderEasingNoG:
	set(new_value):
		if !new_value:
			JointOneEasing = null
			return
		JointOneEasing = new_value.duplicate(true)

@export_group("Joint Two")
## If true, easing is appied to the second joint.
@export var UseEasingOnJointTwo: bool = false
## Easing Resource;
## Defines easing behaviour for the second joint.
@export var JointTwoEasing: SoupySecondOrderEasingNoG:
	set(new_value):
		if !new_value:
			JointTwoEasing = null
			return
		JointTwoEasing = new_value.duplicate(true)
#endregion

## [not intended for access]
## Used for calculations.
var TargetVector: Vector2
func _process(delta) -> void:
	if Enabled and TargetNode and parent_enable_check():
		handle_IK(delta)

## [not intended for access]
## Handles the modification.
func handle_IK(delta: float) -> void:
	if !(ModStack is SoupStack):
		return
	var Skeleton: Skeleton2D = ModStack.Skeleton

	TargetVector = calculate_target_vector()
	var distance: float = TargetVector.length()
	
	#region Angle calculation modifiers
	var isFlipped: int = int(sign(Skeleton.scale).x!=sign(Skeleton.scale).y)
	var bendDirMod: int = (int(!FlipBendDirection)*2 - 1)
	#endregion
	
	#initializing calculation result variables
	var boneAngle: float = (TargetVector.angle() \
	- JointOneBone.get_parent().global_rotation)*sign(JointOneBone.global_scale.y) \
	+ bendDirMod * calculate_first_bone_angle() \
	- JointOneBone.get_bone_angle()
	
	if UseEasingOnJointOne and JointOneEasing:
		JointOneEasing.update(delta,Vector2.RIGHT.rotated(boneAngle))
		boneAngle = JointOneEasing.state.angle()
	
	var fixedAngle: float = ModStack.apply_bone_rotation_mod(JointOneBone,boneAngle)
	if fixedAngle and JointOneEasing and UseEasingOnJointOne:
		JointOneEasing.state = Vector2.RIGHT.rotated(fixedAngle)
	#region handling second joint
	boneAngle = bendDirMod * calculate_second_bone_angle() \
	+ JointOneBone.get_bone_angle() \
	- JointTwoBone.get_bone_angle()
	
	if UseEasingOnJointTwo and JointTwoEasing:
		JointTwoEasing.update(delta,Vector2.RIGHT.rotated(boneAngle))
		boneAngle = JointTwoEasing.state.angle()
	fixedAngle = ModStack.apply_bone_rotation_mod(JointTwoBone,boneAngle)
	if fixedAngle and JointTwoEasing and UseEasingOnJointTwo:
		JointTwoEasing.state = Vector2.RIGHT.rotated(fixedAngle)
	#endregion

## [not intended for access]
## Handles additional calculations to account for softness.
func calculate_target_vector() -> Vector2:
	var realVector: Vector2 = TargetNode.global_position - JointOneBone.global_position
	var boneDifference: float = abs(vectorize_bone(JointOneBone).length() - vectorize_bone(JointTwoBone).length())
	
	var fullLength: float \
	= (vectorize_bone(JointOneBone).length() + vectorize_bone(JointTwoBone).length()) \
	- boneDifference
	var distanceRatio: float = (realVector.length()-boneDifference)/fullLength
	var resultVector: Vector2 = realVector
	if Softness>0 and distanceRatio<(1+Softness) and distanceRatio>(1-Softness):
		resultVector=resultVector.normalized() * (boneDifference + fullLength * calculate_softness_result(distanceRatio))
	return resultVector
## [not intended for access]
## Handles even more additional calculations to account for softness.
func calculate_softness_result(a:float):
	return -(0.25*(a-1-Softness)*(a-1-Softness)/Softness)+1
## [not intended for access]
## Used for abstracting some internal calculations.
func vectorize_bone(bone: Bone2D) -> Vector2:
	#print_debug(bone.get_length(),bone.position.length())
	var res = ((Vector2.RIGHT * bone.get_length()) \
	.rotated(bone.get_bone_angle()))
	return Vector2(res.x*bone.global_scale.x, res.y*bone.global_scale.y)
## [not intended for access]
## The mathemagical function that basically runs the IK.
func cos_from_sides(a: float, b: float, c: float) -> float:
	if a>0 and b>0:
		return (a*a+b*b-c*c)/(2*a*b)
	else:
		return 0.0
## [not intended for access]
## Applies mathemagic to the first joint.
func calculate_first_bone_angle() -> float:
	if possibilityCheck():
		return PI * int(vectorize_bone(JointOneBone).length()<vectorize_bone(JointTwoBone).length())
	else:
		return acos(cos_from_sides(\
			vectorize_bone(JointOneBone).length(),\
			TargetVector.length(),\
			vectorize_bone(JointTwoBone).length()))
## [not intended for access]
## Applies mathemagic to the second joint
func calculate_second_bone_angle() -> float:
	if possibilityCheck():
		return PI
	else:
		return acos(cos_from_sides(\
			vectorize_bone(JointOneBone).length(),\
			vectorize_bone(JointTwoBone).length(),\
			TargetVector.length())) - PI

## Checks if the distance to the target node is reachable with the current setup.
func possibilityCheck() -> bool:
	return TargetVector.length()<0.001 or TargetVector.length() \
	< abs(vectorize_bone(JointOneBone).length()-vectorize_bone(JointTwoBone).length())


