@tool
@icon("Icons/icon_bone_state_component.png")
class_name SoupStateSprite
extends SoupStateComponent
## Can apply and record certain important properties of a Sprite2D node.

## The monitored and modified node
@export var target_node: Sprite2D

@export_group("Frame")

## If true, the node will apply or record this property when calling apply() or record() 
@export var modify_frame: bool = false
## The recorded value.
@export var frame_value: int = 0


@export_group("Frame Coords")

## If true, the node will apply or record this property when calling apply() or record() 
@export var modify_frame_coords: bool = false
## The recorded value.
@export var frame_coords_value:= Vector2.ZERO


@export_group("Region")

## If true, the node will apply or record this property when calling apply() or record() 
@export var modify_region: bool = false
## The recorded value.
@export var region_value: Rect2


@export_group("Texture")

## If true, the node will apply or record this property when calling apply() or record() 
@export var modify_tex: bool = false
## The recorded value.
@export var tex_value: Texture2D


## When called, will set chosen properties on the target node to the recorded values.
func apply()->void:
	if !target_node:
		return
	
	super()
	
	if modify_frame:
		target_node.frame = frame_value
	
	if modify_frame_coords:
		target_node.frame_coords = frame_coords_value
	
	if modify_region:
		target_node.region_rect = region_value
	
	if modify_tex:
		target_node.texture = tex_value


## When called, will record chosen properties from the target node.
func record()->void:
	if !target_node:
		return
	
	super()
	
	if modify_frame:
		frame_value = target_node.frame
	
	if modify_frame_coords:
		frame_coords_value = target_node.frame_coords
	
	if modify_region:
		region_value = target_node.region_rect
	
	if modify_tex:
		tex_value = target_node.texture
