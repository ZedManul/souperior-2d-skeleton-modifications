@tool
@icon("res://addons/soupik/icons/icon_modification.png")
class_name ZMConstraintData extends Resource
@export_group("Rotation")
@export_range(-180,180, 0.5) var rotation_direction_degrees: float = 0:
	set(value):
		rotation_direction_degrees = wrapf(value, -180, 180)
		rotation_direction = deg_to_rad(rotation_direction_degrees)
var rotation_direction: float = 0

@export_range(0,180, 0.5) var rotation_half_arc_degrees: float = 45:
	set(value):
		rotation_half_arc_degrees = clampf(value, 0, 180)
		rotation_half_arc = deg_to_rad(rotation_half_arc_degrees)
var rotation_half_arc: float = PI/4

@export_group("Position")
@export var area_offset: Vector2 = Vector2.ZERO
@export_range(-180,180, 0.5) var area_rotation_degrees: float = 0:
	set(value):
		area_rotation_degrees = wrapf(value, -180, 180)
		area_rotation = deg_to_rad(area_rotation_degrees)
var area_rotation: float = 0

@export var proportions: Vector2 = Vector2(1, 1):
	set(value):
		proportions = value.abs()
