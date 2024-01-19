@tool
@icon("Icons/icon_bone_state_component.png")
class_name SoupStateVariant
extends SoupStateComponent

@export var target_node: Node
@export var target_property: StringName
var value: Variant

func apply()->void:
	if !target_node:
		return
	
	if !(target_property in target_node):
		return
	
	target_node.set(target_property,value)


func record()->void:
	if !target_node:
		return
	
	if !(target_property in target_node):
		return
	
	value = target_node.get(target_property)
