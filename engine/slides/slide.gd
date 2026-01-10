class_name Slide extends Control

signal index_initialized

@warning_ignore("unused_signal")
signal activate_slide

var _order_initialized: bool = false
var _order_index: int

func _ready() -> void:
	reset()
	
## reset the current slides progress
func reset() -> void:
	pass
	
func set_order_index(order_index_new: int) -> void:
	_order_index = order_index_new
	_order_initialized = true
	index_initialized.emit()

func get_order_index() -> int:
	if !_order_initialized:
		push_warning("Trying to access a slide's order index before it was initialized. Use index_initialized to ensure the index is already available.")
	return _order_index

## skip animations and show the full slide
func show_full() -> void:
	pass

## Continues the current slide progress. Returns true if the full slide is shown.
func continue_slide() -> bool:
	return true

## Sets the current slide progress to the given position, like a "seek" function. Similar to continue_slide(), this returns true if the full slide is shown.
func set_progress(_relative_progress: float) -> bool:
	return true
	
## Returns true if the current slide is at the start position
func is_at_start() -> bool:
	return true

## Returns true if the current slide is finished.
func is_finished() -> bool:
	return true

## Returns the title of this slide
func get_title() -> String:
	return ""

## Sets a new title for the slide
func set_title(_new_title: String) -> void:
	pass

## Returns the content of this slide
func get_content() -> String:
	return ""
	
## Sets new content for the slide
func set_content(_new_content: String) -> void:
	pass

## Returns the comments for this slide
func get_comments() -> String:
	return ""
		
## Sets new comments for the slide
func set_comments(_new_comments: String) -> void:
	pass

## Returns the estimated time for this slide (in seconds)
func get_estimated_time_seconds() -> int:
	return 0
	
## Sets a new estimated time for the slide
func set_estimated_time_seconds(_new_estimated_time: int) -> void:
	pass

func get_in_transition_override() -> Transition:
	return null

## Sets a new in transition for the slide
func set_in_transition_override(_new_in_transition_override: Transition) -> void:
	pass
