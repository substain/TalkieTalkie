class_name SlideContext3D
extends SlideContext

## Contains information about the slide setup and the 3D world

var camera: Camera3D

func _init(slide_size_new: Vector2, camera_new: Camera3D) -> void:
	slide_size = slide_size_new
	slide_center_offset = slide_size_new / 2
	
	camera = camera_new
