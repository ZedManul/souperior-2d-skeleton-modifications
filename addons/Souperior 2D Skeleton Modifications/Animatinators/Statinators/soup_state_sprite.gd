@tool
@icon("Icons/icon_bone_state_component.png")
class_name SoupStateSprite
extends SoupStateComponent


@export var target_node: Sprite2D


@export_group("Frame")

@export var modify_frame: bool = false

@export var frame_value: int = 0


@export_group("Frame Coords")

@export var modify_frame_coords: bool = false

@export var frame_coords_value:= Vector2.ZERO


@export_group("Region")

@export var modify_region: bool = false

@export var region_value: Rect2


@export_group("Texture")

@export var modify_tex: bool = false

@export var tex_value: Texture2D


func apply()->void:
	if !target_node:
		return
	
	if modify_frame:
		target_node.frame = frame_value
	
	if modify_frame_coords:
		target_node.frame_coords = frame_coords_value
	
	if modify_region:
		target_node.region_rect = region_value
	
	if modify_tex:
		target_node.texture = tex_value


func record()->void:
	if !target_node:
		return
	
	if modify_frame:
		frame_value = target_node.frame
	
	if modify_frame_coords:
		frame_coords_value = target_node.frame_coords
	
	if modify_region:
		region_value = target_node.region_rect
	
	if modify_tex:
		tex_value = target_node.texture
