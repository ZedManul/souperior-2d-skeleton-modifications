@tool
@icon("customStackIcon.png")
extends Node
class_name SoupStack

signal stack_dropped

## Skeleton affected by the modification stack
@onready var Skeleton: Skeleton2D = get_parent():
	set(new_value):
		Skeleton = new_value
		initialize_arrays()
		Skeleton.bone_setup_changed.connect(on_skeleton_changed)

## if true, the modifications are applied
@export var Enabled: bool = true

var BoneData: Array[BoneModData] = []


func _process(delta: float) -> void:
	pass


func execute() -> void:
	for i: int in Skeleton.get_bone_count():
		execute_bone_modifications(i)

func execute_bone_modifications(boneIdx:int) -> void:
	var bone: Bone2D = Skeleton.get_bone(boneIdx)
	bone.transform = BoneData[boneIdx].apply(bone)

func initialize_arrays():
	BoneData.clear()
	for i: int in Skeleton.get_bone_count():
		BoneData.append(BoneModData.new())
	stack_dropped.emit()

func on_skeleton_changed():
	initialize_arrays()

class Modification:
	enum {FULL, ANGLE, POSITION}
	var suggestedState: Transform2D
	var mode: int
	func _init(m: int ) -> void:
		mode = m

class BoneModData:
	var modifications: Array[Modification] = []
	
	func apply_constraints(constraint: SoupConstraint, target: Transform2D)->Transform2D:
		if !constraint.Enabled:
			return target
		var fixedAngle: float = target.get_rotation()
		if constraint.LimitAngle:
			var angleDiff: float = angle_difference( constraint.AngleLimitCenter\
			, target.get_rotation())
			if abs(angleDiff)>=constraint.AngleLimitRange:
				fixedAngle = constraint.AngleLimitCenter \
				+ sign(angleDiff)*constraint.AngleLimitRange
	
		var fixedPosition: Vector2 = target.get_origin()
		if constraint.LimitPosition:
			fixedPosition = target.get_origin()\
			.clamp(constraint.PositionLimitOffset\
			-constraint.PositionLimitRange\
			,constraint.PositionLimitOffset\
			+constraint.PositionLimitRange)
		return Transform2D(fixedAngle,target.get_scale(),target.get_skew(),fixedPosition)
	
	func apply(target: Bone2D)->Transform2D:
		var result: Transform2D = target.transform
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
		for i: Node in target.get_children(false):
			if i is SoupConstraint:
				result = apply_constraints(i,result)
		return result

func _enter_tree() -> void:
	Skeleton = get_parent()

