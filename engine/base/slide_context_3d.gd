class_name SlideContext3D
extends SlideContext

## Contains information about the slide setup and the 3D world

var camera: Camera3D
var camera_tween: Tween
var slide_center_locations: Dictionary[Vector3, Slide]

func _init(slide_size_new: Vector2, camera_new: Camera3D) -> void:
	slide_size = slide_size_new
	slide_center_offset = slide_size_new / 2
	camera = camera_new
	slide_context_type = SlideContextType.NODE_3D
	
func get_slide_center_position(slide: Slide) -> Vector3:
	return (slide.get_parent() as Node3D).global_position + Vector3(slide_center_offset.x, slide_center_offset.y, 0)

func get_sorted_slide_locations_by_center(relative_to: Vector3) -> Array[Vector3]:
	var arrays: Array[Vector3] = slide_center_locations.keys()
	arrays.sort_custom(sort_by_dist.bind(relative_to))
	return arrays
	
static func sort_by_dist(a: Vector3, b: Vector3, relative_to: Vector3) -> int:
	return relative_to.distance_to(a) < relative_to.distance_to(b)
