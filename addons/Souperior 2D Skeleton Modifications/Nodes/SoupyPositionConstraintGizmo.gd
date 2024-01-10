@tool

extends Node2D
class_name SoupyPositionConstraintGizmo
@onready var visualizee: SoupConstraint = get_parent()



func _draw() -> void:
	if visualizee is SoupConstraint:
		if visualizee.Bone is Bone2D \
		and visualizee.DrawPositionLimitGizmo and visualizee.LimitPosition\
		and visualizee.Enabled and Engine.is_editor_hint():
			draw_position_constraint()

func draw_position_constraint():
	var bone: Bone2D = visualizee.Bone
	var boneDaddy: Node2D = bone.get_parent()
	var posLimR: Vector2 = visualizee.PositionLimitRange
	
	global_position = boneDaddy.global_position \
	+ visualizee.PositionLimitOffset.rotated(boneDaddy.global_rotation)
	global_scale = boneDaddy.global_scale
	global_rotation = boneDaddy.global_rotation
	var gizmoSize:float = maxf(bone.get_length()/3,10)
	var gizmoWidth:float = gizmoSize/10
	
	var edgeColor: Color = Color(Color.AQUA,0.6)
	var cornerColor: Color = Color.ORANGE
	
	draw_gizmo_border(posLimR.y,posLimR.x,gizmoWidth,0,edgeColor)
	draw_gizmo_border(-posLimR.y,posLimR.x,gizmoWidth,PI,edgeColor)
	draw_gizmo_border(-posLimR.y,posLimR.x,gizmoWidth,0,edgeColor)
	draw_gizmo_border(posLimR.y,posLimR.x,gizmoWidth,PI,edgeColor)
	draw_gizmo_border(posLimR.x,posLimR.y,gizmoWidth,PI/2,edgeColor)
	draw_gizmo_border(-posLimR.x,posLimR.y,gizmoWidth,3*PI/2,edgeColor)
	draw_gizmo_border(-posLimR.x,posLimR.y,gizmoWidth,PI/2,edgeColor)
	draw_gizmo_border(posLimR.x,posLimR.y,gizmoWidth,3*PI/2,edgeColor)
	
	draw_gizmo_corner(posLimR.y,posLimR.x,gizmoWidth+1,0,Color.BLACK)
	draw_gizmo_corner(-posLimR.y,posLimR.x,gizmoWidth+1,0,Color.BLACK)
	draw_gizmo_corner(posLimR.y,-posLimR.x,gizmoWidth+1,0,Color.BLACK)
	draw_gizmo_corner(-posLimR.y,-posLimR.x,gizmoWidth+1,0,Color.BLACK)
	
	draw_gizmo_corner(posLimR.y,posLimR.x,gizmoWidth,0,cornerColor)
	draw_gizmo_corner(-posLimR.y,posLimR.x,gizmoWidth,0,cornerColor)
	draw_gizmo_corner(posLimR.y,-posLimR.x,gizmoWidth,0,cornerColor)
	draw_gizmo_corner(-posLimR.y,-posLimR.x,gizmoWidth,0,cornerColor)
	
	

	

func draw_gizmo_border(offset:float,length:float,width:float,angle:float,color:Color)->void:
	var gizmoPointArray: PackedVector2Array 
	gizmoPointArray.append((Vector2(0,width/8+offset)).rotated(angle))
	gizmoPointArray.append((Vector2(-length+width/3,width/3+offset)).rotated(angle))
	gizmoPointArray.append((Vector2(-length-width*2,0+offset)).rotated(angle))
	gizmoPointArray.append((Vector2(-length+width/3,-width/3+offset)).rotated(angle))
	gizmoPointArray.append((Vector2(0,-width/8+offset)).rotated(angle))
	
	draw_colored_polygon(gizmoPointArray,color)

func draw_gizmo_corner(offset:float,length:float,width:float,angle:float,color:Color)->void:
	var gizmoPointArray: PackedVector2Array 
	gizmoPointArray.append((Vector2(-length,width/2+offset)).rotated(angle))
	gizmoPointArray.append((Vector2(-length-width/2, offset)).rotated(angle))
	gizmoPointArray.append((Vector2(-length,-width/2+offset)).rotated(angle))
	gizmoPointArray.append((Vector2(-length+width/2, offset)).rotated(angle))
	
	draw_colored_polygon(gizmoPointArray,color)
