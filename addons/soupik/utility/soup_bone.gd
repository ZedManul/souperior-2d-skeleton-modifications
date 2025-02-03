@tool
@icon("res://addons/soupik/icons/icon_soup_bone.png")
class_name SoupBone extends Bone2D

@export_group("Easing")
@export_subgroup("Rotation")
@export var ease_rotation: bool = false
@export_subgroup("Position")
@export var ease_position: bool = false
@export_group("Constraints")
@export_subgroup("Rotation")
@export var limit_rotation: bool = false
@export_subgroup("Position")
@export var limit_position: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
