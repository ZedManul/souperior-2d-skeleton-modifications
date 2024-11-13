@tool
extends Marker2D

@export var easingX: ZMPhysEasingScalar
@export var easingY: ZMPhysEasingScalar
@export var target: Node2D


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if !target: return
	easingX.update(delta,global_position.x)
	target.global_position.x = easingX.state
	
	easingY.update(delta,global_position.y)
	target.global_position.y = easingY.state
