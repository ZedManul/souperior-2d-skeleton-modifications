@tool
@icon("icon_easing_vec2.png")
class_name ZMPhysEasingAngular
extends ZMPhysEasingScalar
## A custom easing resource; uses physics approximation to produce smooth change. 
## To be used with a rotational value!

#region Export Variables
var range_lower: float = -PI
var range_upper: float =  PI


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
	state_change = state_change + accel
	state = qwrap(state)
	
	

func qwrap(i: float) -> float:
	return wrapf(i,-PI, PI)

func wrapped_diff(i: float, j: float) -> float:
	var c: float = float(TAU)
	var d: float = i-j
	if abs(d+c) < abs (d) || abs(d-c) < abs(d): d = qwrap(d + c)
	return d
