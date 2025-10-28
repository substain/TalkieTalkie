class_name Presentation2D
extends Presentation

## Adds 2D functionality to the main presentation script.

@export var camera: Camera2D

func init_context() -> void:
	SlideHelper.set_context(SlideContext2D.new(slide_size, camera))
