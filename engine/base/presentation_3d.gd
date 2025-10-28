class_name Presentation3D
extends Presentation

## Adds 3D functionality to the main presentation script.

@export var camera: Camera3D

func init_context() -> void:
	SlideHelper.set_context(SlideContext3D.new(slide_size, camera))
	
