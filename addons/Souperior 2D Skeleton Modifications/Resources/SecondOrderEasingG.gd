@tool
@icon("customEasingIcon.png")
extends SoupySecondOrderEasing
class_name SoupySecondOrderEasingG

@export var Gravity: Vector2 = Vector2.ZERO

func update(delta: float, i: Vector2) -> void:
	var id: Vector2 = (i-ip) / delta # Input velocity estimation
	ip = i
	var k2_stable: float = maxf(k2, maxf(delta*delta/4 + delta*k1/2, delta*k1))
	state = state + sd * delta # Integrate position by velocity
	sd = sd + delta * (Gravity\
	+ i + k3 * id - state - k1 * sd) / k2_stable
