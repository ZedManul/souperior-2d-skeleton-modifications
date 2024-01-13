@tool
class_name SoupyPositionConstraintGizmo
extends Node2D

@onready var _visualizee: SoupConstraint = get_parent()

func _ready() -> void:
	z_index = 2048
	top_level = true

func _draw() -> void:
	if _visualizee is SoupConstraint:
		if (
			_visualizee._bone_node is Bone2D 
			and _visualizee.draw_position_limit_gizmo 
			and _visualizee.limit_position
			and _visualizee.enabled 
			and Engine.is_editor_hint()
		):
			_draw_position_constraint()

func _draw_position_constraint():
	var bone: Bone2D = _visualizee._bone_node
	var bone_daddy: Node2D = bone.get_parent()
	var pos_lim_range: Vector2 = _visualizee.position_limit_range
	
	global_position = bone_daddy.global_position \
	+ (_visualizee.position_limit_offset).rotated(bone_daddy.global_rotation*sign(bone_daddy.global_scale.y))*bone_daddy.global_scale
	global_scale = bone_daddy.global_scale
	global_rotation = bone_daddy.global_rotation
	var gizmo_size:float = maxf(bone.get_length()/3,10)
	var gizmo_width:float = gizmo_size/10
	
	var edge_color: Color = Color(Color.AQUA,0.6)
	var corner_color: Color = Color.ORANGE
	
	_draw_gizmo_border(pos_lim_range.y,pos_lim_range.x,gizmo_width,0,edge_color)
	_draw_gizmo_border(-pos_lim_range.y,pos_lim_range.x,gizmo_width,PI,edge_color)
	_draw_gizmo_border(-pos_lim_range.y,pos_lim_range.x,gizmo_width,0,edge_color)
	_draw_gizmo_border(pos_lim_range.y,pos_lim_range.x,gizmo_width,PI,edge_color)
	_draw_gizmo_border(pos_lim_range.x,pos_lim_range.y,gizmo_width,PI/2,edge_color)
	_draw_gizmo_border(-pos_lim_range.x,pos_lim_range.y,gizmo_width,3*PI/2,edge_color)
	_draw_gizmo_border(-pos_lim_range.x,pos_lim_range.y,gizmo_width,PI/2,edge_color)
	_draw_gizmo_border(pos_lim_range.x,pos_lim_range.y,gizmo_width,3*PI/2,edge_color)
	
	_draw_gizmo_corner(pos_lim_range.y,pos_lim_range.x,gizmo_width+1,0,Color.BLACK)
	_draw_gizmo_corner(-pos_lim_range.y,pos_lim_range.x,gizmo_width+1,0,Color.BLACK)
	_draw_gizmo_corner(pos_lim_range.y,-pos_lim_range.x,gizmo_width+1,0,Color.BLACK)
	_draw_gizmo_corner(-pos_lim_range.y,-pos_lim_range.x,gizmo_width+1,0,Color.BLACK)
	
	_draw_gizmo_corner(pos_lim_range.y,pos_lim_range.x,gizmo_width,0,corner_color)
	_draw_gizmo_corner(-pos_lim_range.y,pos_lim_range.x,gizmo_width,0,corner_color)
	_draw_gizmo_corner(pos_lim_range.y,-pos_lim_range.x,gizmo_width,0,corner_color)
	_draw_gizmo_corner(-pos_lim_range.y,-pos_lim_range.x,gizmo_width,0,corner_color)


func _draw_gizmo_border(offset:float,length:float,width:float,angle:float,color:Color)->void:
	var gizmo_point_array: PackedVector2Array 
	gizmo_point_array.append((Vector2(0,width/8+offset)).rotated(angle))
	gizmo_point_array.append((Vector2(-length+width/3,width/3+offset)).rotated(angle))
	gizmo_point_array.append((Vector2(-length-width*2,0+offset)).rotated(angle))
	gizmo_point_array.append((Vector2(-length+width/3,-width/3+offset)).rotated(angle))
	gizmo_point_array.append((Vector2(0,-width/8+offset)).rotated(angle))
	
	draw_colored_polygon(gizmo_point_array,color)

func _draw_gizmo_corner(offset:float,length:float,width:float,angle:float,color:Color)->void:
	var gizmo_point_array: PackedVector2Array 
	gizmo_point_array.append((Vector2(-length,width/2+offset)).rotated(angle))
	gizmo_point_array.append((Vector2(-length-width/2, offset)).rotated(angle))
	gizmo_point_array.append((Vector2(-length,-width/2+offset)).rotated(angle))
	gizmo_point_array.append((Vector2(-length+width/2, offset)).rotated(angle))
	
	draw_colored_polygon(gizmo_point_array,color)
