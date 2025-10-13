class_name FadeOverTransition
extends Transition
## Fades one slide over the other. Does not hide the previous slide - used for slides that have their own background.
## Warning: This transition assumes the to_slide has a higher draw order.

func start_transition(from_slide: Slide, to_slide: Slide) -> Tween:
	from_slide.modulate.a = 1.0
	to_slide.modulate.a = 0.0
	from_slide.visible = true
	to_slide.visible = true
	
	var tween: Tween = to_slide.create_tween()
	tween.tween_property(to_slide, "modulate:a", 1.0, duration)
		
	return tween
