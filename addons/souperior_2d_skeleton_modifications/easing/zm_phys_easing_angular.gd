@tool
@icon("icon_easing_vec2.png")
class_name ZMPhysEasingAngular
extends ZMPhysEasingWrapped
## A custom easing resource; uses physics approximation to produce smooth change. 
## To be used with a rotational value!

#func update(delta: float, i: float) -> void:
	#var k1: float = easing_params.k1
	#var k2: float = easing_params.k2
	#var k3: float = easing_params.k3
	#
	#var wrapped_i: float = qwrap(i)
	#var id: float = wrapped_diff(wrapped_i, last_state) / delta # Input velocity estimation
	#last_state = wrapped_i
	#
	#var k2_stable: float = maxf(k2, maxf(delta * delta/2.0 + delta * k1/2.0, delta * k1))
	#state = state + state_change * delta # Integrate position by velocity
	#
	#var grav_orient: float = wrapped_diff(easing_params._gravity_direction,state)
	#var grav_effect: float = grav_orient * abs(sin(grav_orient)) * easing_params._gravity_force
	#
	#var accel: float = delta \
				#* (wrapped_diff(wrapped_i, state) + grav_effect - k1 * state_change + k3 * id) / k2_stable
	#state_change = state_change + accel
	#state = qwrap(state)

func _validate_property(property: Dictionary) -> void:
	match property.name:
		"range_upper": property.usage |= PROPERTY_USAGE_READ_ONLY
		"range_lower": property.usage |= PROPERTY_USAGE_READ_ONLY

func _init() -> void:
	var range_lower: float = -PI
	var range_upper: float =  PI


func _apply_state_change(delta: float, i: float) -> void:
	input = i
	wrapped_input = range_wrap(i)
	input_change = wrapped_diff(wrapped_input, last_state) / delta 
	last_state = wrapped_input
	state = range_wrap( state + (state_change + last_state_change) / 2 * delta )

func _calculate_state_change(delta: float) -> void:
	last_state_change = state_change
	var grav_orient: float = wrapped_diff(easing_params.gravity_direction,state)
	var grav_effect: float = grav_orient * abs(sin(grav_orient)) * easing_params.gravity_force
	
	state_change = state_change + delta * ( \
			grav_effect + \
			wrapped_diff(wrapped_input, state) - \
			easing_params.k1 * state_change + \
			easing_params.k3 * input_change
		) / k2_stable
	
	state = range_wrap(state)


#func range_wrap(i: float) -> float:
	#return wrapf(i,-PI, PI)
#
#func wrapped_diff(i: float, j: float) -> float:
	#var c: float = float(TAU)
	#var d: float = i-j
	#if abs(d+c) < abs (d) || abs(d-c) < abs(d): d = range_wrap(d + c)
	#return d
