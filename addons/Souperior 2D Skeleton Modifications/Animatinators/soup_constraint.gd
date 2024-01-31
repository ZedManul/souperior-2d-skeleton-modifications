@tool 
@icon("Icons/icon_constraint.png")
class_name SoupConstraint
extends Node
## "Souperior" constraint for Skeleton2D;
## Limits bone rotation and/or position;
## MUST be a direct child of the Bone2D its modifying.

## Position Limit Shape Enumerator.
enum PosLimitShape {
	RECTANGLE,
	ELLIPSE,
}

## If true, the constraint is calculated and applied.
@export var enabled: bool = false:
	set(new_value):
		enabled = new_value
		_draw_visualizers()

#region Rotation Constraint
@export_group("Rotation Constraint")

## If true, the constraint will affect rotation.
@export var limit_rotation: bool = true:
	set(new_value):
		limit_rotation = new_value
		_on_bone_node_updated()

## Angle of the permitted rotation arc center, in radians.
var rotation_limit_angle: float = 0.0 # in radians; used in code

## Angle of the permitted rotation arc center, in degrees; used for export.
@export_range(-180,180,0.001,"or_greater", "or_less") \
		 var rotation_limit_angle_degrees: float = 0.0:
	set(new_value):
		rotation_limit_angle_degrees = wrapf(new_value, -180, 180)
		rotation_limit_angle = PI * rotation_limit_angle_degrees / 180
		_on_bone_node_updated()

## Half-width of the permitted angle arc, in radians.
var rotation_limit_range: float = PI / 4 # in radians; used in code

## Half-width of the permitted angle arc, in degrees; used for export.
@export_range(-180,180,0.001,"or_greater", "or_less") \
		var rotation_limit_range_degrees: float = 45: # used for export
	set(new_value):
		rotation_limit_range_degrees = clampf(new_value, 0, 180)
		rotation_limit_range = PI * rotation_limit_range_degrees / 180
		_on_bone_node_updated()

## If true, the rotation constraint gizmo will be drawn.
@export var draw_rotation_limit_gizmo: bool = true:
	set(new_value):
		draw_rotation_limit_gizmo = new_value
		_draw_visualizers()
#endregion

#region Position Constraint
@export_group("Position Constraint")

## If true, the constraint will affect position.
@export var limit_position: bool = false:
	set(new_value):
		limit_position = new_value
		_on_bone_node_updated()

## Center of the permitted position area.
@export var position_limit_offset := Vector2.ZERO:
	set(new_value):
		position_limit_offset = new_value
		_on_bone_node_updated()

## Half-size of the permitted position area.
@export var position_limit_range := Vector2.ONE:
	set(new_value):
		position_limit_range = new_value.clamp(
				Vector2.ONE * 0.001,
				abs(new_value) + Vector2.ONE
			)
		
		_on_bone_node_updated()

## Shape of the position constraint.
@export_enum("Rectangle", "Ellipse") \
var position_constraint_shape: int = PosLimitShape.RECTANGLE:
	set(new_value):
		position_constraint_shape = new_value
		_draw_visualizers()

## Rotation of the constraint shape, in degrees.
@export_range(-180.0, 180.0, 0.001, "or_greater", "or_less") \
var position_constraint_rotation_degrees: float = 0.0:
	set(new_value):
		position_constraint_rotation_degrees = clampf(new_value, -180, 180)
		position_constraint_rotation = PI * position_constraint_rotation_degrees / 180
		_on_bone_node_updated()

## Rotation of the constraint shape, in radians.
var position_constraint_rotation: float = 0

## If true, the position constraint gizmo will be drawn.
@export var draw_position_limit_gizmo: bool = true:
	set(new_value):
		draw_position_limit_gizmo = new_value
		_draw_visualizers()
#endregion

## [not intended for access]
## Set dynamically; Please dont touch this.
var _previous_bone_node_transform: Transform2D

## [not intended for access]
## The bone affected by a constraint;
## MUST be a direct parent of the constraint node.
@onready var _bone_node: Bone2D = get_parent():
	set(new_value):
		_bone_node = new_value
		position_limit_offset = _bone_node.position

## [not intended for access]
## Modstack reference.
@onready var _mod_stack: SoupStack = _find_stack()

## [not intended for access]
## Position gizmo; internal node.
@onready var _position_visualizer: SoupyPositionConstraintGizmo = \
		_add_position_visualizer()

## [not intended for access]
## Rotation gizmo; internal node.
@onready var _angle_visualizer: SoupyAngleConstraintGizmo = \
		_add_angle_visualizer()


func _enter_tree() -> void:
	_bone_node = get_parent()
	_mod_stack = _find_stack()
	_draw_visualizers()


func _process(_delta: float) -> void:
	if !(_bone_node is Bone2D and enabled):
		return
	
	var current_bone_node_transform := Transform2D(
			_bone_node.global_rotation,
			_bone_node.global_scale,
			_bone_node.global_skew,
			_bone_node.global_position
		)
	
	if _previous_bone_node_transform != current_bone_node_transform:
		_previous_bone_node_transform = current_bone_node_transform
		_on_bone_node_updated()


#region Visualiser Functions
## [not intended for access]
## Creates the rotation constraint gizmo node.
func _add_angle_visualizer() -> SoupyAngleConstraintGizmo:
	for i in get_children(true):
		if i is SoupyAngleConstraintGizmo:
			i.queue_free()
	var new_vis_node: SoupyAngleConstraintGizmo = \
			SoupyAngleConstraintGizmo.new()
	add_child(new_vis_node, true, INTERNAL_MODE_BACK)
	return new_vis_node


## [not intended for access]
## Creates the position constraint gizmo node.
func _add_position_visualizer() -> SoupyPositionConstraintGizmo:
	for i in get_children(true):
		if i is SoupyPositionConstraintGizmo:
			i.queue_free()
	var new_vis_node: SoupyPositionConstraintGizmo = \
			SoupyPositionConstraintGizmo.new()
	add_child(new_vis_node, true, INTERNAL_MODE_BACK)
	return new_vis_node


## [not intended for access]
## Redraws the gizmos.
func _draw_visualizers():
	
	if _position_visualizer:
		_position_visualizer.queue_redraw()
	if _angle_visualizer:
		_angle_visualizer.queue_redraw()
#endregion


## [not intended for access]
## Fetches the modification stack attached to this skeleton.
func _find_stack() -> SoupStack:
	var found_node = get_parent()
	for i: int in 1000:
		if found_node is Bone2D:
			found_node = found_node.get_parent()
			continue
		elif found_node is Skeleton2D:
			for j in found_node.get_children(false):
				if j is SoupStack:
					return j
			break
		else:
			break
	return null


## [not intended for access]
## Handles redrawing gizmos and applying the constraint if the bone node changed in any way.
func _on_bone_node_updated() -> void:
	_draw_visualizers()
	if !_mod_stack:
		return
	_mod_stack.apply_constraints(_bone_node)
