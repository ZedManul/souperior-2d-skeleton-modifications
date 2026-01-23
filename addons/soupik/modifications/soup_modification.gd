@tool
@icon("res://addons/soupik/icons/icon_modification.png")
class_name SoupMod
extends Node2D
## Base node for "Souperior" modifications;
## Does nothing by itself, but can be used for organisation to toggle groups of modifications at once.

## If false, this modification and its children in the tree will not be applied.
@export var enabled: bool = true

## How much the modification affects the skeleton. Useful for transitions in animation or mixing multiple modifications.
## If you want to mix multiple modifications, the modification which is processed first must be enabled and have full strength,
## with the modifications after it having reduced strength for mixing amount.
## Otherwise it lacks concrete values to mix from and will drift as it mixes with its own previous position.
@export_range(0, 1, 0.01, "or_greater", "or_less") var strength: float = 1.0:
	set(value):
		strength = clampf(value,0.0,1.0)

enum ProcessMode {
	PROCESS,
	PHYSICS_PROCESS
}

@export_enum("Process", "Physics Process") var ik_process_mode: int = ProcessMode.PROCESS:
	set(value):
		ik_process_mode = value
		set_process(ik_process_mode == ProcessMode.PROCESS)
		set_physics_process(ik_process_mode == ProcessMode.PHYSICS_PROCESS)

@export_group("Gizmo")
@export_custom(PROPERTY_HINT_GROUP_ENABLE, "") var draw_gizmo: bool = false
@export_range(0.0, 1000.0, 0.1, "or_greater", "suffix:px") var gizmo_size: float = 10.0
@export_range(0.0, 2.0, 0.01, "or_greater") var strength_gizmo_scale: float = 0.5


var scale_orient: int = 1

func _process(delta) -> void:
	if Engine.is_editor_hint() : queue_redraw()
	_process_loop(delta)


func _physics_process(delta) -> void:
	_process_loop(delta)


func _process_loop(_delta):
	pass


## Checks if parent modifications are enabled.
func enable_check() -> bool:
	var mod_group = get_parent()
	if (mod_group is SoupMod):
		return enabled and mod_group.enable_check()
	return enabled

## Returns strength, accounting for parent modifications.
func get_inherited_strength() -> float:
	var mod_group = get_parent()
	if (mod_group is SoupMod):
		return strength * mod_group.get_inherited_strength()
	return strength


func _draw() -> void:
	if !draw_gizmo: return
	_draw_gizmo()

func _draw_gizmo() -> void:
	draw_strength(strength_gizmo_scale)

func draw_strength(scale: float) -> void:
	if scale == 0.0: return
	var _str:= get_inherited_strength()
	draw_arc(Vector2.ZERO,gizmo_size * scale,0.0,_str*TAU,7,Color.BLACK,gizmo_size * scale/5.0)
	var colr = Color.DARK_RED
	if enable_check(): colr = Color.GREEN_YELLOW
	draw_arc(Vector2.ZERO,gizmo_size * scale,0.0,_str*TAU,7,colr,gizmo_size * scale/10.0)

func draw_target() -> void:
	var target_gizmo_poly_quarter: PackedVector2Array = [Vector2(1.0,0.0),Vector2(0.2,0.1),Vector2(0.0,0.0),Vector2(0.2,-0.1)]
	
	for q: float in range(4.0):
		var poly: PackedVector2Array
		var out_poly: PackedVector2Array
		for i:Vector2 in target_gizmo_poly_quarter:
			var this_vec = (i * gizmo_size).rotated(q*PI/2.0)*(1-q/8)
			poly.append(this_vec * Vector2(0.8, 0.8)+Vector2(gizmo_size/20.0,0).rotated(q*PI/2.0))
			out_poly.append(this_vec)
		draw_colored_polygon(out_poly, Color.BLACK)
		draw_colored_polygon(poly, Color.AQUA)
