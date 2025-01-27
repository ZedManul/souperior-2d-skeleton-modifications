@tool
@icon("res://addons/soupik/icons/icon_fabrik.png")
class_name SoupFABRIK
extends SoupMod
## "Souperior" modification for Skeleton2D; Reaches for the target with a chain of bones

## Target node for the modification;
## The bone is pointed towards this;
## To avoid unintended behaviour, make sure this node is NOT a child of the chain base.
@export var target_node: Node2D: 
	set(value):
		target_node = value
		if Engine.is_editor_hint():
			update_configuration_warnings()

## 
@export var determenistic: bool = false

## Offset angle from target, in degrees; used for export.
@export_range(-180,180,0.001,"or_greater", "or_less") \
		 var bias_offset_degrees: float = 0:
	set(new_value):
		bias_offset_degrees = wrapf(new_value,-180,180)
		_bias_offset = deg_to_rad(bias_offset_degrees)

## If true, the modification is calculated and applied.
@export var enabled: bool = false


## The start of the chain
@export var chain_root: Bone2D:
	set(value):
		chain_root = value
		_get_bone_nodes()
		if Engine.is_editor_hint():
			update_configuration_warnings()

## End of the chain 
@export var chain_tip: Bone2D:
	set(value):
		chain_tip = value
		_get_bone_nodes()
		if Engine.is_editor_hint():
			update_configuration_warnings()

var _bone_nodes: Array[Bone2D]
var _bias_offset: float = 0



## How many passes the FABRIK does PER FRAME;
## This should work just fine at 1, but if you feel like the chain moves to the target too slow, you can increase it;
## Although I do not recommend to do so, as it effectively multiplies the amount of computations per frame.
@export var iterations: int = 1:
	set(new_value):
		iterations = clampi(new_value,1,16)

@export_category("Easing")

@export var ease_rotation: bool = false: 
	set(value):
		ease_rotation = value
		if Engine.is_editor_hint():
			update_configuration_warnings()

@export var easing: ZMPhysEasingAngular:
	set(value):
		if not value is ZMPhysEasingAngular:
			easing = null
		else:
			easing = value.duplicate()
			easing.force_set((_target_point - _base_point).angle())
			easing.parameter_resource_changed.connect(_on_parameter_resource_changed)
		_fill_easing_stack(easing)
		if Engine.is_editor_hint():
			update_configuration_warnings()

var _easing_stack: Array[ZMPhysEasingAngular]

func _fill_easing_stack(value: ZMPhysEasingAngular) -> void:
	_easing_stack.resize(_bone_nodes.size())
	for i: int in range(_bone_nodes.size()):
		if value == null:
			_easing_stack[i] = null
			continue
		_easing_stack[i] = value.duplicate()
		_easing_stack[i].force_set(_bone_nodes[i].global_rotation)

func _on_parameter_resource_changed(params: ZMPhysEasingParams) -> void: 
	for i: ZMPhysEasingAngular in _easing_stack:
		i.easing_params = params

var _base_point: Vector2
var _target_point: Vector2
var _joint_points: PackedVector2Array
var _limb_lengths: PackedFloat32Array


func _get_configuration_warnings():
	var warn_msg: Array[String] = []
	if !chain_root:
		warn_msg.append("Chain root not set!")
	if !chain_tip:
		warn_msg.append("Chain tip not set!")
	if !target_node: 
		warn_msg.append("Target node not set!")
	if ease_rotation && !easing: 
		warn_msg.append("Easing enabled, but the resource is not set!")
	return warn_msg


func _ready() -> void:
		_fill_easing_stack(easing)


func process_loop(delta) -> void:
	if !(
			enabled 
			and target_node 
			and _bone_nodes.size()>0
			and _parent_enable_check()
		):
		return
	_scale_orient = sign(_bone_nodes[0].global_transform.determinant())
	
	handle_ik(delta)


## make and apply IK calculations
func handle_ik(delta: float) -> void:
	_initialize_calculation_variables(delta)
	if determenistic:
		_handle_pole()
	for i: int in iterations:
		_backward_pass()
		_forward_pass()
	_apply_chain_to_bones(delta)


## If pole node is set, orient all the virtual bones towards it
func _handle_pole() -> void:
	var pole_vector: Vector2 = Vector2.from_angle(target_node.global_rotation + _bias_offset * _scale_orient)
	for i:int in range(1,_joint_points.size()):
		_joint_points[i] = _joint_points[i-1] + pole_vector * _limb_lengths[i-1]


## [not intended for access]
## first half of mathemagic happens here
func _backward_pass() -> void:
	_joint_points[-1] = _target_point
	for i: int in range(_joint_points.size() - 1, 0, -1):
		var this_bone:Bone2D = _bone_nodes[i-1] 
		var a:Vector2 = _joint_points[i]
		var b:Vector2 = _joint_points[i - 1]
		var angle:float = a.angle_to_point(b)
		_joint_points[i - 1] = a + Vector2(_limb_lengths[i - 1], 0).rotated(angle)


## [not intended for access]
## second half of mathemagic happens here
func _forward_pass() -> void:
	_joint_points[0] = _base_point
	for i: int in range(_joint_points.size() - 1):
		
		var a:Vector2 = _joint_points[i]
		var b:Vector2 = _joint_points[i + 1]
		var angle:float = a.angle_to_point(b)
		
		_joint_points[i + 1] = a + Vector2(_limb_lengths[i], 0).rotated(angle)


## [Not intended for access]
## Charging up the mathemagical ritual
func _initialize_calculation_variables(delta: float) -> void:
	_base_point = _bone_nodes[0].global_position
	
	_target_point = target_node.global_position
	
	#region Joint points and lengths
	_joint_points.clear()
	_limb_lengths.clear()
	for i: Bone2D in _bone_nodes:
		_joint_points.append(i.global_position)
		_limb_lengths.append(i.get_length())
	
	# calculate the chain tip
	_joint_points.append(
			_bone_nodes[-1].global_position \
			+ Vector2.from_angle(
					_bone_nodes[-1].global_rotation \
					- _bone_nodes[-1].get_bone_angle()
				) * _bone_nodes[-1].get_length()
		)
	#endregion


## [not intended for access]
## Writes the point chain data to bone node positions
func _apply_chain_to_bones(delta) -> void:
	for i:int in _bone_nodes.size():
		var target_rotation =  \
						_joint_points[i].angle_to_point(
									_joint_points[i + 1]
								)
		if _easing_stack.size() > i:
			if _easing_stack[i] != null and ease_rotation:
				_easing_stack[i].update(delta, target_rotation)
				target_rotation = _easing_stack[i].state
		_bone_nodes[i].global_rotation = target_rotation \
						- _bone_nodes[i].get_bone_angle() * _scale_orient


func _get_bone_nodes() -> void:
	_bone_nodes.clear()
	if chain_root and chain_tip: 
		var i: Node = chain_tip
		while i is Bone2D:
			_bone_nodes.push_front(i)
			if i == chain_root: return
			i = i.get_parent()
	_bone_nodes.clear()
