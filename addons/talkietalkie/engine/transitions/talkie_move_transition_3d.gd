class_name TalkieMoveTransition3D
extends TalkieTransition

func start_transition(_from_slide: TalkieSlide, to_slide: TalkieSlide) -> Tween:
	var context: TalkieSlideContext3D = TalkieSlideHelper.get_context_3d()
	if is_instance_valid(context.camera_tween):
		context.camera_tween.kill()
		
	var camera: Camera3D = context.camera
	var global_pos_to: Vector3 = context.get_slide_center_position(to_slide)

	context.camera_tween = to_slide.create_tween()
	context.camera_tween.tween_property(camera, "global_position", global_pos_to, duration)
	return context.camera_tween
	
func on_finish_transition(_previous_from_slide: TalkieSlide) -> void:
	pass
