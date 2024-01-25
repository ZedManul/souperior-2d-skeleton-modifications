@tool
@icon("Icons/icon_bone_state_component.png")
class_name SoupStateVariant
extends SoupStateComponent
## Can apply and record any property on a given node;
## NOTE: You cant pre-set the recorded value. You have to record.

## The monitored and modified node.
@export var target_node: Node

## Number of saved state positions.
@export var state_count: int = 1:
	set(new_value):
		state_count = max(1,new_value)
		_resize_value_arrays()

## Selected state position.
@export var current_state: int:
	set(new_value):
		current_state = clampi(new_value,0,state_count-1)

## The monitored and modified property.
@export var target_property: StringName
## The recorded value of the monitored and modified property.
var value: Array[Variant]


## When called, will set the chosen property on the target node to the recorded value.
func apply()->void:
	if !target_node:
		return
	
	if !(target_property in target_node):
		return
	
	target_node.set(target_property,value[current_state])


## When called, will record the chosen property from the target node.
func record()->void:
	if !target_node:
		return
	
	if !(target_property in target_node):
		return
	
	value[current_state] = target_node.get(target_property)


func _resize_value_arrays() -> void:
	value.resize(state_count)
