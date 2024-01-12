@tool 

@icon("Icons/customConstraintIcon")
extends Node
class_name SoupConstraint

@onready var Bone: Bone2D = get_parent():
	set(new_value):
		Bone = new_value
		PositionLimitOffset = Bone.position
@onready var ModStack: SoupStack = find_stack()
## if true, the modification is calculated and applied
@export var Enabled: bool = false:
	set(new_value):
		Enabled = new_value
		draw_visualizers()

@onready var PositionVisualizer: SoupyPositionConstraintGizmo = initiate_position_visualizer()
@onready var AngleVisualizer: SoupyAngleConstraintGizmo = initiate_angle_visualizer()
#region Angle Constraint
@export_group("Angle Constraint")
@export var LimitAngle: bool = true:
	set(new_value):
		LimitAngle = new_value
		on_bone_updated()
var AngleLimitCenter: float = 0 # in radians; used in code
@export_range(-180.0, 180.0, 0.001, "or_greater", "or_less") \
var AngleConstraintCenter: float = 0: # used for export
	set(new_value):
		AngleConstraintCenter = clampf(new_value,-180,180)
		AngleLimitCenter = PI*AngleConstraintCenter/180
		on_bone_updated()

var AngleLimitRange: float = PI/4 # in radians; used in code
@export_range(0.0, 180.0, 0.001, "or_greater", "or_less") \
var AngleConstraintRange: float = 45: # used for export
	set(new_value):
		AngleConstraintRange=clampf(new_value,-180,180)
		AngleLimitRange = PI*AngleConstraintRange/180
		on_bone_updated()
@export var DrawAngleLimitGizmo: bool = true:
	set(new_value):
		DrawAngleLimitGizmo = new_value
		draw_visualizers()
#endregion
#region Position Constraint
@export_group("Position Constraint")
@export var LimitPosition: bool = false:
	set(new_value):
		LimitPosition = new_value
		on_bone_updated()
@export var PositionLimitOffset: Vector2 = Vector2.ZERO:
	set(new_value):
		PositionLimitOffset = new_value
		on_bone_updated()
@export var PositionLimitRange: Vector2 = Vector2.ONE:
	set(new_value):
		PositionLimitRange = new_value.clamp(Vector2.ZERO,abs(new_value)+Vector2.ONE)
		on_bone_updated()

@export var DrawPositionLimitGizmo: bool = true:
	set(new_value):
		DrawPositionLimitGizmo = new_value
		draw_visualizers()
#endregion

var PrevBoneTransform: Transform2D
func _process(delta: float) -> void:
	if !(Bone is Bone2D and Enabled):
		return
	var curBoneTransform\
	 = Transform2D(Bone.global_rotation,Bone.global_scale,Bone.global_skew,Bone.global_position)
	if PrevBoneTransform!= curBoneTransform:
		PrevBoneTransform = curBoneTransform
		on_bone_updated()

#region Visualiser Functions
func add_angle_visualizer() -> void:
	for i in get_children(true):
		if i is SoupyAngleConstraintGizmo:
			i.queue_free()
	add_child(SoupyAngleConstraintGizmo.new(),true,INTERNAL_MODE_BACK)

func initiate_angle_visualizer() -> SoupyAngleConstraintGizmo:
	add_angle_visualizer()
	for i in get_children(true):
		if i is SoupyAngleConstraintGizmo:
			return i
	return null

func add_position_visualizer() -> void:
	for i in get_children(true):
		if i is SoupyPositionConstraintGizmo:
			i.queue_free()
	add_child(SoupyPositionConstraintGizmo.new(),true,INTERNAL_MODE_BACK)

func initiate_position_visualizer() -> SoupyPositionConstraintGizmo:
	add_position_visualizer()
	for i in get_children(true):
		if i is SoupyPositionConstraintGizmo:
			return i
	return null

func draw_visualizers():
	if PositionVisualizer is SoupyPositionConstraintGizmo:
		PositionVisualizer.queue_redraw()
	if AngleVisualizer is SoupyAngleConstraintGizmo:
		AngleVisualizer.queue_redraw()
#endregion

func find_stack() -> SoupStack:
	var foundNode = get_parent()
	for i: int in 1000:
		if foundNode is Bone2D:
			foundNode = foundNode.get_parent()
			continue
		elif foundNode is Skeleton2D:
			for j in foundNode.get_children(false):
				if j is SoupStack:
					return j
			break
		else:
			break
	return null

func on_bone_updated() -> void:
	draw_visualizers()
	if !(ModStack is SoupStack):
		return
	#print_debug("it gets here")
	ModStack.apply_constraints(Bone)

func stack_hook_initialization() -> void:
	draw_visualizers()

func _enter_tree() -> void:
	Bone = get_parent()
	ModStack = find_stack()
	draw_visualizers()
