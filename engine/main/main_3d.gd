class_name Main3D
extends Main

@export var camera: Camera3D

func init_context() -> void:
	SlideHelper.set_context(SlideContext3D.new(slide_size, camera))
