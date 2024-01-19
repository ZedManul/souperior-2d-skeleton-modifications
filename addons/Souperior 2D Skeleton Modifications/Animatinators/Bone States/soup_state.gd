@tool
@icon("Icons/icon_bone_state.png")
class_name SoupState
extends Node

signal state_applied()
signal state_recorded()

@export var apply_state: bool = false:
	set(new_value):
		apply_state = false
		apply()

@export var record_state: bool = false:
	set(new_value):
		record_state = false
		record()


func apply()->void:
	for i: Node in get_children(false):
		if i is SoupStateComponent:
			i.apply()
	print_debug("State Applied!")


func record()->void:
	for i: Node in get_children(false):
		if i is SoupStateComponent:
			i.record()
	print_debug("State Recorded!")
