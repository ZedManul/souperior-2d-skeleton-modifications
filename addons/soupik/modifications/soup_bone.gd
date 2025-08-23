@tool
@icon("res://addons/soupik/icons/icon_soup_bone.png")
class_name SoupBone2D extends Bone2D
enum EasingMode {
	PROCESS,
	PHYSICS_PROCESS
}

enum TransformMode {
	IK,
	MANUAL,
	RECORDING_TARGET
}

@export_enum("IK", "Manual", "Recording Target") var transform_mode: int = TransformMode.RECORDING_TARGET

@export var target_rotation: float = 0.0:
	set(value):
		target_rotation = wrapf(value, -PI, PI)
@export var target_position: Vector2 = Vector2.ZERO

@export_category("Easing")
@export_enum("Process", "Physics Process") var easing_process_mode: int = EasingMode.PROCESS:
	set(value):
		easing_process_mode = value
		set_process(easing_process_mode == EasingMode.PROCESS)
		set_physics_process(easing_process_mode == EasingMode.PHYSICS_PROCESS)
@export_group("Rotation")
@export var ease_rotation: bool = false
@export var rotation_easing_params: ZMPhysEasingRotationalParams
@export_group("Position")
@export var ease_position: bool = false
@export var position_easing_params: ZMPhysEasingParams

@export_category("Constraints")
@export var limit_rotation: bool = false
@export var limit_position: bool = false
@export var constraint_data: ZMConstraintData
@export var hide_constraint_gizmo: bool = false

var offset_angle: float = get_bone_angle()

#region position easing vars
var prev_global_pos: Vector2 = global_position
var prev_global_target_pos = global_position
var global_pos_change: Vector2 = Vector2.ZERO
var prev_global_pos_change: Vector2 = Vector2.ZERO
#endregion

#region rotation easing vars
var prev_global_rotat: float = global_rotation
var prev_global_target_rotat: float = global_rotation
var global_rotat_change: float = 0
var prev_global_rotat_change: float = 0
#endregion


#region gizmo vars
var angle_gizmo_poly: PackedVector2Array = PackedVector2Array([
			Vector2(-0.1,0),
			Vector2(-0.1,0.05),
			Vector2(0,0.1),
			Vector2(1,0.01),
			Vector2(1,0)
		])
#endregion


func _get_configuration_warnings():
	var warn_msg: Array[String] = []
	if transform_mode == TransformMode.RECORDING_TARGET:
		warn_msg.append("IK wont be applied while Recording Target")
	if ease_position and !position_easing_params:
		warn_msg.append("Position Easing Parameters not set!")
	if ease_rotation:
		if !rotation_easing_params:
			warn_msg.append("Rosition Easing Parameters not set!")
		elif !rotation_easing_params.params:
			warn_msg.append("Rosition Easing Parameters not set!")
	if !constraint_data and (limit_position or limit_rotation):
		warn_msg.append("Constraint Data not set!")
	return warn_msg


func _enter_tree() -> void:
	target_rotation = rotation
	target_position = position


func _ready() -> void:
	init_rotation()
	init_position()


func _process(delta: float) -> void:
	_process_loop(delta)


func _physics_process(delta: float) -> void:
	_process_loop(delta)


func _process_loop(delta: float) -> void:
	if Engine.is_editor_hint():
		queue_redraw()
	if !is_node_ready():
		await ready
	offset_angle = get_bone_angle() * sign(global_transform.determinant())
	match transform_mode:
		TransformMode.IK:
			handle_position_change(delta)
			handle_rotation_change(delta)
		TransformMode.MANUAL:
			pass
		TransformMode.RECORDING_TARGET:
			record_target_transform()
	update_prev_states()


func init_position() -> void:
	position = target_position
	prev_global_pos = global_position
	prev_global_target_pos = globalify_position(target_position)


func init_rotation() -> void:
	rotation = target_rotation
	prev_global_rotat = global_rotation
	prev_global_target_rotat = globalify_rotat(target_rotation)


func update_prev_states() -> void:
	prev_global_target_pos = globalify_position(target_position)
	prev_global_pos = global_position
	
	prev_global_target_rotat = globalify_rotat(target_rotation)
	prev_global_rotat = global_rotation


func record_target_transform() -> void:
	target_rotation = rotation
	target_position = position


func handle_position_change(delta: float) -> void:
	global_position = prev_global_pos ## Pinning global position
	if limit_position:
		target_position = constraint_position(target_position)
	if !ease_position:
		position = target_position
		return
	
	handle_position_easing(delta)


func handle_position_easing(delta: float) -> void:
	var stable_k2: float = position_easing_params.calculate_stable_k2(delta)
	var global_target_pos: Vector2 = globalify_position(target_position)
	var global_target_pos_change: Vector2 = (global_target_pos - prev_global_target_pos) / delta
	global_position += (global_pos_change + prev_global_pos_change) / 2 * delta
	
	if limit_position: 
		position = constraint_position(position)
	
	global_pos_change += delta * ( \
			position_easing_params.gravity + \
			global_target_pos + position_easing_params.k3 * global_target_pos_change - \
			global_position - position_easing_params.k1 * global_pos_change \
		) / stable_k2
	prev_global_pos_change = global_pos_change


func handle_rotation_change(delta: float) -> void:
	global_rotation = angle_wrap(prev_global_rotat)
	if limit_rotation:
		target_rotation = constraint_rotation(target_rotation + offset_angle) - offset_angle
	if !ease_rotation or !rotation_easing_params:
		rotation = target_rotation
		return
	if !rotation_easing_params.params:
		return
	handle_rotation_easing(delta)


func handle_rotation_easing(delta: float) -> void:
	var stable_k2: float = rotation_easing_params.params.calculate_stable_k2(delta)
	var global_target_rotat: float = globalify_rotat(target_rotation)
	var global_target_rotat_change: float = angle_diff(global_target_rotat, prev_global_target_rotat) / delta 
	global_rotation += (global_rotat_change + prev_global_rotat_change) / 2 * delta
	global_rotation = angle_wrap(global_rotation)
	
	
	var extra_force: Vector2 = (prev_global_pos - global_position) * rotation_easing_params.velocity_effect * delta
	var force_sum: Vector2 = extra_force + rotation_easing_params.params.gravity * PI / 180.0 
	var force_orient: float = angle_diff(force_sum.angle(),angle_wrap(global_rotation + offset_angle))
	var force_effect: float = force_orient * abs(sin(force_orient)) * force_sum.length()
	
	if limit_rotation:
		rotation = constraint_rotation(rotation + offset_angle) - offset_angle
	
	global_rotat_change += delta * ( \
			force_effect + \
			angle_diff(global_target_rotat, global_rotation) - \
			rotation_easing_params.params.k1 * global_rotat_change + \
			rotation_easing_params.params.k3 * global_target_rotat_change
		) / stable_k2	
	
	prev_global_rotat_change = global_rotat_change


func constraint_position(pos: Vector2) -> Vector2:
	if !constraint_data:
		return pos
	var s = pos - constraint_data.area_offset
	s = s.rotated(-constraint_data.area_rotation)
	s = s / constraint_data.proportions
	s = s.limit_length(1.0)
	s = s * constraint_data.proportions
	s = s.rotated(constraint_data.area_rotation)
	s = s + constraint_data.area_offset
	return s


func constraint_rotation(angle: float) -> float:
	if !constraint_data:
		return angle
	if angle_difference(angle, constraint_data.rotation_direction) > constraint_data.rotation_half_arc:
		return constraint_data.rotation_direction - constraint_data.rotation_half_arc
	if angle_difference(angle, constraint_data.rotation_direction) < -constraint_data.rotation_half_arc:
		return constraint_data.rotation_direction + constraint_data.rotation_half_arc
	return angle


func set_target_rotation(i: float) -> void:
	target_rotation = localify_rotat(i)


func set_target_position(i: Vector2) -> void:
	target_position = localify_position(i)


#region Helper Functions
func globalify_position(i: Vector2) -> Vector2:
	var ref: Node = get_parent()
	if not (ref is Node2D):
		return i
	return (i * ref.global_scale).rotated(ref.global_rotation) + ref.global_position

func localify_position(i: Vector2) -> Vector2:
	var ref: Node = get_parent()
	if not (ref is Node2D):
		return i
	return (i-ref.global_position).rotated(-ref.global_rotation) / ref.global_scale


func globalify_rotat(i: float) -> float:
	var ref: Node = get_parent()
	if not (ref is Node2D):
		return i
	var v: Vector2 = Vector2.from_angle(i)
	return (v * ref.global_scale).angle() + ref.global_rotation


func localify_rotat(i: float) -> float:
	var ref: Node = get_parent()
	if not (ref is Node2D):
		return i
	var v: Vector2 = Vector2.from_angle(i - ref.global_rotation)
	return (v / ref.global_scale).angle()


func angle_wrap(i: float) -> float:
	return wrapf(i, -PI, PI)

func angle_diff(i: float, j: float) -> float:
	var d: float = i-j
	if abs(d+TAU) < abs (d) || abs(d-TAU) < abs(d): d = angle_wrap(d + TAU)
	return d
#endregion


#region drawing gizmos
func _draw() -> void:
	if hide_constraint_gizmo or !Engine.is_editor_hint():
		return
	var size = get_length()
	if constraint_data:
		draw_set_transform(Vector2.ZERO,-rotation)
		if limit_position:
			var offset = constraint_data.area_offset
			var rotation_offset = constraint_data.area_rotation
			draw_line(offset - position,
					offset - position +\
					(constraint_data.proportions * Vector2.RIGHT).rotated(rotation_offset),
					Color.BLACK, size/20)
			draw_line(offset - position,
					offset - position +\
					(constraint_data.proportions * Vector2.RIGHT).rotated(rotation_offset),
					Color.FIREBRICK, size/40)
					
			draw_line(offset - position,
					offset - position +\
					(constraint_data.proportions * Vector2.DOWN).rotated(rotation_offset),
					Color.BLACK, size/20)
			draw_line(offset - position,
					offset - position +\
					(constraint_data.proportions * Vector2.DOWN).rotated(rotation_offset),
					Color.LIME, size/40)
			draw_ellipse(offset - position,
					constraint_data.proportions, 
					rotation_offset, 
					Color.BLACK, size/20, 16)
			draw_ellipse(offset - position,
					constraint_data.proportions, 
					rotation_offset, 
					Color.DARK_ORANGE, size/40, 16)
			
		if limit_rotation:
			var a1: float = constraint_data.rotation_direction \
					- constraint_data.rotation_half_arc
			var a2: float = constraint_data.rotation_direction \
					+ constraint_data.rotation_half_arc
			
			draw_arc(Vector2.ZERO,size/4,a1,a2,
					7, Color.BLACK, size/20)
			draw_arc(Vector2.ZERO,size/4,a1,a2,
					7, Color.AQUA, size/40)
			
			draw_angle_indicator(a1, size/2, -1)
			draw_angle_indicator(a2, size/2, 1)
		

func draw_angle_indicator(angle: float, full_scale: float, y_scale: float):
	var poly: PackedVector2Array
	var out_poly: PackedVector2Array
	for i in angle_gizmo_poly:
		var this_vec = (Vector2(full_scale, full_scale * y_scale) * i).rotated(angle)
		poly.append(this_vec)
		out_poly.append(this_vec * Vector2(1.2, 1.2))
	
	draw_colored_polygon(out_poly, Color.BLACK)
	draw_colored_polygon(poly, Color.ORANGE)


func draw_ellipse(offset: Vector2, proportions: Vector2, angle: float, color: Color, width: float, segment_count: int) -> void:
	var poly: PackedVector2Array
	for i: int in segment_count+1:
		var this_vec: Vector2 = Vector2.from_angle(2*PI * i / segment_count)
		this_vec = (this_vec * proportions).rotated(angle)
		poly.append(this_vec + offset)
	draw_polyline(poly, color, width)
#endregion
