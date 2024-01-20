@tool
@icon("Icons/icon_bone_state_component.png")
class_name SoupStateTransform
extends SoupStateComponent


@export var target_node: Node2D


@export_group("Position")

@export var modify_position: bool = false

@export var position_value:= Vector2.ZERO


@export_group("Rotation")

@export var modify_rotation: bool = false

@export var rotation_value: float = 0


@export_group("Scale")

@export var modify_scale: bool = false

@export var scale_value:= Vector2.ONE


@export_group("Skew")

@export var modify_skew: bool = false

@export var skew_value: float = 0

func apply()->void:
	if !target_node:
		return
	
	if modify_position:
		target_node.position = position_value
	
	if modify_rotation:
		target_node.rotation = rotation_value
	
	if modify_scale:
		target_node.scale = scale_value
	
	if modify_skew:
		target_node.skew = skew_value


func record()->void:
	if !target_node:
		return
	
	if modify_position:
		position_value = target_node.position
	
	if modify_rotation:
		rotation_value = target_node.rotation
	
	if modify_scale:
		scale_value = target_node.scale
	
	if modify_skew:
		skew_value = target_node.skew
