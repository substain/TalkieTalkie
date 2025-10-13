class_name MoveTransition2D
extends Transition

func start_transition(_from_slide: Slide, to_slide: Slide) -> Tween:
	var context: SlideContext2D = SlideHelper.get_context_2d()
	if is_instance_valid(context.camera_tween):
		context.camera_tween.kill()
		
	var camera: Camera2D = context.camera
	var global_pos_to: Vector2 = context.get_slide_center_position(to_slide)

	context.camera_tween = to_slide.create_tween()
	context.camera_tween.tween_property(camera, "global_position", global_pos_to, duration)
	return context.camera_tween
