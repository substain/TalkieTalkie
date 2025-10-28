class_name SlideContext2D
extends SlideContext

## Contains information about the slide setup and the 2D world

var camera: Camera2D
var camera_tween: Tween
var slide_center_locations: Dictionary[Vector2, Slide]

func _init(slide_size_new: Vector2, camera_new: Camera2D) -> void:
	slide_size = slide_size_new
	slide_center_offset = slide_size_new / 2
	camera = camera_new
	slide_context_type = SlideContextType.NODE_2D
	
func get_slide_center_position(slide: Slide) -> Vector2:
	return (slide.get_parent() as Node2D).global_position + slide_center_offset

func get_sorted_slide_locations_by_center(relative_to: Vector2) -> Array[Vector2]:
	var arrays: Array[Vector2] = slide_center_locations.keys()
	arrays.sort_custom(sort_by_dist.bind(relative_to))
	return arrays
	
static func sort_by_dist(a: Vector2, b: Vector2, relative_to: Vector2) -> int:
	return relative_to.distance_to(a) < relative_to.distance_to(b)
