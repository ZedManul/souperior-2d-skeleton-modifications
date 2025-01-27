@tool
@icon("res://addons/soupik/icons/easing/icon_easing_angular.png")
class_name ZMPhysEasingAngular
extends ZMPhysEasingWrapped
## A custom easing resource; uses physics approximation to produce smooth change. 
## To be used with a rotational value!

var force_orient: float = 0
var force_effect: float = 0
var extra_force: Vector2 = Vector2.ZERO

func _validate_property(property: Dictionary) -> void:
	match property.name:
		"range_upper": property.usage |= PROPERTY_USAGE_READ_ONLY
		"range_lower": property.usage |= PROPERTY_USAGE_READ_ONLY


func _init() -> void:
	range_lower = -PI
	range_upper =  PI


func _apply_state_change(delta: float, i: float) -> void:
	input = i
	wrapped_input = range_wrap(i)
	input_change = wrapped_diff(wrapped_input, last_state) / delta 
	last_state = wrapped_input
	state = range_wrap( state + (state_change + last_state_change) / 2 * delta )

func _calculate_force() -> void:
	var force_sum: Vector2 = extra_force + easing_params.gravity * PI / 180.0
	force_orient = wrapped_diff(force_sum.angle(),state)
	force_effect = force_orient * abs(sin(force_orient)) * force_sum.length()

func _calculate_state_change(delta: float) -> void:
	last_state_change = state_change
	
	_calculate_force()
	
	state_change = state_change + delta * ( \
			force_effect + \
			wrapped_diff(wrapped_input, state) - \
			easing_params.k1 * state_change + \
			easing_params.k3 * input_change
		) / k2_stable
	
	state = range_wrap(state)
