@tool
@icon("customIKIcon.png")
extends Node
class_name SoupTwoBoneIK

## "Souperior" custom modification for Skeleton2D; Procedurally affects two bones to end at a target, if possible.

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
				handle_IK()
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


@export var FlipBendDirection: bool = false
## Softness slows down the bones as the constrained bones straighten. 
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
		if Skeleton is Skeleton2D:
			if (JointOneBoneIdx>=0)and(JointOneBoneIdx<Skeleton.get_bone_count()):
				if (JointOneBone != Skeleton.get_bone(JointOneBoneIdx).get_path()):
					JointOneBone = Skeleton.get_bone(JointOneBoneIdx).get_path()
					return
		if JointOneBone:
			JointOneBone = ""
	get:
		return JointOneBoneIdx
@export_node_path("Bone2D") var JointOneBone: NodePath:
	set(new_value):
		JointOneBone=new_value
		if (Skeleton is Skeleton2D):
			if JointOneBone:
				if JointOneBoneIdx != get_node(JointOneBone).get_index_in_skeleton():
					JointOneBoneIdx = get_node(JointOneBone).get_index_in_skeleton()
	get:
		return JointOneBone
#endregion 

#region Bone 2
@export  var JointTwoBoneIdx: int = -1:
	set(new_value):
		JointTwoBoneIdx=new_value
		if Skeleton is Skeleton2D:
			if (JointTwoBoneIdx>=0)and(JointTwoBoneIdx<Skeleton.get_bone_count()):
				if (JointTwoBone != Skeleton.get_bone(JointTwoBoneIdx).get_path()):
					JointTwoBone = Skeleton.get_bone(JointTwoBoneIdx).get_path()
					return
		if JointTwoBone:
			JointTwoBone = ""
	get:
		return JointTwoBoneIdx
@export_node_path("Bone2D") var JointTwoBone: NodePath:
	set(new_value):
		JointTwoBone=new_value
		if (Skeleton is Skeleton2D):
			if JointTwoBone:
				if JointTwoBoneIdx != get_node(JointTwoBone).get_index_in_skeleton():
					JointTwoBoneIdx = get_node(JointTwoBone).get_index_in_skeleton()
	get:
		return JointTwoBone
#endregion




#region Calculation Related Variables
var FirstBone: Bone2D
var SecondBone: Bone2D
var TargetVector: Vector2
#endregion




func _process(delta) -> void:
	if Enabled and TargetNode:
		handle_IK()


func handle_IK() -> void:
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
	FirstBone.transform = jointTransform.interpolate_with(FirstBone.get_transform(), Easing)
	#endregion
	
	
	#region handling second joint
	bonePos = SecondBone.position 
	boneAngle = bendDirMod * calculate_second_bone_angle() \
	+ FirstBone.get_bone_angle() \
	- SecondBone.get_bone_angle()
	
	jointTransform = Transform2D(boneAngle, Vector2.ONE, 0, bonePos)
	SecondBone.transform = jointTransform.interpolate_with(SecondBone.transform, Easing)
	#endregion

func calculate_target_vector() -> Vector2:
	var realVector: Vector2 = get_node(TargetNode).global_position - FirstBone.global_position
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
	return Vector2(res.x*Skeleton.scale.x, res.y*Skeleton.scale.y)

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
