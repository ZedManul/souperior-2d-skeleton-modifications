@tool
@icon("res://addons/soupik/icons/icon_easing_params.png")
class_name ZMPhysEasingParams extends Resource
## Easing frequency:  
## 
## Defines the speed at which the system will respond;
## Values above 20 may cause instability in low-fps environments 
## and otherwise does not appear any different from an uneased parameter. 
@export_range(0.001, 30, 0.1, "or_greater", "or_less") var frequency: float = 1:
	set(value):
		frequency=clampf(value,0.001,30)
		compute_constants(frequency,damping,reaction)

## Easing damping:  
##
## Defines how the system settles at the target value;
## Values below 1 allow for vibration
@export var damping: float = 1:
	set(value):
		damping=maxf(value,0.0)
		compute_constants(frequency,damping,reaction)

## Easing reaction:  
##
## Defines how quickly the system reacts to a change in target value;
## Values below 0 cause anticipation in motion;
## Values above 1 overshoot the motion
@export var reaction: float = 1:
	set(value):
		reaction=value
		compute_constants(frequency,damping,reaction)
#endregion

@export var gravity: Vector2 = Vector2.ZERO


var k1: float
var k2: float
var k3: float

func _init() -> void:
	compute_constants(1.0, 1.0, 1.0)

func compute_constants(f: float, z: float, r: float) -> void:
	k1 = z / (PI * f)
	k2 = 1.0 / ((TAU * f)*(TAU * f))
	k3 = r * z / (TAU * f)

func calculate_stable_k2(delta: float) -> float:
	return maxf(
					k2, 
					maxf(
							delta * delta / 2.0 + delta * k1 / 2.0,
							delta * k1
						)
					)
