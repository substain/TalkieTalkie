class_name Transitions extends Object
	
static func fade_over_transition(from_slide: Slide, to_slide: Slide, duration: float = 1.0) -> Tween:
	from_slide.modulate.a = 1.0
	to_slide.modulate.a = 0.0
	from_slide.visible = true
	to_slide.visible = true
	
	#TODO: ensure to_slide has a higher draw order
	var tween: Tween = from_slide.create_tween()
	tween.tween_property(to_slide, "modulate:a", 1.0, duration)
		
	return tween

## TODO: this does not fully cover background
static func mix_transition(from_slide: Slide, to_slide: Slide, duration: float = 1.0) -> Tween:
	from_slide.modulate.a = 1.0
	to_slide.modulate.a = 0.0
	from_slide.visible = true
	to_slide.visible = true
	
	var tween: Tween = from_slide.create_tween().set_parallel(true)
	tween.tween_property(from_slide, "modulate:a", 0.0, duration)
	tween.tween_property(to_slide, "modulate:a", 1.0, duration)
	return tween
