@tool
@icon("Icons/icon_bone_state_component.png")
class_name SoupStateAnimatedSprite
extends SoupStateComponent


@export var target_node: AnimatedSprite2D


@export_group("Sprite Frames")

@export var modify_spriteframes: bool = false

@export var spriteframe_value: SpriteFrames


@export_group("Animation")

@export var modify_animation: bool = false

@export var animation_value: StringName


@export_group("Frame")

@export var modify_frame: bool = false

@export var frame_value: int = 0



func apply()->void:
	if !target_node:
		return
	
	if modify_spriteframes:
		target_node.sprite_frames = spriteframe_value
	
	if modify_frame:
		target_node.frame = frame_value
	
	if modify_animation:
		target_node.animation = animation_value

func record()->void:
	if !target_node:
		return
	
	if modify_spriteframes:
		spriteframe_value = target_node.sprite_frames
	
	if modify_frame:
		frame_value = target_node.frame
	
	if modify_animation:
		animation_value = target_node.animation
	
	
