@tool
@icon("res://addons/soupik/icons/icon_modification_group.png")
class_name SoupGroup
extends Node
## Used for grouping modifications within a stack;
## Allows for toggling whole groups at once.

## If true, the child modifications are applied.
@export var enabled: bool = true:
	set(new_value):
		enabled = new_value
		for i in get_children(false):
			if i is SoupGroup:
				i.parent_enabled = enabled and parent_enabled

var parent_enabled: bool = true:
	set(new_value):
		parent_enabled = new_value
		for i in get_children(false):
			if i is SoupGroup:
				i.parent_enabled = enabled and parent_enabled


func _enter_tree() -> void:
	var parent = get_parent()
	if parent is SoupGroup:
		parent_enabled = parent.enabled and parent.parent_enabled

func _ready() -> void:
	var parent = get_parent()
	if parent is SoupGroup:
		parent_enabled = parent.enabled and parent.parent_enabled
