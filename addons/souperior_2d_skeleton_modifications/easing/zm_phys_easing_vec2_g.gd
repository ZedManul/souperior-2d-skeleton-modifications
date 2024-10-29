@tool
@icon("icon_easing_vec2.png")
class_name ZMPhysEasingVec2G extends ZMPhysEasingVec2
## A custom easing resource;
## Uses physics approximation to produce smooth change; 
## Applies gravity to the eased parameter.

## Gravity applied to the eased parameter.
@export var gravity: Vector2 = Vector2.ZERO

func update(delta: float, i: Vector2) -> void:
	var id: Vector2 = (i-last_state) / delta # Input velocity estimation
	last_state = i
	var k2_stable: float = maxf(k2, maxf(delta*delta/2.0 + delta*k1/2.0, delta*k1))
	state = state + state_change * delta # Integrate position by velocity
	state_change = state_change + delta * (gravity\
				+ i + k3 * id - state - k1 * state_change) / k2_stable
