@tool
@icon("customSubStackIcon.png")
extends Node
class_name SoupSubStack
## Used for grouping modifications within a stack;
## Allows for toggling whole groups at once.
## /!\Currently, nesting substacks inside substacks leads to some unintended behaviour/!\

## If true, the child modifications are applied.
@export var Enabled: bool = true
