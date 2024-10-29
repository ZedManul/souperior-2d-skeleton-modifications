@tool

extends Node2D

@export var target_node: Node2D

@export var easing_x: ZMPhysEasingScalar:
	set(value):
		easing_x = value.duplicate(true)
		
		easing_x.initialize_variables(global_position.x)

@export var easing_y: ZMPhysEasingScalar:
	set(value):
		easing_y = value.duplicate(true)
		
		easing_y.initialize_variables(global_position.y)

@export var easing_a: ZMPhysEasingAngular:
	set(value):
		easing_a = value.duplicate(true)
		
		easing_a.initialize_variables(global_rotation)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if target_node == null:
		return
	if easing_x == null:
		target_node.global_position.x = global_position.x
	else:
		easing_x.update(delta, global_position.x)
		target_node.global_position.x = easing_x.state
	
	if easing_y == null:
		target_node.global_position.y = global_position.y
	else:
		easing_y.update(delta, global_position.y)
		target_node.global_position.y = easing_y.state
	
	
	if easing_a == null:
		target_node.global_rotation = global_rotation
	else:
		easing_a.update(delta, global_rotation)
		target_node.global_rotation = easing_a.state
