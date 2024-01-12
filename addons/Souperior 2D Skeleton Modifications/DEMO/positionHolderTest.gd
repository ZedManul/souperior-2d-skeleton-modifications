@tool

extends Node

@export var target: Node2D
@export var Bone: Bone2D:
	set(new_value):
		Bone = new_value
@export var Easing: SoupySecondOrderEasing: 
	set(new_value):
		if new_value is SoupySecondOrderEasing: 
			Easing = new_value.duplicate(true)
		else: 
			Easing = null



#var last_global_pos: Vector2 
func _process(delta: float) -> void:
	if (Bone is Bone2D and target is Node2D):
		var resultPos: Vector2 = target.global_position
		if Easing is SoupySecondOrderEasing:
			Easing.update(delta,target.global_position)
			resultPos = Easing.state
		Bone.position = PositionGlobalToLocal(resultPos, Bone.get_parent())
	

func PositionGlobalToLocal( position: Vector2, parentNode: Node2D) -> Vector2:
	return (position - parentNode.global_position)\
	.rotated(-parentNode.global_rotation)\
	/parentNode.global_scale
	
	
