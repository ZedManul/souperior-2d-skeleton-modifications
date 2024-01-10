@tool 

@icon("customConstraintIcon")
extends SoupStackPart
class_name SoupConstraint

## if true, the modification is calculated and applied
@export var Enabled: bool = false:
	set(new_value):
		Enabled = new_value
		update_constraints()
		draw_visualizers()
		if !Enabled:
			ConstraintData.clear(ModStack)
#region Bone 
@export var BoneIdx: int = -1:
	set(new_value):
		BoneIdx=new_value
		if !(ModStack is SoupStack):
			return
		
		ModStack.initialize_arrays()
		var Skeleton: Skeleton2D = ModStack.Skeleton
		if Skeleton is Skeleton2D:
			BoneIdx=clampi(new_value,0,Skeleton.get_bone_count()-1)
			if ConstraintData is Constraint:
				ConstraintData.clear(ModStack)
			ConstraintData = Constraint.new(BoneIdx)
			if (Bone != Skeleton.get_bone(BoneIdx)):
				Bone = Skeleton.get_bone(BoneIdx)
				return
		else:
			Bone = null

@export var Bone: Bone2D:
	set(new_value):
		Bone=new_value
		if !(ModStack is SoupStack):
			return
		PositionLimitOffset = Bone.position
		if (ModStack.Skeleton is Skeleton2D):
			if Bone:
				if BoneIdx != Bone.get_index_in_skeleton():
					BoneIdx = Bone.get_index_in_skeleton()
					PrevBoneTransform = Bone.transform
#endregion 

@onready var PositionVisualizer: SoupyPositionConstraintGizmo = initiate_position_visualizer()
@onready var AngleVisualizer: SoupyAngleConstraintGizmo = initiate_angle_visualizer()
#region Angle Constraint
@export_group("Angle Constraint")
@export var LimitAngle: bool = true:
	set(new_value):
		LimitAngle = new_value
		update_constraints()
		on_bone_updated()
var AngleLimitCenter: float = 0 # in radians; used in code
@export_range(-180.0, 180.0, 0.001, "or_greater", "or_less") \
var AngleConstraintCenter: float = 0: # used for export
	set(new_value):
		AngleConstraintCenter = clampf(new_value,-180,180)
		AngleLimitCenter = PI*AngleConstraintCenter/180
		update_constraints()
		on_bone_updated()

var AngleLimitRange: float = PI/4 # in radians; used in code
@export_range(0.0, 180.0, 0.001, "or_greater", "or_less") \
var AngleConstraintRange: float = 45: # used for export
	set(new_value):
		AngleConstraintRange=clampf(new_value,-180,180)
		AngleLimitRange = PI*AngleConstraintRange/180
		update_constraints()
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
		update_constraints()
		on_bone_updated()
@export var PositionLimitOffset: Vector2 = Vector2.ZERO:
	set(new_value):
		PositionLimitOffset = new_value
		update_constraints()
		on_bone_updated()
@export var PositionLimitRange: Vector2 = Vector2.ONE:
	set(new_value):
		PositionLimitRange = new_value.clamp(Vector2.ZERO,abs(new_value)+Vector2.ONE)
		update_constraints()
		on_bone_updated()

@export var DrawPositionLimitGizmo: bool = true:
	set(new_value):
		DrawPositionLimitGizmo = new_value
		draw_visualizers()
#endregion

@onready var ConstraintData:Constraint = Constraint.new()

var PrevBoneTransform: Transform2D
func _process(delta: float) -> void:
	if Bone is Bone2D and Enabled:
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

func on_bone_updated():
	draw_visualizers()
	if ModStack is SoupStack:
		if 0 <= BoneIdx and BoneIdx < ModStack.Skeleton.get_bone_count():
			ModStack.execute_bone_modifications(BoneIdx)

# Updates Constraints in the stack list
func update_constraints(): 
	if ConstraintData is Constraint and ModStack.Skeleton is Skeleton2D:
		ConstraintData.targetBoneIdx \
		= clamp(BoneIdx, 0, ModStack.Skeleton.get_bone_count()-1)
		if LimitAngle:
			if !(ConstraintData.aConstrStruct \
			in ModStack.BoneData[ConstraintData.targetBoneIdx].aConstraints):
				ConstraintData.init_angle_constraint(ModStack)
			ConstraintData.aConstrStruct.angleLimitCenter = AngleLimitCenter
			ConstraintData.aConstrStruct.angleLimitRange = AngleLimitRange
		else:
			ConstraintData.remove_angle_constraint(ModStack)
		if LimitPosition:
			if !(ConstraintData.pConstrStruct \
			in ModStack.BoneData[ConstraintData.targetBoneIdx].pConstraints):
				ConstraintData.init_position_constraint(ModStack)
			ConstraintData.pConstrStruct.offset = PositionLimitOffset
			ConstraintData.pConstrStruct.range = PositionLimitRange
		else:
			ConstraintData.remove_position_constraint(ModStack)


func stack_hook_initialization():
	update_constraints()
	draw_visualizers()

class Constraint:
	var targetBoneIdx: int
	var aConstrStruct: SoupStack.AngleConstraint
	var pConstrStruct: SoupStack.PositionConstraint
	
	func _init(bIdx: int = -1) -> void:
		targetBoneIdx = bIdx
	
	func remove_position_constraint(modStack: SoupStack):
		modStack.BoneData[targetBoneIdx].pConstraints.erase(pConstrStruct)
	func remove_angle_constraint(modStack: SoupStack):
		modStack.BoneData[targetBoneIdx].aConstraints.erase(aConstrStruct)
	
	func init_position_constraint(modStack: SoupStack):
		remove_position_constraint(modStack)
		if modStack is SoupStack and modStack.BoneData.size()>0:
			modStack.BoneData[targetBoneIdx].pConstraints.append(SoupStack.PositionConstraint.new())
			pConstrStruct = modStack.BoneData[targetBoneIdx].pConstraints.back()
	
	func init_angle_constraint(modStack: SoupStack):
		remove_angle_constraint(modStack)
		if modStack is SoupStack and modStack.BoneData.size()>0:
			modStack.BoneData[targetBoneIdx].aConstraints.append(SoupStack.AngleConstraint.new())
			aConstrStruct = modStack.BoneData[targetBoneIdx].aConstraints.back()

	
	func clear(modStack: SoupStack)-> void:
		remove_position_constraint(modStack)
		remove_angle_constraint(modStack)

func _exit_tree() -> void:
	ConstraintData.clear(ModStack)

func _enter_tree() -> void:
	update_constraints()
	draw_visualizers()
