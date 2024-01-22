@tool
@icon("Icons/icon_state_angle_fixer.png")
class_name SoupStateAngleFixInator
extends SoupStateInator
## Automatically switches between child property state groups depending on a bone's rotation;
## All direct children MUST be Soup State Component Groups

## If true, the node will automatically apply states
@export var enabled: bool = true

## The rotation of this bone will be used to determine when to switch states.
@export var bone_node: Bone2D:
	set(new_value):
		bone_node = new_value
		_calculate_true_rotation()
		_previous_true_rotation = true_rotation

## This node will be used as the frame of reference for rotation;
## if not specified, global rotation will be used instead.
@export var reference_node: Node2D = get_parent()

## Rotation angle offset; in radians.
var angle_offset: float = 0
## Rotation angle offset; in degrees.
@export_range(-180,180,0.001,"or_greater", "or_less") \
		var angle_offset_degrees: float = 0:
	set(new_value):
		angle_offset_degrees = wrapf(new_value,-180,180)
		angle_offset = deg_to_rad(angle_offset_degrees)


@export_group("Rotation Plane")
## Amount of sections and corresponding states;
## Make sure there are at least this many "Soup State Component Group" nodes as children of this node.
@export_range(0,60,1) var section_count: int = 8:
	set(new_value):
		section_count = clampi(new_value,1,60)
		_calculate_border_vectors()

## Offsets the rotation of the borders; in radians.
var rotation_plane_angle: float = 0:
	set(new_value):
		rotation_plane_angle = new_value
		_calculate_border_vectors()

## Offsets the rotation of the borders; in degrees.
@export_range(-180,180,0.001,"or_greater", "or_less") \
		var rotation_plane_angle_degrees: float = 0:
	set(new_value):
		rotation_plane_angle_degrees = wrapf(new_value,-180,180)
		rotation_plane_angle = deg_to_rad(rotation_plane_angle_degrees)

## Squishes the borders along one axis; 
## Effectively it tilts the plane which the borders lie in;
## in radians.
var rotation_plane_tilt: float = 0:
	set(new_value):
		rotation_plane_tilt = new_value
		_calculate_border_vectors()

## Squishes the borders along one axis; 
## Effectively it tilts the plane which the borders lie in;
## in degrees.
@export_range(0,89.95,0.05,"or_greater", "or_less") \
		var rotation_plane_tilt_degrees: float = 0:
	set(new_value):
		rotation_plane_tilt_degrees = clampf(new_value,0,89.95)
		rotation_plane_tilt = deg_to_rad(rotation_plane_tilt_degrees)

@export_group("Gizmo")
## If true, the border gizmo will be drawn
@export var draw_gizmo: bool = true:
	set(new_value):
		draw_gizmo = new_value
		_draw_visualizer()
## Border gizmo size
@export_range(0.05,1000,0.5) var gizmo_size: float = 10:
	set(new_value):
		gizmo_size = maxf(0.05, new_value)

## [not intended for access]
## Array of vectors representing borders between states.
var _border_vectors: PackedVector2Array = []
## [not intended for access]
## Array of angles representing borders between states.
var _border_angles: PackedFloat32Array = []

## [not intended for access]
## Previous value of true rotation.
var _previous_true_rotation:float
## Effective angle that the sections are measured against. 
var true_rotation: float = 0

## [not intended for access]
## Node that draws the gizmo
var _visualizer: SoupyStateAngleFixInatorGizmo = \
		_add_visualizer()


func _enter_tree() -> void:
	_draw_visualizer()


func _ready() -> void:
	_calculate_border_vectors()
	child_order_changed.connect(_on_children_changed)


func _process(delta: float) -> void:
	_calculate_true_rotation()
	
	if ((_previous_true_rotation == true_rotation) 
			or enabled):
		return
	
	update_state()


## Checks the "true rotation" against border angles and applies the corresponding state group.
func update_state() -> void: 
	if !bone_node:
		return
	var checked_angle: float = wrapf(true_rotation,-PI,PI)
	var chosen_state: int
	for i: int in section_count:
		var bottom_angle:float = _border_angles[i]
		var top_angle:float = _border_angles[(i+1)%section_count]
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
	
	_draw_visualizer()
	
	if chosen_state >= get_child_count():
		return
	
	var state_node: Node = get_child(chosen_state)
	if state_node is SoupStateComponentGroup:
		get_child(chosen_state).apply()


#region Borders
## [not intended for access]
## Calculates border vectors.
func _calculate_border_vectors() -> void:
	_border_vectors.clear()
	for i: int in section_count:
		_border_vectors.append(
				(
					Vector2.from_angle(
						TAU/float(section_count) * (i - 0.5)
					) \
					* Vector2(cos(rotation_plane_tilt),1)
				).rotated(rotation_plane_angle)
			)
	
	_calculate_border_angles()
	_rename_state_nodes()
	update_state()
	
	_draw_visualizer()
	


## [not intended for access]
## Calculates border angles from border vectors.
func _calculate_border_angles() -> void:
	_border_angles.clear()
	for i: Vector2 in _border_vectors:
		_border_angles.append(i.angle())


## [not intended for access]
## Renames state group nodes to match the angles
func _rename_state_nodes() -> void:
	for i: int in get_child_count():
		if i >= section_count:
			get_child(i).set_name("UnusedState" + str(i))
			continue
		
		get_child(i).set_name(
				"AngleState" \
				+ str(roundf(rad_to_deg(_border_angles[i]) * 100) / 100) \
				+ "_to_" \
				+ str(roundf(rad_to_deg(_border_angles[(i+1)%section_count]) * 100) / 100)
			)
#endregion


#region Gizmo functions
## [not intended for access]
## Creates the gizmo node.
func _add_visualizer() -> SoupyStateAngleFixInatorGizmo:
	for i in get_children(true):
		if i is SoupyStateAngleFixInatorGizmo:
			i.queue_free()
	var new_vis_node: SoupyStateAngleFixInatorGizmo = \
			SoupyStateAngleFixInatorGizmo.new()
	add_child(new_vis_node, true, INTERNAL_MODE_BACK)
	return new_vis_node


## [not intended for access]
## Redraws the gizmo.
func _draw_visualizer():
	if _visualizer is SoupyStateAngleFixInatorGizmo:
		_visualizer.queue_redraw()
#endregion


## [not intended for access]
## Updates the true_rotation variable.
func _calculate_true_rotation() -> void:
	_previous_true_rotation = true_rotation
	if !bone_node:
		return
	
	true_rotation = bone_node.global_rotation + bone_node.get_bone_angle() + angle_offset
	
	if !reference_node:
		return
	true_rotation -= reference_node.global_rotation 


func _on_children_changed() -> void:
	_calculate_border_vectors()
