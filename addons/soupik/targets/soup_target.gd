@tool
class_name SoupTarget extends Marker2D


## Targeted node for the modification;
## It will be moved to the global coordinates of this node. 
@export var target_node: Node2D

## If true, the target is animated.
@export var enabled: bool = false

@export_enum("PROCESS", "PHYSICS_PROCESS") var ik_process_mode: int = 0:
	set(value):
		ik_process_mode = value
		set_process(ik_process_mode == 0)
		set_physics_process(ik_process_mode == 1)

@export var easing: ZMPhysEasingVec2:
	set(value):
		if value == null:
			easing = null
			return
		easing = value.duplicate()
		easing.force_set(global_position)

func _process(delta) -> void:
	process_loop(delta)


func _physics_process(delta) -> void:
	process_loop(delta)


func process_loop(delta) -> void:
	if (target_node == null or !enabled): return
	if (easing == null):
		target_node.global_position = global_position
		return
	
	easing.update(delta, global_position)
	target_node.global_position = easing.state
