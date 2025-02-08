@tool
@icon("res://addons/soupik/icons/icon_modification.png")
class_name SoupMod
extends Node
## Base node for "Souperior" modifications;
## Does nothing by itself; dont put this in your tree.

## The modification sub-stack this node belongs to.
@onready var mod_group: Node = get_parent()

enum ProcessMode {
	PROCESS,
	PHYSICS_PROCESS
}

@export_enum("Process", "Physics Process") var ik_process_mode: int = ProcessMode.PROCESS:
	set(value):
		ik_process_mode = value
		set_process(ik_process_mode == ProcessMode.PROCESS)
		set_physics_process(ik_process_mode == ProcessMode.PROCESS)



var scale_orient: int = 1


func _enter_tree() -> void:
	mod_group = get_parent()


func _process(delta) -> void:
	_process_loop(delta)


func _physics_process(delta) -> void:
	_process_loop(delta)


func _process_loop(_delta):
	pass




## Checks if parent stack structures are enabled.
func parent_enable_check() -> bool:
	if (mod_group is SoupGroup):
		return (mod_group.enabled
				and mod_group.parent_enabled
				)
	else:
		return true
