class_name Main2D
extends Main

## Adds 2D functionality to the main script.

@export var camera: Camera2D

func init_context() -> void:
	SlideHelper.set_context(SlideContext2D.new(slide_size, camera))
	
func transition_to_slide(from_slide: Slide, to_slide: Slide, transition: Callable) -> void:
	if is_instance_valid(transition_tween):
		transition_tween.kill()
	transition_tween = transition.call(from_slide, to_slide)
	last_from_slide = from_slide

func show_only_current_slide() -> void:
	if is_instance_valid(transition_tween):
		transition_tween.kill()
	camera.global_position = SlideHelper.get_context_2d().get_slide_center_position(slide_instances[slide_index])
