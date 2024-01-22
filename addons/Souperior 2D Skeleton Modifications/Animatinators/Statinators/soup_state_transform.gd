@tool
@icon("Icons/icon_bone_state_component.png")
class_name SoupStateTransform
extends SoupStateComponent
## Can apply and record certain important properties of a transform 2D component.

## The monitored and modified node.
@export var target_node: Node2D

@export_group("Position")
## If true, the node will apply or record this property when calling apply() or record() 
@export var modify_position: bool = false
## The recorded value.
@export var position_value:= Vector2.ZERO


@export_group("Rotation")
## If true, the node will apply or record this property when calling apply() or record() 
@export var modify_rotation: bool = false
## The recorded value.
@export var rotation_value: float = 0


@export_group("Scale")
## If true, the node will apply or record this property when calling apply() or record() 
@export var modify_scale: bool = false
## The recorded value.
@export var scale_value:= Vector2.ONE


@export_group("Skew")
## If true, the node will apply or record this property when calling apply() or record() 
@export var modify_skew: bool = false
## The recorded value.
@export var skew_value: float = 0


## When called, will set chosen properties on the target node to the recorded values.
func apply()->void:
	if !target_node:
		return
	
	super()
	
	if modify_position:
		target_node.position = position_value
	
	if modify_rotation:
		target_node.rotation = rotation_value
	
	if modify_scale:
		target_node.scale = scale_value
	
	if modify_skew:
		target_node.skew = skew_value


## When called, will record chosen properties from the target node.
func record()->void:
	if !target_node:
		return
	
	super()
	
	if modify_position:
		position_value = target_node.position
	
	if modify_rotation:
		rotation_value = target_node.rotation
	
	if modify_scale:
		scale_value = target_node.scale
	
	if modify_skew:
		skew_value = target_node.skew
