@tool
@icon("Icons/custom_transform_stack_icon.png")
class_name SoupTransformStacker
extends Node2D



@export var enabled: bool = true

@export var stack_vector: Vector2 = Vector2.ZERO

@export var offset: float = 0

@export var reference_node: Node2D

@export var stacked_nodes: Array[Node2D]

func _process(delta: float) -> void:
	if !enabled:
		return
	
	var global_stack_vector = stack_vector
	if reference_node:
		global_stack_vector = \
				global_stack_vector.rotated(reference_node.global_rotation)
	
	var stack_height = stacked_nodes.size()
	if (
			stack_height == 1
		):
		if stacked_nodes[0]:
			stacked_nodes[0].global_rotation = \
					global_rotation
			stacked_nodes[0].global_position = \
					global_position
	else:
		for i: int in stack_height:
			if !stacked_nodes[i]:
				continue
			stacked_nodes[i].global_rotation = \
					global_rotation
			stacked_nodes[i].global_position = \
					global_position \
					+ global_stack_vector * (offset + (float(i) / float(stack_height - 1)))
