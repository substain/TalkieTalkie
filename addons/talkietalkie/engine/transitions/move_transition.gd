class_name MoveTransition
extends Transition

## Move transition according to the provided direction.
## Note that this transition is intended for a basic control node setup.

const visible_pos: Vector2 = Vector2.ZERO

## The direction a slide is wiped towards
@export var slide_move_direction: Vector2 = Vector2.LEFT

## Duck Typing because we may have the same property but not the same base nodes
@warning_ignore_start("unsafe_property_access") 

func start_transition(from_slide: Slide, to_slide: Slide) -> Tween:
	if !Util.has_position_property(from_slide):
		push_warning("MoveTransition expects both slides to have a 'position' property, but '", from_slide, "' does not have one. Stopping the transition.")
		return
	if !Util.has_position_property(to_slide):
		push_warning("MoveTransition expects both slides to have a 'position' property, but '", from_slide, "' does not have one. Stopping the transition.")
		return
	
	from_slide.modulate.a = 1.0
	to_slide.modulate.a = 1.0
	from_slide.visible = true
	to_slide.visible = true
	
	var previous_slide_target_pos: Vector2 = visible_pos + (TTSlideHelper.get_context().slide_size * slide_move_direction)
	var next_slide_source_pos: Vector2 = visible_pos + (TTSlideHelper.get_context().slide_size * -slide_move_direction)
		
	from_slide.position = visible_pos
	to_slide.position = next_slide_source_pos
	
	var tween: Tween = to_slide.create_tween().set_parallel(true)
	tween.tween_property(from_slide, "position", previous_slide_target_pos, duration)
	tween.tween_property(to_slide, "position", visible_pos, duration)	
	
	tween.finished.connect(_clean_up.bind(from_slide, to_slide))
	return tween

func on_finish_transition(_previous_from_slide: Slide) -> void:
	pass

func _clean_up(from_slide: Slide, to_slide: Slide) -> void:
	from_slide.modulate.a = 0.0
	from_slide.position = visible_pos
	to_slide.position = visible_pos
@warning_ignore_restore("unsafe_property_access")
