@tool
@icon("icon_easing.png")
class_name SoupySecondOrderEasingG
extends SoupySecondOrderEasing
## A custom easing resource;
## Uses physics approximation to produce smooth change; 
## Applies gravity to the eased parameter.

## Gravity applied to the eased parameter.
@export var gravity: Vector2 = Vector2.ZERO

func update(delta: float, i: Vector2) -> void:
	var id: Vector2 = (i-ip) / delta # Input velocity estimation
	ip = i
	var k2_stable: float = maxf(k2, maxf(delta*delta/2.0 + delta*k1/2.0, delta*k1))
	state = state + sd * delta # Integrate position by velocity
	sd = sd + delta * (gravity\
	+ i + k3 * id - state - k1 * sd) / k2_stable
