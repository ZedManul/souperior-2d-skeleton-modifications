@tool
@icon("icons/icon_jiggle.png")
class_name SoupJiggle 
extends SoupMod

## The to-be-modified bone nodes.
@export var chain_root: Bone2D:
	set(value):
		chain_root = value
		_get_bone_nodes()

@export var chain_tip: Bone2D:
	set(value):
		chain_tip = value
		_get_bone_nodes()

@export var angle_offsets: Array[float]

## If true, the modification is calculated and applied.
@export var enabled: bool = false

@export var intensity: float = 10

## Easing resource. Jiggle bones will not function without one.
@export var easing: ZMPhysEasingAngular:
	set(value):
		if not value is ZMPhysEasingAngular:
			easing = null
			_fill_easing_stack(null)
			return
		
		easing = value.duplicate()
		easing.parameter_resource_changed.connect(_on_parameter_resource_changed)
		_fill_easing_stack(easing)


var _bone_nodes: Array[Bone2D]

var _easing_stack: Array[ZMPhysEasingAngular]
var _last_pos: Vector2 = Vector2.ZERO
var _last_vel: Vector2 = Vector2.ZERO


func _ready() -> void:
		_fill_easing_stack(easing)

func process_loop(delta:float):
	if !(
			enabled 
			and chain_root 
			and easing
			and _parent_enable_check()
		):
		return
	_scale_orient = sign(_bone_nodes[0].global_transform.determinant())
	_handle_jiggle_chain(delta)



func _handle_jiggle_chain(delta: float) -> void:
	var current_vel = (chain_root.global_position - _last_pos) * delta
	
	var accel = (current_vel - _last_vel) 
	_easing_stack[0].extra_force = accel * intensity 
	
	_last_pos = chain_root.global_position
	_last_vel = current_vel
	
	for i: int in _bone_nodes.size():
		
		if _easing_stack[i]:
			var parent_angle = 0
			var bone_parent = _bone_nodes[i].get_parent()
			
			if bone_parent is Node2D: parent_angle += bone_parent.global_rotation
			if bone_parent is Bone2D: parent_angle += bone_parent.get_bone_angle() * _scale_orient
			
			var target_rotation = parent_angle
			if angle_offsets.size() > i: target_rotation += deg_to_rad(angle_offsets[i]) * _scale_orient
			
			_easing_stack[i].update(delta, target_rotation)
			target_rotation = _easing_stack[i].state
			
			_bone_nodes[i].global_rotation = target_rotation  - _bone_nodes[i].get_bone_angle() * _scale_orient 


func _on_parameter_resource_changed(params: ZMPhysEasingParams) -> void: 
	for i: ZMPhysEasingAngular in _easing_stack:
		i.easing_params = params


func _fill_easing_stack(value: ZMPhysEasingAngular) -> void:
	_easing_stack.resize(_bone_nodes.size())
	for i: int in range(_bone_nodes.size()):
		if value == null:
			_easing_stack[i] = null
			continue
		_easing_stack[i] = value.duplicate()
		_easing_stack[i].force_set(_bone_nodes[i].global_rotation)


func _get_bone_nodes() -> void:
	_bone_nodes.clear()
	if chain_root:
		_last_pos = chain_root.global_position
		if !chain_tip:
			_bone_nodes.push_front(chain_root)
			return
		var i: Node = chain_tip
		while i is Bone2D:
			_bone_nodes.push_front(i)
			if i == chain_root: return
			i = i.get_parent()
	_bone_nodes.clear()
	
	
