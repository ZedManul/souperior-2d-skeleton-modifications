@tool
@icon("res://addons/soupik/icons/icon_modification.png")
class_name SoupMod
extends Node
## Base node for "Souperior" modifications;
## Does nothing by itself; dont put this in your tree.

## The modification stack this node belongs to.
#@onready var _mod_stack: SoupStack = _find_stack()

## The modification sub-stack this node belongs to.
@onready var _mod_group: Node = get_parent()

@export_enum("PROCESS", "PHYSICS_PROCESS") var ik_process_mode: int = 0:
	set(value):
		ik_process_mode = value
		set_process(ik_process_mode == 0)
		set_physics_process(ik_process_mode == 1)



var _scale_orient: int = 1


func _enter_tree() -> void:
	_mod_group = get_parent()
	#_mod_stack = _find_stack()


func _process(delta) -> void:
	process_loop(delta)
	#	print_debug("processingn....")


func _physics_process(delta) -> void:
	process_loop(delta)
	#print_debug("physics processingn....")


func process_loop(_delta):
	pass




## Checks if parent stack structures are enabled.
func _parent_enable_check() -> bool:
	if (_mod_group is SoupGroup):
		return (_mod_group.enabled
				and _mod_group.parent_enabled
				)
	else:
		return true
