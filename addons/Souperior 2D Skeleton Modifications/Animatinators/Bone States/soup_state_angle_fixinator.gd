@tool
@icon("Icons/icon_state_angle_fixer.png")
class_name SoupStateAngleFixInator
extends SoupStateInator

@export var enabled: bool = true

@export var target_node: Node2D:
	set(new_value):
		target_node = new_value
		_previous_global_rotation = target_node.global_rotation
		_previous_rotation = target_node.rotation

@export_range(0,60,1) var section_count: int = 8:
	set(new_value):
		section_count = clampi(new_value,1,60)
		_calculate_border_vectors()
	
var angle_offset: float = 0:
	set(new_value):
		angle_offset = new_value
		_calculate_border_vectors()


@export_range(-180,180,0.001,"or_greater", "or_less") \
		var angle_offset_degrees: float = 0:
	set(new_value):
		angle_offset_degrees = wrapf(new_value,-180,180)
		angle_offset = deg_to_rad(angle_offset_degrees)

var rotation_plane_angle: float = 0:
	set(new_value):
		rotation_plane_angle = new_value
		_calculate_border_vectors()

@export_range(0,89.95,0.05,"or_greater", "or_less") \
		var rotation_plane_angle_degrees: float = 0:
	set(new_value):
		rotation_plane_angle_degrees = clampf(new_value,0,89.95)
		rotation_plane_angle = deg_to_rad(rotation_plane_angle_degrees)

@export_group("Gizmo")

@export var draw_gizmo: bool = true

@export_range(0.05,100,0.05) var gizmo_size: float = 10:
	set(new_value):
		gizmo_size = maxf(0.05, new_value)

var border_vectors: PackedVector2Array = []
var border_angles: PackedFloat32Array = []

var _previous_global_rotation:float 
var _previous_rotation:float


func _ready() -> void:
	child_order_changed.connect(_on_children_changed)


func _process(delta: float) -> void:
	if !(target_node and enabled):
		return
	#if (_previous_rotation == target_node.rotation):
		#return
	
	update_state()
	#_previous_rotation = target_node.rotation


func _calculate_border_vectors() -> void:
	border_vectors.clear()
	for i: int in section_count:
		border_vectors.append(
				(
					Vector2.from_angle(
						TAU/float(section_count) * (i - 0.5)
					) \
					* Vector2(cos(rotation_plane_angle),1)
				).rotated(angle_offset)
			)
	
	_calculate_border_angles()
	_rename_state_nodes()


func _calculate_border_angles() -> void:
	border_angles.clear()
	for i: Vector2 in border_vectors:
		border_angles.append(i.angle())


func _rename_state_nodes() -> void:
	for i: int in get_child_count():
		if i >= section_count:
			get_child(i).set_name("UnusedState" + str(i))
			continue
		
		get_child(i).set_name(
				"AngleState" \
				+ str(roundf(rad_to_deg(border_angles[i]) * 100) / 100) \
				+ "_to_" \
				+ str(roundf(rad_to_deg(border_angles[(i+1)%section_count]) * 100) / 100)
			)

func update_state() -> void:
	var checked_angle: float = wrapf(target_node.rotation,-PI,PI)
	var chosen_state: int
	for i: int in section_count:
		var bottom_angle:float = border_angles[i]
		var top_angle:float = border_angles[(i+1)%section_count]
		if top_angle < bottom_angle:
			if checked_angle > 0:
				top_angle += TAU 
			else:
				bottom_angle -= TAU 
		if (
				checked_angle < top_angle
				and checked_angle > bottom_angle
			):
				chosen_state = i
				break
	var state_node: Node = get_child(chosen_state)
	if state_node is SoupState:
		get_child(chosen_state).apply()

func _on_children_changed() -> void:
	_rename_state_nodes()


