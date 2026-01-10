class_name SceneSlide extends Slide

@export var slide_title: String

@export_multiline var slide_content: String

@export_multiline var comments: String

@export var estimated_time_seconds: int = 0

## Overrides the default transition from the previous slide to this slide
@export var in_transition_override: Transition = null

# override
func get_title() -> String:
	return slide_title
	
# override
func set_title(new_title: String) -> void:
	slide_title = new_title
		
# override
func get_content() -> String:
	return slide_content

# override	
func set_content(new_content: String) -> void:
	slide_content = new_content
	
# override	
func get_comments() -> String:
	return comments
			
# override	
func set_comments(new_comments: String) -> void:
	comments = new_comments
	
# override
func get_estimated_time_seconds() -> int:
	return estimated_time_seconds
	
# override	
func set_estimated_time_seconds(new_estimated_time: int) -> void:
	estimated_time_seconds = new_estimated_time
	
# override
func get_in_transition_override() -> Transition:
	return in_transition_override

# override	
func set_in_transition_override(new_in_transition_override: Transition) -> void:
	in_transition_override = new_in_transition_override
