@tool
@icon("Icons/customModificationIcon.png")
extends SoupStackPart
class_name SoupMod

## Parent node for modification stacks.
##
## Not intended for actual use.

func parent_enable_check() -> bool:
	if !(ModStack is SoupStack):
		return false
	if (SubStack is SoupSubStack):
		return (ModStack.Enabled) and (SubStack.Enabled)
	else:
		return ModStack.Enabled

func PositionGlobalToLocal( position: Vector2, parentNode: Node2D) -> Vector2:
	return (position - parentNode.global_position)\
	.rotated(-parentNode.global_rotation)\
	/parentNode.global_scale

func AngleGlobalToLocal( angle: float, parentNode: Node2D) -> float:
	return (angle - parentNode.global_rotation*sign(parentNode.global_scale.y))
