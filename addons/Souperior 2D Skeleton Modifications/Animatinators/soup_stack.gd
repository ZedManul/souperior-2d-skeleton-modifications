@tool
@icon("Icons/icon_stack.png")
class_name SoupStack
extends Node
## A skeleton's (spinal) brain;    
## All of the constraints and modifications go through this thing;
## MUST be a direct child of a Skeleton2D node.

## If true, the modifications are applied.
@export var enabled: bool = true

## [not intended for access]
## skeleton affected by the modification stack;
## Must be a direct parent to the stack node for constraints to work.
@onready var skeleton: Skeleton2D = get_parent()


func _enter_tree() -> void:
	skeleton = get_parent()
