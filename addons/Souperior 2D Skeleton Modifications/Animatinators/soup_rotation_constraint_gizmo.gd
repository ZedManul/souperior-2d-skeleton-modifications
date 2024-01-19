@tool

extends Node2D
class_name SoupyAngleConstraintGizmo
@onready var _visualizee: SoupConstraint = get_parent()

func _ready() -> void:
	z_index =  2047
	top_level = true

func _draw() -> void:
	if _visualizee is SoupConstraint:
		if (
			_visualizee._bone_node is Bone2D 
			and _visualizee.draw_rotation_limit_gizmo 
			and _visualizee.limit_rotation
			and _visualizee.enabled 
			and Engine.is_editor_hint()
		):
			_draw_angle_constraint()

func _draw_angle_constraint():
	var bone: Bone2D = _visualizee._bone_node
	global_position = bone.global_position
	global_scale = bone.global_scale
	
	var bone_angle_correction = bone.get_bone_angle()*global_scale.y
	global_rotation = bone_angle_correction+bone.get_parent().global_rotation
	
	var gizmo_size:float = maxf(bone.get_length()/3,10)
	var gizmo_width:float = gizmo_size/20
	
	draw_arc(
			Vector2.ZERO, 
			gizmo_size*3/4, 
			_visualizee.rotation_limit_angle - _visualizee.rotation_limit_range,
			 _visualizee.rotation_limit_angle + _visualizee.rotation_limit_range,
			 7, Color(Color.BLACK,0.7), gizmo_width/2+1
		)
	_draw_gizmo_arrow_outline(
			gizmo_size,
			gizmo_width,
			_visualizee.rotation_limit_angle - _visualizee.rotation_limit_range,
			 1, Color.BLACK
		)
	_draw_gizmo_arrow_outline(
			gizmo_size,gizmo_width,
			_visualizee.rotation_limit_angle + _visualizee.rotation_limit_range
			, 1, Color.BLACK
		)
	
	draw_arc(
			Vector2.ZERO,
			gizmo_size*3/4, 
			_visualizee.rotation_limit_angle - _visualizee.rotation_limit_range,
			_visualizee.rotation_limit_angle + _visualizee.rotation_limit_range,
			 7, Color(Color.AQUA,0.7), gizmo_width/2
		)
	_draw_gizmo_arrow(
			gizmo_size,
			gizmo_width,
			_visualizee.rotation_limit_angle - _visualizee.rotation_limit_range,
			Color.ORANGE
		)
	_draw_gizmo_arrow(
			gizmo_size,
			gizmo_width,
			_visualizee.rotation_limit_angle + _visualizee.rotation_limit_range,
			Color.ORANGE
		)

func _draw_gizmo_arrow(length:float,width:float,angle:float, color: Color)->void: 
	var gizmo_point_array: PackedVector2Array 
	gizmo_point_array.append((Vector2.RIGHT*width)\
	.rotated(angle - PI/2))
	gizmo_point_array.append((Vector2.RIGHT*width)\
	.rotated(angle - 3*PI/4))
	gizmo_point_array.append((Vector2.RIGHT*width)\
	.rotated(angle + 3*PI/4))
	gizmo_point_array.append((Vector2.RIGHT*width)\
	.rotated(angle + PI/2))
	gizmo_point_array.append(Vector2(length,width/8)\
	.rotated(angle))
	gizmo_point_array.append(Vector2(length,-width/8)\
	.rotated(angle))
	draw_colored_polygon(gizmo_point_array,color)

func _draw_gizmo_arrow_outline(length:float,width:float,angle:float, girth:float, color: Color)->void:
	var gizmo_point_array: PackedVector2Array 
	gizmo_point_array.append((Vector2.RIGHT*(width+girth))\
	.rotated(angle - PI/2))
	gizmo_point_array.append((Vector2.RIGHT*(width+girth))\
	.rotated(angle - 3*PI/4))
	gizmo_point_array.append((Vector2.RIGHT*(width+girth))\
	.rotated(angle + 3*PI/4))
	gizmo_point_array.append((Vector2.RIGHT*(width+girth))\
	.rotated(angle + PI/2))
	gizmo_point_array.append((Vector2.RIGHT*length)\
	.rotated(angle + PI/128)\
	 + Vector2.RIGHT.rotated(angle + PI/4)*girth)
	gizmo_point_array.append((Vector2.RIGHT*length)\
	.rotated(angle - PI/128)\
	 + Vector2.RIGHT.rotated(angle - PI/4)*girth)
	draw_colored_polygon(gizmo_point_array,color)
