class_name Slide extends CanvasItem

@export var slide_title: String

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

## Retunrs true if the current slide is finished.
func is_finished() -> bool:
	return true
