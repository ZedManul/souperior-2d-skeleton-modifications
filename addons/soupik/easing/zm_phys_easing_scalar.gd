@tool
@icon("res://addons/soupik/icons/easing/icon_easing_scalar.png")
class_name ZMPhysEasingScalar
extends Resource
## A custom easing resource; uses physics approximation to produce smooth change.

signal parameter_resource_changed(parameter_resource: ZMPhysEasingParams)

@export var easing_params: ZMPhysEasingParams:
	set(value):
		easing_params = value
		parameter_resource_changed.emit(easing_params)

var state: float 
var state_change: float
var last_state: float
var last_state_change: float 
var input: float 
var input_change: float = 0.0 
var k2_stable: float = INF


func update(delta: float, i: float) -> float:
	if !easing_params: return i
	_calculate_stable_k2(delta)
	_apply_state_change(delta, i)
	_calculate_state_change(delta)
	return state


func force_set(i: float) -> void:
	state = i
	state_change = 0
	last_state = i
	last_state_change = 0
	input = i
	input_change = 0

func _calculate_stable_k2(delta: float) -> void:
	k2_stable = maxf(
					easing_params.k2, 
					maxf(
							delta * delta / 2.0 + delta * easing_params.k1 / 2.0,
							delta * easing_params.k1
						)
					)

func _apply_state_change(delta: float, i: float) -> void:
	input = i
	input_change = (input - last_state) / delta 
	last_state = input
	state = state + (state_change + last_state_change) / 2 * delta # Integrate position by velocity

func _calculate_state_change(delta: float) -> void:
	last_state_change = state_change
	state_change = state_change + delta * ( \
			easing_params.gravity.x + \
			input + easing_params.k3 * input_change - \
			state - easing_params.k1 * state_change \
		) / k2_stable
