@tool
@icon("Icons/customStackIcon.png")
extends Node
class_name SoupStack

## Skeleton affected by the modification stack
@onready var Skeleton: Skeleton2D = get_parent()

## if true, the modifications are applied
@export var Enabled: bool = true

func apply_bone_position_mod(boneIdx:int, targetPos: Vector2) -> void:
	var bone: Bone2D = Skeleton.get_bone(boneIdx)
	bone.position = apply_position_constraints(bone,targetPos)

func apply_bone_rotation_mod(boneIdx:int, targetRot: float) -> void:
	var bone: Bone2D = Skeleton.get_bone(boneIdx)
	bone.rotation = apply_rotation_constraints(bone,targetRot)

func apply_constraints(boneNode:Bone2D) -> void:
	apply_rotation_constraints(boneNode,boneNode.rotation)
	apply_position_constraints(boneNode,boneNode.position)

func apply_position_constraints(boneNode:Bone2D, targetPos: Vector2) -> Vector2:
	var fixedPosition: Vector2 = targetPos
	for i in boneNode.get_children():
		if !(i is SoupConstraint):
			continue
		if !i.Enabled or !i.LimitPosition:
			continue
		fixedPosition = targetPos\
		.clamp(i.PositionLimitOffset-i.PositionLimitRange\
		,i.PositionLimitOffset+i.PositionLimitRange)
	return fixedPosition

func apply_rotation_constraints(boneNode:Bone2D, targetRot: float) -> float:
	var fixedAngle: float = targetRot
	for i in boneNode.get_children():
		if !(i is SoupConstraint):
			continue
		if !i.Enabled or !i.LimitAngle:
			continue
		var angleDiff: float = angle_difference( i.AngleLimitCenter, targetRot)
		if abs(angleDiff)>=i.AngleLimitRange:
			fixedAngle = i.AngleLimitCenter \
			+ sign(angleDiff)*i.AngleLimitRange
	return fixedAngle

func _enter_tree() -> void:
	Skeleton = get_parent()
