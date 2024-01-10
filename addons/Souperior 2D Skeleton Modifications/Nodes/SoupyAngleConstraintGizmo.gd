@tool

extends Node2D
class_name SoupyAngleConstraintGizmo
@onready var visualizee: SoupConstraint = get_parent()



func _draw() -> void:
	if visualizee is SoupConstraint:
		if visualizee.Bone is Bone2D \
		and visualizee.DrawAngleLimitGizmo and visualizee.LimitAngle\
		and visualizee.Enabled and Engine.is_editor_hint():
			draw_angle_constraint()

func draw_angle_constraint():
	var bone: Bone2D = visualizee.Bone
	global_position = bone.global_position
	global_scale = bone.global_scale
	var bone_angle_correction = bone.get_bone_angle()*global_scale.y
	global_rotation = bone_angle_correction+bone.get_parent().global_rotation
	var gizmoSize:float = maxf(bone.get_length()/3,10)
	var gizmoWidth:float = gizmoSize/20
	
	draw_arc(Vector2.ZERO\
	, gizmoSize*3/4\
	, visualizee.AngleLimitCenter - visualizee.AngleLimitRange\
	, visualizee.AngleLimitCenter + visualizee.AngleLimitRange\
	, 7, Color(Color.BLACK,0.7), gizmoWidth/2+1)
	draw_gizmo_arrow_outline(gizmoSize,gizmoWidth\
	,visualizee.AngleLimitCenter - visualizee.AngleLimitRange\
	, 1, Color.BLACK)
	draw_gizmo_arrow_outline(gizmoSize,gizmoWidth\
	,visualizee.AngleLimitCenter + visualizee.AngleLimitRange\
	, 1, Color.BLACK)
	
	draw_arc(Vector2.ZERO\
	, gizmoSize*3/4\
	, visualizee.AngleLimitCenter - visualizee.AngleLimitRange\
	, visualizee.AngleLimitCenter + visualizee.AngleLimitRange\
	, 7, Color(Color.AQUA,0.7), gizmoWidth/2)
	draw_gizmo_arrow(gizmoSize,gizmoWidth\
	,visualizee.AngleLimitCenter - visualizee.AngleLimitRange\
	,Color.ORANGE)
	draw_gizmo_arrow(gizmoSize,gizmoWidth\
	,visualizee.AngleLimitCenter + visualizee.AngleLimitRange\
	,Color.ORANGE)

func draw_gizmo_arrow(length:float,width:float,angle:float, color: Color)->void: 
	var gizmoPointArray: PackedVector2Array 
	gizmoPointArray.append((Vector2.RIGHT*width)\
	.rotated(angle - PI/2))
	gizmoPointArray.append((Vector2.RIGHT*width)\
	.rotated(angle - 3*PI/4))
	gizmoPointArray.append((Vector2.RIGHT*width)\
	.rotated(angle + 3*PI/4))
	gizmoPointArray.append((Vector2.RIGHT*width)\
	.rotated(angle + PI/2))
	gizmoPointArray.append(Vector2(length,width/8)\
	.rotated(angle))
	gizmoPointArray.append(Vector2(length,-width/8)\
	.rotated(angle))
	draw_colored_polygon(gizmoPointArray,color)

func draw_gizmo_arrow_outline(length:float,width:float,angle:float, girth:float, color: Color)->void:
	var gizmoPointArray: PackedVector2Array 
	gizmoPointArray.append((Vector2.RIGHT*(width+girth))\
	.rotated(angle - PI/2))
	gizmoPointArray.append((Vector2.RIGHT*(width+girth))\
	.rotated(angle - 3*PI/4))
	gizmoPointArray.append((Vector2.RIGHT*(width+girth))\
	.rotated(angle + 3*PI/4))
	gizmoPointArray.append((Vector2.RIGHT*(width+girth))\
	.rotated(angle + PI/2))
	gizmoPointArray.append((Vector2.RIGHT*length)\
	.rotated(angle + PI/128)\
	 + Vector2.RIGHT.rotated(angle + PI/4)*girth)
	gizmoPointArray.append((Vector2.RIGHT*length)\
	.rotated(angle - PI/128)\
	 + Vector2.RIGHT.rotated(angle - PI/4)*girth)
	draw_colored_polygon(gizmoPointArray,color)
