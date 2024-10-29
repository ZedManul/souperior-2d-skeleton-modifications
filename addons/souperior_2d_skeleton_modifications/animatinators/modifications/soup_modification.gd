@tool
@icon("Icons/icon_modification.png")
class_name SoupMod
extends Node
## Base node for "Souperior" modifications;
## Does nothing by itself; dont put this in your tree.

## The modification stack this node belongs to.
@onready var _mod_stack: SoupStack = _find_stack()

## The modification sub-stack this node belongs to.
@onready var _mod_sub_stack: Node = get_parent()

@export_enum("PROCESS", "PHYSICS_PROCESS") var ik_process_mode: int = 0:
	set(value):
		ik_process_mode = value
		set_process(ik_process_mode == 0)
		set_physics_process(ik_process_mode == 1)



var _scale_orient: int = 1


func _enter_tree() -> void:
	_mod_sub_stack = get_parent()
	_mod_stack = _find_stack()


func _process(delta) -> void:
	process_loop(delta)
	#	print_debug("processingn....")


func _physics_process(delta) -> void:
	process_loop(delta)
	#print_debug("physics processingn....")


func process_loop(_delta):
	pass


## Fetches the modification stack this node belongs to.
func _find_stack() -> SoupStack:
	var found_node: Node = get_parent()
	for i in 1000:
		if found_node is SoupStack:
			return found_node
		elif found_node is SoupSubStack:
			found_node = found_node.get_parent()
			continue
		elif found_node == get_tree().root:
			break
	return null


## Checks if parent stack structures are enabled.
func _parent_enable_check() -> bool:
	if !(_mod_stack is SoupStack):
		return false
	if (_mod_sub_stack is SoupSubStack):
		return (
				_mod_stack.enabled 
				and _mod_sub_stack.enabled
				and _mod_sub_stack.parent_enabled
				)
	else:
		return _mod_stack.enabled
