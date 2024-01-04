@tool
@icon("customTransformEasingIcon.png")
extends Resource
class_name TransformEasing

#region Angular Easing Parameters
@export_group("Angular Easing Parameters")
## Easing Frequency
##
## Defines the speed at which the system will respond
@export var Frequency: float = 1:
	set(new_value):
		Frequency=max(new_value,0.001)
		set_xy_constants(Frequency,Damping,Reaction)
	get:
		return Frequency
## Easing Damping
##
## Defines how the system settles at the target value;
## Values below 1 allow for oscillation
@export var Damping: float = 1:
	set(new_value):
		Damping=new_value
		set_xy_constants(Frequency,Damping,Reaction)
	get:
		return Damping
## Easing Reaction
##
## Defines how quickly the system reacts to a change in target value;
## Values below 0 cause anticipation in motion;
## Values above 1 overshoot the motion
@export var Reaction: float = 1:
	set(new_value):
		Reaction=new_value
		set_xy_constants(Frequency,Damping,Reaction)
	get:
		return Reaction
#endregion

#region Translation Easing Parameters
@export_group("Translation Easing Parameters")
## Easing Frequency
##
## Defines the speed at which the system will respond
@export var TFrequency: float = 1:
	set(new_value):
		TFrequency=max(new_value,0.001)
		set_origin_constants(TFrequency,TDamping,TReaction)
	get:
		return TFrequency
## Easing Damping
##
## Defines how the system settles at the target value;
## Values below 1 allow for oscillation
@export var TDamping: float = 1:
	set(new_value):
		TDamping=new_value
		set_origin_constants(TFrequency,TDamping,TReaction)
	get:
		return TDamping
## Easing Reaction
##
## Defines how quickly the system reacts to a change in target value;
## Values below 0 cause anticipation in motion
## Values above 1 overshoot the motion
@export var TReaction: float = 1:
	set(new_value):
		TReaction=new_value
		set_origin_constants(TFrequency,TDamping,TReaction)
	get:
		return TReaction
#endregion

var State: Transform2D = Transform2D.IDENTITY
var xDynamic: SecondOrderEasing

var oDynamic: SecondOrderEasing
func _init() -> void:
	xDynamic = SecondOrderEasing.new()
	oDynamic = SecondOrderEasing.new()
	set_xy_constants(1,1,1)
	set_origin_constants(1,1,1)
func set_xy_constants(f: float, z: float, r: float) -> void:
	xDynamic.compute_constants(f,z,r)
func set_origin_constants(f: float, z: float, r: float) -> void:
	oDynamic.compute_constants(f,z,r)
func update_xy(delta: float, i: Transform2D) -> void:
	xDynamic.update(delta,i.x)
	State = Transform2D(xDynamic.s, State.y, State.origin)
func update_origin(delta: float, i: Transform2D) -> void:
	oDynamic.update(delta,i.x)
	State = Transform2D(State.x, State.y, oDynamic.s)
