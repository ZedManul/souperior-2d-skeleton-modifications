@tool
@icon("Icons/icon_bone_state_component.png")
class_name SoupStateVariant
extends SoupStateComponent
## Can apply and record any property on a given node;
## NOTE: You cant pre-set the recorded value. You have to record.

## The monitored and modified node.
@export var target_node: Node
## The monitored and modified property.
@export var target_property: StringName
## The recorded value of the monitored and modified property.
var value: Variant


## When called, will set the chosen property on the target node to the recorded value.
func apply()->void:
	if !target_node:
		return
	
	if !(target_property in target_node):
		return
	
	target_node.set(target_property,value)


## When called, will record the chosen property from the target node.
func record()->void:
	if !target_node:
		return
	
	if !(target_property in target_node):
		return
	
	value = target_node.get(target_property)
