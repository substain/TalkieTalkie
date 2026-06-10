class_name TalkieFadeOverTransition
extends TalkieTransition
## Fades one slide over the other. Does not hide the previous slide - used for slides that have their own background.
## Warning: This transition assumes the to_slide has a higher draw order.

func start_transition(from_slide: TalkieSlide, to_slide: TalkieSlide) -> Tween:
	from_slide.modulate.a = 1.0
	to_slide.modulate.a = 0.0
	from_slide.visible = true
	to_slide.visible = true
	
	var tween: Tween = to_slide.create_tween()
	tween.tween_property(to_slide, "modulate:a", 1.0, duration)
		
	return tween

func on_finish_transition(previous_from_slide: TalkieSlide) -> void:
	if is_instance_valid(previous_from_slide):
		previous_from_slide.modulate.a = 0.0
