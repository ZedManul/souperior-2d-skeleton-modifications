@tool
@icon("res://addons/soupik/icons/easing/icon_easing_wrapped.png")
class_name ZMPhysEasingWrapped
extends ZMPhysEasingScalar
## A custom easing resource; uses physics approximation to produce smooth change.

@export var range_lower: float = -PI
@export var range_upper: float =  PI

var wrapped_input: float

func _apply_state_change(delta: float, i: float) -> void:
	input = i
	wrapped_input = range_wrap(i)
	input_change = wrapped_diff(wrapped_input, last_state) / delta 
	last_state = wrapped_input
	state = range_wrap( state + (state_change + last_state_change) / 2 * delta )

func _calculate_state_change(delta: float) -> void:
	last_state_change = state_change
	
	state_change = state_change + delta * ( \
			easing_params.gravity.x + \
			wrapped_diff(wrapped_input, state) - \
			easing_params.k1 * state_change + \
			easing_params.k3 * input_change
		) / k2_stable
	
	state = range_wrap(state)


func range_wrap(i: float) -> float:
	return wrapf(i,range_lower, range_upper)

func wrapped_diff(i: float, j: float) -> float:
	var c: float = float(abs(range_upper - range_lower))
	var d: float = i-j
	if abs(d+c) < abs (d) || abs(d-c) < abs(d): d = range_wrap(d + c)
	return d
