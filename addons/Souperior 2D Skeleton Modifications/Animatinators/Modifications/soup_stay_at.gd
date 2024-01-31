@tool
@icon("Icons/icon_stay_at.png")
class_name SoupStayAt
extends SoupMod
## "Souperior" modification for Skeleton2D; 
## Moves bone's global position to a target_node global position;
## Can be used as a jiggle modifier for the bone's position!

## Target node for the modification;
## The bone tries to stay at the global position of this node;
## To avoid unintended behaviour, make sure this node is NOT a child of the to-be-modified bone.
@export var target_node: Node2D

## If true, the modifications are applied.
@export var enabled: bool = false:
	set(new_value):
		enabled = new_value
		fix_easing()

@export_category("Bones")
#region bone_node 
## The to-be-modified bone node.
@export var bone_node: Bone2D:
	set(new_value):
		bone_node=new_value
		fix_easing()
#endregion 

#region easing
@export_category("Easing")
## If true, easing is appied;
## Required for the effect to feel "jiggly".
@export var use_easing: bool = false:
	set(new_value):
		use_easing = new_value
		fix_easing()
## Easing Resource;
## Defines easing behaviour.
@export var easing: SoupySecondOrderEasing: 
	set(new_value):
		if !new_value:
			easing = null
			return
		easing = new_value.duplicate(true)
		fix_easing()
#endregion


func _enter_tree() -> void:
	fix_easing()


func _ready() -> void:
	fix_easing()


func _process(delta: float) -> void:
	if !(
			enabled 
			and target_node 
			and bone_node
			and _parent_enable_check() 
		):
		return
	
	var result_position: Vector2 = target_node.global_position
	if easing and use_easing:
		easing.update(delta,target_node.global_position)
		result_position = easing.state
	
	var fixed_position: Vector2 = \
	_mod_stack.apply_bone_position_mod(
			bone_node, 
			position_global_to_local(
				result_position, bone_node.get_parent()
			)
		)
	
	if fixed_position and easing and use_easing:
		easing.state = position_local_to_global(fixed_position, bone_node.get_parent())


## Updates the internal variables of the easing resource to match the current wanted state;
## Prevents weird behaviour on bone change, scene reload, or any other situation that may cause the easing internals to become outdated.
func fix_easing():
	if !(easing and bone_node and target_node):
		return
	easing.initialize_variables(target_node.global_position)
