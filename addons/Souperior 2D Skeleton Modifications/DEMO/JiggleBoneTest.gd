@tool

extends Node

@export var target: Node2D:
	set(new_value):
		target = new_value
		VirtualPoint = target.global_position
@export var Bone: Bone2D:
	set(new_value):
		Bone = new_value
@export var Easing: SoupySecondOrderEasing: 
	set(new_value):
		if new_value is SoupySecondOrderEasing: 
			Easing = new_value.duplicate(true)
		else: 
			Easing = null

var VirtualPoint: Vector2 
func _process(delta: float) -> void:
	if !(Bone is Bone2D and target is Node2D):
		return
	if Easing is SoupySecondOrderEasing:
		Easing.update(delta,target.global_position)
		VirtualPoint = (Easing.state-Bone.global_position).normalized()\
		*Bone.global_position.distance_to(target.global_position)\
		+Bone.global_position
	var correctionAngle: float = -Bone.get_bone_angle()
	var resultAngle = correctionAngle\
	+ Bone.global_position.angle_to_point(VirtualPoint)*sign(Bone.global_scale.y)
	Bone.rotation = AngleGlobalToLocal(resultAngle,Bone.get_parent())


func AngleGlobalToLocal( angle: float, parentNode: Node2D) -> float:
	return (angle - parentNode.global_rotation*sign(parentNode.global_scale.y))
