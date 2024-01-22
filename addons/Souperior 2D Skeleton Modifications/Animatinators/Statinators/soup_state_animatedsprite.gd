@tool
@icon("Icons/icon_bone_state_component.png")
class_name SoupStateAnimatedSprite
extends SoupStateComponent
## Can apply and record certain important properties of an AnimatedSprite2D node.

## The monitored and modified node
@export var target_node: AnimatedSprite2D


@export_group("Sprite Frames")
## If true, the node will apply or record this property when calling apply() or record() 
@export var modify_spriteframes: bool = false
## The recorded value.
@export var spriteframe_value: SpriteFrames


@export_group("Animation")
## If true, the node will apply or record this property when calling apply() or record() 
@export var modify_animation: bool = false
## The recorded value.
@export var animation_value: StringName


@export_group("Frame")
## If true, the node will apply or record this property when calling apply() or record() 
@export var modify_frame: bool = false
## The recorded value.
@export var frame_value: int = 0


## When called, will set chosen properties on the target node to the recorded values.
func apply()->void:
	if !target_node:
		return
	
	super()
	
	if modify_spriteframes:
		target_node.sprite_frames = spriteframe_value
	
	if modify_frame:
		target_node.frame = frame_value
	
	if modify_animation:
		target_node.animation = animation_value


## When called, will record chosen properties from the target node.
func record()->void:
	if !target_node:
		return
	
	super()
	
	if modify_spriteframes:
		spriteframe_value = target_node.sprite_frames
	
	if modify_frame:
		frame_value = target_node.frame
	
	if modify_animation:
		animation_value = target_node.animation
	
	
