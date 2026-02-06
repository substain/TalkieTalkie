class_name ResourceSlide extends Slide

@export var resource: SlideResource

func _ready() -> void:
	super()
	
# override
func get_title() -> String:
	return resource.slide_title

# override
func set_title(new_title: String) -> void:
	resource.slide_title = new_title
		
# override
func get_content() -> String:
	return resource.slide_content

# override	
func set_content(new_content: String) -> void:
	resource.slide_content = new_content
	
# override	
func get_comments() -> String:
	return resource.comments
	
# override	
func set_comments(new_comments: String) -> void:
	resource.comments = new_comments
	
# override
func get_estimated_time_seconds() -> int:
	return resource.estimated_time 
	
# override	
func set_estimated_time_seconds(new_estimated_time: int) -> void:
	resource.estimated_time  = new_estimated_time
	
# override
func get_in_transition_override() -> Transition:
	return resource.in_transition_override

# override	
func set_in_transition_override(new_in_transition_override: Transition) -> void:
	resource.in_transition_override = new_in_transition_override
