@tool
@icon("Icons/icon_bone_state.png")
class_name SoupStateComponentGroup
extends SoupStateComponent
## Applies and records all child property state components at once.

## Number of saved state positions.
@export var state_count: int = 1:
	set(new_value):
		state_count = max(1,new_value)
		_update_child_state_count()

## Selected state position.
@export var current_state: int:
	set(new_value):
		current_state = clampi(new_value,0,state_count-1)
		_update_child_current_state()


## Applies child state components
func apply() -> void:
	super()
	for i: Node in get_children():
		if i is SoupStateComponent:
			i.apply()


## Records child state components
func record() -> void:
	super()
	for i: Node in get_children():
		if i is SoupStateComponent:
			i.record()


func _update_child_current_state() -> void:
	for i: Node in get_children():
		if i is SoupStateComponent:
			i.current_state = current_state


func _update_child_state_count() -> void:
	for i: Node in get_children():
		if i is SoupStateComponent:
			i.state_count = state_count
