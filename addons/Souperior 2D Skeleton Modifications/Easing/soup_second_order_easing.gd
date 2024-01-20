@tool
@icon("icon_easing.png")
class_name SoupySecondOrderEasing
extends Resource
## A custom easing resource; uses physics approximation to produce smooth change.

#region Export Variables
## Easing frequency:  
## 
## Defines the speed at which the system will respond;
## Values above 20 may cause instability in low-fps environments 
## and otherwise does not appear any different from an uneased parameter. 
@export_range(0.001, 30, 0.1, "or_greater", "or_less") var frequency: float = 1:
	set(new_value):
		frequency=clampf(new_value,0.001,30)
		compute_constants(frequency,damping,reaction)
	get:
		return frequency
## Easing damping:  
##
## Defines how the system settles at the target value;
## Values below 1 allow for vibration
@export var damping: float = 1:
	set(new_value):
		damping=maxf(new_value,0.0)
		compute_constants(frequency,damping,reaction)
	get:
		return damping
## Easing reaction:  
##
## Defines how quickly the system reacts to a change in target value;
## Values below 0 cause anticipation in motion;
## Values above 1 overshoot the motion
@export var reaction: float = 1:
	set(new_value):
		reaction=new_value
		compute_constants(frequency,damping,reaction)
	get:
		return reaction
#endregion

var ip: Vector2 # Previous Input
var state: Vector2 # State
var sd: Vector2 # State Derivative
# Dynamics constants
var k1: float
var k2: float
var k3: float


func compute_constants(f: float, z: float, r: float) -> void:
	k1 = z / (PI * f)
	k2 = 1.0 / ((TAU * f)*(TAU * f))
	k3 = r * z / (TAU * f)
func initialize_variables(i0: Vector2) -> void:
	ip = i0
	state = i0
	sd = Vector2.ZERO
func update(delta: float, i: Vector2) -> void:
	var id: Vector2 = (i-ip) / delta # Input velocity estimation
	ip = i
	var k2_stable: float = maxf(k2, maxf(delta*delta/2.0 + delta*k1/2.0, delta*k1))
	state = state + sd * delta # Integrate position by velocity
	sd = sd + delta * (i + k3 * id - state - k1 * sd) / k2_stable
