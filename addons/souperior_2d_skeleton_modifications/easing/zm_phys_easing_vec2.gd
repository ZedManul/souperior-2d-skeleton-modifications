@tool
@icon("icon_easing_vec2.png")
class_name ZMPhysEasingVec2
extends Resource
## A custom easing resource; uses physics approximation to produce smooth change.

signal parameter_resource_changed(parameter_resource: ZMPhysEasingParams)

@export var easing_params: ZMPhysEasingParams:
	set(value):
		easing_params = value
		parameter_resource_changed.emit(easing_params)

var state: Vector2 
var state_change: Vector2
var last_state: Vector2
var last_state_change: Vector2 
var input: Vector2 
var input_change: Vector2 = Vector2.ZERO 
var k2_stable: float = INF

func update(delta: float, i: Vector2) -> Vector2:
	if !easing_params: return i
	_calculate_stable_k2(delta)
	_apply_state_change(delta, i)
	_calculate_state_change(delta)
	return state


func force_set(i: Vector2) -> void:
	state = i
	state_change = Vector2.ZERO
	last_state = i
	last_state_change = Vector2.ZERO
	input = i
	input_change = Vector2.ZERO
	

func _calculate_stable_k2(delta: float) -> void:
	k2_stable = maxf(
					easing_params.k2, 
					maxf(
							delta * delta / 2.0 + delta * easing_params.k1 / 2.0,
							delta * easing_params.k1
						)
					)

func _apply_state_change(delta: float, i: Vector2) -> void:
	input = i
	input_change = (input - last_state) / delta 
	last_state = input
	state = state + (state_change + last_state_change) / 2 * delta # Integrate position by velocity

func _calculate_state_change(delta: float) -> void:
	last_state_change = state_change
	state_change = state_change + delta * ( \
			easing_params.gravity + \
			input + easing_params.k3 * input_change - \
			state - easing_params.k1 * state_change \
		) / k2_stable
