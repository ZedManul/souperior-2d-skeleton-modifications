@tool
@icon("res://addons/soupik/icons/icon_stay_at.png")
class_name SoupBoneControl
extends SoupMod

## "Souperior" modification for Skeleton2D; Moves bone to match its own or a target's position and/or angle.

## If true, target node's rotation and scale will be imparted onto the bone. 
@export var control_rotation: bool

## If true, target node's position will be imparted onto the bone. 
@export var control_position: bool

## Only has effect if Control Position is set to false; Makes itself or the target node inherit position from the bone.
@export var inherit_bone_position: bool

## The to-be-modified bone node.
@export var bone_node: Bone2D: 
	set(value):
		bone_node = value
		if Engine.is_editor_hint():
			update_configuration_warnings()

## Optional target node; otherwise targets the IK node itself.
@export var target_node: Node2D


@export_storage var target_position: Vector2 = Vector2.ZERO
@export_storage var target_rotation: float = 0.0

func _get_configuration_warnings():
	var warn_msg: Array[String] = []
	if !bone_node:
		warn_msg.append("Bone not set!")
	return warn_msg


func _process_loop(delta) -> void:
	if !(
			bone_node 
			and enable_check()
		):
		return
	scale_orient = sign(bone_node.global_transform.determinant())
	var _strength: = get_inherited_strength()
	handle_position_control(_strength)
	handle_rotation_control(_strength)


## [not intended for access]
## Handles position modification.
func handle_position_control(str: float) -> void:
	var _target: Node2D = self
	if target_node: _target = target_node
	if !control_position:
		if !inherit_bone_position: return
		_target.global_position = bone_node.global_position
		return
	
	if bone_node is SoupBone2D: 
		bone_node.set_target_position(bone_node.get_parent().to_global(bone_node.target_position).lerp(_target.global_position, str))
	else:
		bone_node.global_position = bone_node.global_position.lerp(_target.global_position, str)



## [not intended for access]
## Handles rotation modification.
func handle_rotation_control(str: float) -> void:
	var _target: Node2D = self
	if target_node: _target = target_node
	if !control_rotation: return
	
	var bone_rotat:float = bone_node.global_rotation

	target_rotation = _target.global_rotation
	bone_node.global_transform.x = _target.global_transform.x
	bone_node.global_transform.y = _target.global_transform.y
	bone_node.global_rotation = bone_rotat
	if bone_node is SoupBone2D: 
		bone_node.set_target_rotation(lerp_angle(bone_node.angle_to_global(bone_node.target_rotation), target_rotation, str))
	else:
		bone_node.global_rotation = lerp_angle(bone_node.global_rotation, target_rotation, str)


func _draw_gizmo() -> void:
	if target_node: draw_set_transform(to_local(target_node.global_position),target_node.global_rotation+global_rotation)
	draw_strength(strength_gizmo_scale)
	draw_control()

func draw_control()->void:
	var bone_gizmo_pointer: PackedVector2Array = [Vector2(1.0,0.0),Vector2(0.1,0.1),Vector2(0.0,0.0),Vector2(0.1,-0.1)]
	var bone_gizmo_side: PackedVector2Array = [Vector2(0.0,0.3),Vector2(0.1,0.1),Vector2(0.0,0.15),Vector2(-0.1,0.1)]

	var poly: PackedVector2Array
	var out_poly: PackedVector2Array
	if control_rotation:
		for i:Vector2 in bone_gizmo_pointer:
			var this_vec = (i * gizmo_size)
			poly.append(this_vec * Vector2(0.8, 0.8)+Vector2(gizmo_size/40.0,0))
			out_poly.append(this_vec)
		draw_colored_polygon(out_poly, Color.BLACK)
		draw_colored_polygon(poly, Color.AQUA)
	if !control_position: return
	for q: float in range(4.0):
		poly.clear()
		out_poly.clear()
		for i:Vector2 in bone_gizmo_side:
			var this_vec = (i * gizmo_size).rotated(q*PI/2.0)
			poly.append(this_vec * Vector2(0.8, 0.8)-Vector2(gizmo_size/40.0,0).rotated((q-1)*PI/2.0))
			out_poly.append(this_vec)
		draw_colored_polygon(out_poly, Color.BLACK)
		draw_colored_polygon(poly, Color.AQUA)
