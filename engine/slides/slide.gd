class_name Slide extends CanvasItem

@export var slide_title: String

## Overrides the default transition from the previous slide to this slide
@export var in_transition_override: Transition = null

var order_index: int

func _ready() -> void:
	reset()
	
## reset the current slides progress
func reset() -> void:
	pass

## skip animations and show the full slide
func show_full() -> void:
	pass

## Continues the current slide progress. Returns true if the full slide is shown.
func continue_slide() -> bool:
	return true

## Sets the current slide progress to the given position, like a "seek" function. Similar to continue_slide(), this returns true if the full slide is shown.
func set_progress(relative_progress: float) -> bool:
	return true
	
## Returns true if the current slide is at the start position
func is_at_start() -> bool:
	return true

## Returns true if the current slide is finished.
func is_finished() -> bool:
	return true
