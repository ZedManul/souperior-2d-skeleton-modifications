@tool
@icon("customStackIcon.png")
extends Node
class_name SoupStack

signal stack_dropped

## Skeleton affected by the modification stack
@onready @export var Skeleton: Skeleton2D = find_skeledaddy():
	set(new_value):
		Skeleton = new_value
		Skeleton.bone_setup_changed.connect(on_skeleton_changed)

## if true, the modifications are applied
@export var Enabled: bool = true

var BoneData: Array[BoneModData] = []

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	pass

func execute() -> void:
	for i: int in Skeleton.get_bone_count():
		execute_bone_modifications(i)

func execute_bone_modifications(boneIdx:int) -> void:
	var bone: Bone2D = Skeleton.get_bone(boneIdx)
	bone.transform = BoneData[boneIdx].apply(bone.transform)

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

func initialize_arrays():
	BoneData.clear()
	for i: int in Skeleton.get_bone_count():
		BoneData.append(BoneModData.new())
	stack_dropped.emit()

func on_skeleton_changed():
	initialize_arrays()

class AngleConstraint:
	var angleLimitCenter: float
	var angleLimitRange: float
	func apply(target: Transform2D) -> Transform2D:
		var angleDiff: float = angle_difference( angleLimitCenter\
		, target.get_rotation())
		if abs(angleDiff)>=angleLimitRange:
			var fixedAngle: float = angleLimitCenter+sign(angleDiff)*angleLimitRange
			return Transform2D(fixedAngle\
			, target.get_scale(), target.get_skew(), target.get_origin())
		return target
	func _init(aLimC: float = 0, aLimR: float =PI/4):
		angleLimitCenter = aLimC
		angleLimitRange = aLimR

class PositionConstraint:
	var offset: Vector2
	var range: Vector2:
		set(new_value):
			range = new_value.clamp(Vector2.ZERO,abs(new_value)+Vector2.ONE)
	
	func _init(pLimO: Vector2 = Vector2.ZERO, pLimR: Vector2 = Vector2.ONE):
		offset = pLimO
		range = pLimR
	
	func apply(target: Transform2D) -> Transform2D:
		var result:Vector2
		result = target.get_origin().clamp(offset-range,offset+range)
		return Transform2D(target.x, target.y, result)

class Modification:
	enum {FULL, ANGLE, POSITION}
	var suggestedState: Transform2D
	var mode: int
	func _init(m: int ) -> void:
		mode = m

class BoneModData:
	var modifications: Array[Modification] = []
	var aConstraints: Array[AngleConstraint] = []
	var pConstraints: Array[PositionConstraint] = []
	
	func apply(target: Transform2D)->Transform2D:
		var result: Transform2D = target
		for i:Modification in modifications:
			match i.mode:
				Modification.FULL: 
					result = i.suggestedState
				Modification.ANGLE: 
					result = Transform2D(i.suggestedState.get_rotation() \
					, result.get_scale(),result.get_skew(),result.get_origin())
				Modification.POSITION: 
					result = Transform2D(result.get_rotation(), result.get_scale(),result.get_skew()\
					,i.suggestedState.get_origin())
		for i:AngleConstraint in aConstraints:
			result = i.apply(result)
			
		for i:PositionConstraint in pConstraints:
			result = i.apply(result)
		return result
