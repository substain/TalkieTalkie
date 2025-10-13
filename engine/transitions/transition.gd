class_name Transition
extends Resource
## Default implementation for a transition: Mix Transition. Does not completely cover background.

@export var duration: float

func start_transition(from_slide: Slide, to_slide: Slide) -> Tween:
	from_slide.modulate.a = 1.0
	to_slide.modulate.a = 0.0
	from_slide.visible = true
	to_slide.visible = true
	
	var tween: Tween = to_slide.create_tween().set_parallel(true)
	tween.tween_property(from_slide, "modulate:a", 0.0, duration)
	tween.tween_property(to_slide, "modulate:a", 1.0, duration)
	return tween
