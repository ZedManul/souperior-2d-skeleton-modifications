@tool
class_name SoupyStateAngleFixInatorGizmo
extends Node2D
## [Not intended for access]


@onready var _visualizee: SoupStateAngleFixInator = get_parent()


func _ready() -> void:
	z_index = 2048
	top_level = true


func _draw() -> void:
	if _visualizee is SoupStateAngleFixInator:
		if (
			_visualizee.bone_node is Node2D 
			and _visualizee.draw_gizmo 
			and _visualizee.enabled 
			and Engine.is_editor_hint()
		):
			_draw_border_star()


func _draw_border_star() -> void:
	var node: Bone2D = _visualizee.bone_node
	global_position = node.global_position
	global_scale = node.global_scale
	
	global_rotation = node.get_parent().global_rotation
	
	var border_color = Color(Color.AQUA,0.9)
	var arrow_color = Color(Color.ORANGE,0.7)
	var gizmo_size:float = _visualizee.gizmo_size
	for i: Vector2 in _visualizee._border_vectors:
		_draw_border_beam(i,gizmo_size, border_color)
	
	_draw_rotation_arrow(_visualizee.true_rotation,gizmo_size,arrow_color)


func _draw_border_beam(beam_vector: Vector2, size: float, color: Color) -> void:
	var gizmo_point_array: PackedVector2Array 
	gizmo_point_array.append(Vector2(0,size/20)\
			.rotated(beam_vector.angle()))
	gizmo_point_array.append(Vector2(-size/20,0)\
			.rotated(beam_vector.angle()))
	gizmo_point_array.append(Vector2(0,-size/20)\
			.rotated(beam_vector.angle()))
	gizmo_point_array.append(Vector2(4 * size * beam_vector.length(),0)\
			.rotated(beam_vector.angle()))
	
	var gizmo_color_array: PackedColorArray
	gizmo_color_array.append(Color.TRANSPARENT)
	gizmo_color_array.append(color)
	gizmo_color_array.append(Color.TRANSPARENT)
	gizmo_color_array.append(Color.TRANSPARENT)
	
	draw_polygon(gizmo_point_array,gizmo_color_array)


func _draw_rotation_arrow(arrow_rotation: float, size: float, color: Color) -> void:
	var gizmo_point_array: PackedVector2Array 
	gizmo_point_array.append(Vector2(0,size/20)\
			.rotated(arrow_rotation))
	gizmo_point_array.append(Vector2(-size/20,0)\
			.rotated(arrow_rotation))
	gizmo_point_array.append(Vector2(0,-size/20)\
			.rotated(arrow_rotation))
	gizmo_point_array.append(Vector2(3 * size ,0)\
			.rotated(arrow_rotation))
	
	
	draw_colored_polygon(gizmo_point_array,color)
