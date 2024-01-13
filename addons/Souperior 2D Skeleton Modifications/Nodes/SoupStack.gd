@tool
@icon("Icons/customStackIcon.png")
extends Node
class_name SoupStack
## A skeleton's (spinal) brain;    
## All of the constraints and modifications go through this thing;
## MUST be a direct child of a Skeleton2D node.

## [not intended for access]
## Skeleton affected by the modification stack;
## Must be a direct parent to the stack node for constraints to work.
@onready var Skeleton: Skeleton2D = get_parent()
## If true, the modifications are applied.
@export var Enabled: bool = true

## Modifies a bone's position and applies constraints;
## Returns the resulting bone position.
func apply_bone_position_mod(boneNode:Bone2D, targetPos: Vector2) -> Vector2:
	boneNode.position = apply_position_constraints(boneNode,targetPos)
	return boneNode.position
## Modifies a bone's rotation and applies constraints;
## Returns the resulting bone rotation.
func apply_bone_rotation_mod(boneNode:Bone2D, targetRot: float) -> float:
	boneNode.rotation = apply_rotation_constraints(boneNode,targetRot)
	return boneNode.rotation
## Applies bone constraints to the current bone rotation and position.
func apply_constraints(boneNode:Bone2D) -> void:
	boneNode.rotation = apply_rotation_constraints(boneNode,boneNode.rotation)
	boneNode.position = apply_position_constraints(boneNode,boneNode.position)
## Returns resulting position from applying constraints to a given bone.
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
## Returns resulting rotation from applying constraints to a given bone.
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
