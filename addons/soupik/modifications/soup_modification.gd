@tool
@icon("res://addons/soupik/icons/icon_modification.png")
class_name SoupMod
extends Node2D
## Base node for "Souperior" modifications;
## Does nothing by itself, but can be used for organisation to toggle groups of modifications at once.

## If false, this modification and its children in the tree will not be applied.
@export var enabled: bool = false

## How much the modification affects the skeleton. Useful for transitions in animation or mixing multiple modifications.
@export_range(0, 1, 0.01, "or_greater", "or_less") var strength: float = 1.0:
	set(value):
		strength = clampf(value,0.0,1.0)


enum ProcessMode {
	PROCESS,
	PHYSICS_PROCESS
}

@export_enum("Process", "Physics Process") var ik_process_mode: int = ProcessMode.PROCESS:
	set(value):
		ik_process_mode = value
		set_process(ik_process_mode == ProcessMode.PROCESS)
		set_physics_process(ik_process_mode == ProcessMode.PHYSICS_PROCESS)

var scale_orient: int = 1

func _process(delta) -> void:
	_process_loop(delta)


func _physics_process(delta) -> void:
	_process_loop(delta)


func _process_loop(_delta):
	pass


## Checks if parent modifications are enabled.
func enable_check() -> bool:
	var mod_group = get_parent()
	if (mod_group is SoupMod):
		return enabled and mod_group.enable_check()
	return enabled

## Returns strength, accounting for parent modifications.
func get_inherited_strength() -> float:
	var mod_group = get_parent()
	if (mod_group is SoupMod):
		return strength * mod_group.get_inherited_strength()
	return strength
