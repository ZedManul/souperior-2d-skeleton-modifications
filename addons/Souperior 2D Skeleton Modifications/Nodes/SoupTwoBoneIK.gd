@tool
@icon("customIKIcon.png")
extends SoupMod
class_name SoupTwoBoneIK

## "Souperior" custom modification for Skeleton2D; Procedurally affects two bones to end at a target, if possible.

## Target node for the modification:
## 
## Defines the point to which the chain tries to go
@export var TargetNode: Node2D
## if true, the modification is calculated and applied
@export var Enabled: bool = false

## Flips the bend direction
@export var FlipBendDirection: bool = false

## Softness slows down the bones as the chain straightens.
##  
## With 0 softness, IK bones may move very quickly just before the target goes out of range, 
## which is usually undesirable
@export_range(0, 1, 0.01, "or_greater", "or_less") var Softness: float = 0:
	set(new_value):
		Softness=clampf(new_value,0,1)
	get:
		return Softness

@export_category("Bones")
#region Bone 1  
@export var JointOneBoneIdx: int = -1:
	set(new_value):
		JointOneBoneIdx=new_value
		if !(ModStack is SoupStack):
			return
		var Skeleton: Skeleton2D = ModStack.Skeleton
		if Skeleton is Skeleton2D:
			if (JointOneBoneIdx>=0)and(JointOneBoneIdx<Skeleton.get_bone_count()):
				if (JointOneBone != Skeleton.get_bone(JointOneBoneIdx)):
					JointOneBone = Skeleton.get_bone(JointOneBoneIdx)
					return
		if JointOneBone:
			JointOneBone = null
	get:
		return JointOneBoneIdx
@export var JointOneBone: Bone2D:
	set(new_value):
		JointOneBone=new_value
		if !(ModStack is SoupStack):
			return
		if (ModStack.Skeleton is Skeleton2D):
			if JointOneBone:
				if JointOneBoneIdx != JointOneBone.get_index_in_skeleton():
					JointOneBoneIdx = JointOneBone.get_index_in_skeleton()
	get:
		return JointOneBone
#endregion 
#region Bone 2
@export  var JointTwoBoneIdx: int = -1:
	set(new_value):
		JointTwoBoneIdx=new_value
		if !(ModStack is SoupStack):
			return
		var Skeleton: Skeleton2D = ModStack.Skeleton
		if Skeleton is Skeleton2D:
			if (JointTwoBoneIdx>=0)and(JointTwoBoneIdx<Skeleton.get_bone_count()):
				if (JointTwoBone != Skeleton.get_bone(JointTwoBoneIdx)):
					JointTwoBone = Skeleton.get_bone(JointTwoBoneIdx)
					return
		if JointTwoBone:
			JointTwoBone = null
	get:
		return JointTwoBoneIdx
@export var JointTwoBone: Bone2D:
	set(new_value):
		JointTwoBone=new_value
		if !(ModStack is SoupStack):
			return
		if (ModStack.Skeleton is Skeleton2D):
			if JointTwoBone:
				if JointTwoBoneIdx != JointTwoBone.get_index_in_skeleton():
					JointTwoBoneIdx = JointTwoBone.get_index_in_skeleton()
	get:
		return JointTwoBone
#endregion

@export_category("Easing")
@export_group("Joint One")
## Toggles Easing:
##
## This sort of easing is rather advanced 
## and may be unwanted on some modifications
@export var UseEasingOnJointOne: bool = false
## Easing Resource:
## 
## Defines easing behaviour
@export var JointOneEasing: SoupySecondOrderEasing:
	set(new_value):
		if new_value is SoupySecondOrderEasing: 
			JointOneEasing = new_value.duplicate(true)
		else: 
			JointOneEasing = null
	get:
		return JointOneEasing
@export_group("Joint Two")
## Toggles Easing:
##
## This sort of easing is rather advanced 
## and may be unwanted on some modifications
@export var UseEasingOnJointTwo: bool = false
## Easing Resource:
##
## Defines easing behaviour
@export var JointTwoEasing: SoupySecondOrderEasing:
	set(new_value):
		if new_value is SoupySecondOrderEasing: 
			JointTwoEasing = new_value.duplicate(true)
		else: 
			JointTwoEasing = null
	get:
		return JointTwoEasing

#region Calculation Related Variables
var FirstBone: Bone2D
var SecondBone: Bone2D
var TargetVector: Vector2
#endregion

func _ready() -> void:
	requests.append(ModificationRequest.new(-1,Transform2D.IDENTITY))
	requests.append(ModificationRequest.new(-1,Transform2D.IDENTITY))

func _process(delta) -> void:
	if Enabled and TargetNode and parent_enable_check():
		handle_IK(delta)
		ModStack.apply_modification(requests[0])
		ModStack.apply_modification(requests[1])

func handle_IK(delta: float) -> void:
	if !(ModStack is SoupStack):
			return
	var Skeleton: Skeleton2D = ModStack.Skeleton
	#region Updateding Calculation-related variables
	FirstBone = Skeleton.get_bone(JointOneBoneIdx)
	SecondBone = Skeleton.get_bone(JointTwoBoneIdx)
	TargetVector = calculate_target_vector()
	
	var distance: float = TargetVector.length()
	#endregion
	
	#region Angle calculation modifiers
	var isFlipped: int = int(sign(Skeleton.scale).x!=sign(Skeleton.scale).y)
	#var isInverted: int = int(sign(Skeleton.scale).y==-1)
	var bendDirMod: int = (int(!FlipBendDirection)*2 - 1)
	#endregion
	
	#initializing calculation result variables
	var bonePos: Vector2 = FirstBone.position 
	var boneAngle: float = 0.0
	
	#region handling first joint
	if !isFlipped:
		boneAngle = (TargetVector.angle() \
			+ bendDirMod * calculate_first_bone_angle() \
			- FirstBone.get_parent().global_rotation) \
			- FirstBone.get_bone_angle()
	else:
		boneAngle = flip_angle(TargetVector.angle() \
			- calculate_first_bone_angle() \
			- FirstBone.get_parent().global_rotation) \
			- FirstBone.get_bone_angle() + PI
	
	var jointTransform: Transform2D = Transform2D(boneAngle, Vector2.ONE, 0, bonePos)
	if UseEasingOnJointOne and (JointOneEasing is SoupySecondOrderEasing):
		JointOneEasing.update(delta,jointTransform.x)
		jointTransform = Transform2D(JointOneEasing.state.angle(),bonePos)
	requests[0].override(JointOneBoneIdx,jointTransform)
	#endregion
	
	
	#region handling second joint
	bonePos = SecondBone.position 
	boneAngle = bendDirMod * calculate_second_bone_angle() \
	+ FirstBone.get_bone_angle() \
	- SecondBone.get_bone_angle()
	
	jointTransform = Transform2D(boneAngle, Vector2.ONE, 0, bonePos)
	if UseEasingOnJointTwo and (JointTwoEasing is SoupySecondOrderEasing):
		JointTwoEasing.update(delta,jointTransform.x)
		jointTransform = Transform2D(JointTwoEasing.state.angle(),bonePos)
	requests[1].override(JointTwoBoneIdx,jointTransform)
	#endregion

func calculate_target_vector() -> Vector2:
	var realVector: Vector2 = TargetNode.global_position - FirstBone.global_position
	var boneDifference: float = abs(vectorize_bone(FirstBone).length() - vectorize_bone(SecondBone).length())
	
	var fullLength: float \
	= (vectorize_bone(FirstBone).length() + vectorize_bone(SecondBone).length()) \
	- boneDifference
	var distanceRatio: float = (realVector.length()-boneDifference)/fullLength
	var resultVector: Vector2 = realVector
	if Softness>0 and distanceRatio<(1+Softness) and distanceRatio>(1-Softness):
		resultVector=resultVector.normalized() * (boneDifference + fullLength * calculate_softness_result(distanceRatio))
	return resultVector

func vectorize_bone(bone: Bone2D) -> Vector2:
	var res = ((Vector2.RIGHT * bone.get_length()) \
	.rotated(bone.get_bone_angle()))
	return Vector2(res.x*ModStack.Skeleton.scale.x, res.y*ModStack.Skeleton.scale.y)

func calculate_bone_position(bone: Bone2D) -> Vector2:
	var bonedad=bone.get_parent()
	if bonedad is Bone2D:
		return vectorize_bone(bone.get_parent())
	elif bonedad is Skeleton2D: 
		return bone.position
	else:
		return Vector2.ZERO

func cos_from_sides(a: float, b: float, c: float) -> float:
	if a>0 and b>0:
		return (a*a+b*b-c*c)/(2*a*b)
	else:
		return 0.0

func calculate_first_bone_angle() -> float:
	if possibilityCheck():
		return PI * int(vectorize_bone(FirstBone).length()<vectorize_bone(SecondBone).length())
	else:
		return acos(cos_from_sides(\
			vectorize_bone(FirstBone).length(),\
			TargetVector.length(),\
			vectorize_bone(SecondBone).length()))

func calculate_second_bone_angle() -> float:
	if possibilityCheck():
		return PI
	else:
		return acos(cos_from_sides(\
			vectorize_bone(FirstBone).length(),\
			vectorize_bone(SecondBone).length(),\
			TargetVector.length())) - PI

func possibilityCheck() -> bool:
	return TargetVector.length()<0.001 or TargetVector.length() \
	< abs(vectorize_bone(FirstBone).length()-vectorize_bone(SecondBone).length())

func flip_angle(a: float) -> float:
	return PI - a

func calculate_softness_result(a:float):
	return -(0.25*(a-1-Softness)*(a-1-Softness)/Softness)+1
