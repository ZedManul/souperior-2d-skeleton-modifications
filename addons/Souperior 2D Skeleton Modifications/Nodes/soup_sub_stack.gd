@tool
@icon("Icons/icon_sub_stack.png")
class_name SoupSubStack
extends Node
## Used for grouping modifications within a stack;
## Allows for toggling whole groups at once.
## (!)Currently, nesting substacks inside substacks leads to some unintended behaviour

## If true, the child modifications are applied.
@export var enabled: bool = true
