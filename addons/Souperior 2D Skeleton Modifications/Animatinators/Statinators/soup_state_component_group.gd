@tool
@icon("Icons/icon_bone_state.png")
class_name SoupStateComponentGroup
extends SoupStateComponent
## Applies and records all child property state components at once.


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
