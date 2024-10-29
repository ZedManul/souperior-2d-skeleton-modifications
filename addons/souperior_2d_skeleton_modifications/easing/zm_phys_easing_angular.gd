@tool
@icon("icon_easing_vec2.png")
class_name ZMPhysEasingAngular
extends Resource
## A custom easing resource; uses physics approximation to produce smooth change.

#region Export Variables
var range_lower: float = -PI
var range_upper: float =  PI


## Easing frequency:  
## 
## Defines the speed at which the system will respond;
## Values above 20 may cause instability in low-fps environments 
## and otherwise does not appear any different from an uneased parameter. 
@export_range(0.001, 30, 0.1, "or_greater", "or_less") var frequency: float = 1:
	set(new_value):
		frequency=clampf(new_value,0.001,30)
		_compute_constants(frequency,damping,reaction)

## Easing damping:  
##
## Defines how the system settles at the target value;
## Values below 1 allow for vibration
@export var damping: float = 1:
	set(new_value):
		damping=maxf(new_value,0.0)
		_compute_constants(frequency,damping,reaction)

## Easing reaction:  
##
## Defines how quickly the system reacts to a change in target value;
## Values below 0 cause anticipation in motion;
## Values above 1 overshoot the motion
@export var reaction: float = 1:
	set(new_value):
		reaction=new_value
		_compute_constants(frequency,damping,reaction)
#endregion

var last_state: float # Previous Input
var state: float # State
var state_change: float # State Derivative


# Dynamics constants
var k1: float
var k2: float
var k3: float


func _compute_constants(f: float, z: float, r: float) -> void:
	k1 = z / (PI * f)
	k2 = 1.0 / ((TAU * f)*(TAU * f))
	k3 = r * z / (TAU * f)


func initialize_variables(i0: float) -> void:
	last_state = i0
	state = i0
	state_change = 0


func update(delta: float, i: float) -> void:
	## this code is hell 
	## but it took me 3 days straight 
	## to get it working like i wanted 
	## so please just look elsewhere........
	var wrapped_i = qwrap(i)
	#print_debug("State: " + str(state) + "; TPos: " + str(wrapped_i) + ";")
	var id: float = wrapped_diff(wrapped_i, last_state) / delta # Input velocity estimation
	last_state = wrapped_i
	var k2_stable: float = maxf(k2, maxf(delta * delta/2.0 + delta * k1/2.0, delta * k1))
	state = state + state_change * delta # Integrate position by velocity
	var accel: float = delta \
				* (wrapped_diff(wrapped_i, state) - k1 * state_change + k3 * id) / k2_stable
	
	
	#if abs(id) > 10:
		#print_debug("Input State: " + str(wrapped_i) \
					#+ ";\n Warped Diff: " + str(wrapped_diff(wrapped_i, state)) \
					#+ ";\n inp_vel: " + str(id) \
					#+ ";\n State (S): " + str(state) \
					#+ ";\n StateChange (S): " + str(state_change) \
					#+  ";\n Accel (R): " + str(accel) + ";")
	state_change = state_change + accel
	state = qwrap(state)
	

func qwrap(i: float) -> float:
	return wrapf(i,-PI, PI)

func wrapped_diff(i: float, j: float) -> float:
	var c: float = float(TAU)
	var d: float = i-j
	if abs(d+c) < abs (d) || abs(d-c) < abs(d): d = qwrap(d + c)
	return d
