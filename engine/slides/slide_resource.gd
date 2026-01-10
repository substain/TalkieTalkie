class_name SlideResource extends Resource

@export var slide_title: String

@export_multiline var slide_content: String

@export_multiline var comments: String

@export var estimated_time: int = 0

@export var in_transition_override: Transition = null
