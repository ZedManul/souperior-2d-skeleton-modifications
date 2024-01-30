@tool
@icon("Icons/icon_two_bone_ik.png")
class_name SoupFABRIK
extends SoupMod
## "Souperior" modification for Skeleton2D; Reaches for the target with a chain of bones.

## Target node for the modification;
## The bone is pointed towards this;
## To avoid unintended behaviour, make sure this node is NOT a child of a to-be-modified bone.
@export var target_node: Node2D

## If true, the modification is calculated and applied.
@export var enabled: bool = false

@export_category("Bones")

## The to-be-modified bone nodes.
@export var bone_node: Array[Bone2D]


var _base_point: Vector2
var _end_point: Vector2
var _joint_points: PackedVector2Array
var _limb_lengths: PackedFloat32Array
var _iterations: int = 16
