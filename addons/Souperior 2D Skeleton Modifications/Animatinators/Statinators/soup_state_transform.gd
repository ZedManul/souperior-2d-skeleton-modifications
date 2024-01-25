@tool
@icon("Icons/icon_bone_state_component.png")
class_name SoupStateTransform
extends SoupStateComponent
## Can apply and record certain important properties of a transform 2D component.

## The monitored and modified node.
@export var target_node: Node2D

## Number of saved state positions.
@export var state_count: int = 1:
	set(new_value):
		state_count = max(1,new_value)
		_resize_value_arrays()


## Selected state position.
@export var current_state: int:
	set(new_value):
		current_state = clampi(new_value,0,state_count-1)

@export_group("Position")
## If true, the node will apply or record this property when calling apply() or record() 
@export var modify_position: bool = false
## The recorded value.
@export var position_value: PackedVector2Array:
	set(new_value):
		position_value = new_value
		position_value.resize(state_count)


@export_group("Rotation")
## If true, the node will apply or record this property when calling apply() or record() 
@export var modify_rotation: bool = false
## The recorded value.
@export var rotation_value: PackedFloat32Array:
	set(new_value):
		rotation_value = new_value
		rotation_value.resize(state_count)

@export_group("Scale")
## If true, the node will apply or record this property when calling apply() or record() 
@export var modify_scale: bool = false
## The recorded value.
@export var scale_value: PackedVector2Array:
	set(new_value):
		scale_value = new_value
		scale_value.resize(state_count)


@export_group("Skew")
## If true, the node will apply or record this property when calling apply() or record() 
@export var modify_skew: bool = false
## The recorded value.
@export var skew_value: PackedFloat32Array:
	set(new_value):
		skew_value = new_value
		skew_value.resize(state_count)


## When called, will set chosen properties on the target node to the recorded values.
func apply()->void:
	if !target_node:
		return
	
	super()
	
	if modify_position:
		target_node.position = position_value[current_state]
	
	if modify_rotation:
		target_node.rotation = rotation_value[current_state]
	
	if modify_scale:
		target_node.scale = scale_value[current_state]
	
	if modify_skew:
		target_node.skew = skew_value[current_state]


## When called, will record chosen properties from the target node.
func record()->void:
	if !target_node:
		return
	
	super()
	
	if modify_position:
		position_value[current_state] = target_node.position
	
	if modify_rotation:
		rotation_value[current_state] = target_node.rotation
	
	if modify_scale:
		scale_value[current_state] = target_node.scale
	
	if modify_skew:
		skew_value[current_state] = target_node.skew


func _resize_value_arrays() -> void:
	position_value.resize(state_count)
	rotation_value.resize(state_count)
	scale_value.resize(state_count)
	skew_value.resize(state_count)
