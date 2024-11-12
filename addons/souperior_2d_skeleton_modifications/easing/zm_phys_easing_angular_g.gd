@tool
@icon("icon_easing_vec2.png")
class_name ZMPhysEasingAngularG extends ZMPhysEasingAngular
## A custom easing resource; uses physics approximation to produce smooth change. 
## To be used with a rotational value!

@export var gravity: Vector2 = Vector2.ZERO:
	set(value):
		gravity = value
		_gravity_force = gravity.length()  * PI / 180.0
		_gravity_direction = gravity.angle()
		constants_changed.emit(k1,k2,k3)

var _gravity_force: float = 0

var _gravity_direction: float = PI/2

func update(delta: float, i: float) -> void:
	
	var wrapped_i: float = qwrap(i)
	var id: float = wrapped_diff(wrapped_i, last_state) / delta # Input velocity estimation
	last_state = wrapped_i
	
	var k2_stable: float = maxf(k2, maxf(delta * delta/2.0 + delta * k1/2.0, delta * k1))
	state = state + state_change * delta # Integrate position by velocity
	
	var grav_orient: float = wrapped_diff(_gravity_direction,state)
	var grav_effect: float = grav_orient * abs(sin(grav_orient)) * _gravity_force
	
	var accel: float = delta \
				* (wrapped_diff(wrapped_i, state) + grav_effect - k1 * state_change + k3 * id) / k2_stable
	state_change = state_change + accel
	state = qwrap(state)
	
	
