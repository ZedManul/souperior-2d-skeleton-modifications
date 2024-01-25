@tool
@icon("Icons/icon_bone_state_component.png")
class_name SoupStateComponent
extends Node
## Parent node for property state components;
## State components can record and then apply properties of other nodes on command;

## Emitted when the component is applied.
signal applied()
## Emitted when the component is recorded.
signal recorded()



## Does nothing; 
## Overriden by the inheriting classes.
func apply() -> void:
	applied.emit()

## Does nothing; exists for inheritance
## Overriden by the inheriting classes.
func record() -> void:
	recorded.emit()
