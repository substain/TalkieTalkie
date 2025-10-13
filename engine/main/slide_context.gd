class_name SlideContext
extends RefCounted

## Contains information about the slide setup
## The current context is accessible via the SlideHelper autoload.

var slide_size: Vector2
var slide_center_offset: Vector2

func _init(slide_size_new: Vector2) -> void:
	slide_size = slide_size_new
	slide_center_offset = slide_size_new / 2
	
