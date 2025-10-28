class_name LinearProgresTracker2D extends Area2D

# Tracks the position of an object and changes the current slide's progress accordingly.
# Currently, this only tracks from left to right, i.e. this is not generalized behavior.

@export var start_x: float
@export var end_x: float

var tracked_object: Node2D

func _ready() -> void:
	# TODO: find minimum and maximum based on collision shape?
	pass

func _physics_process(delta: float) -> void:
	if tracked_object == null:
		return
		
	if !is_instance_valid(tracked_object):
		tracked_object = null
		return

	var current_x_pos: float = tracked_object.position.x
	
	if current_x_pos > start_x || current_x_pos < end_x:
		return
		
	var current_progress: float = inverse_lerp(start_x, end_x, current_x_pos)
	
	SlideHelper.slide_controller.seek()
	
	# TODO request slide progress based on current progress
		
func _on_body_entered(body: Node2D) -> void:
	tracked_object = body

func _on_body_exited(body: Node2D) -> void:
	if body != tracked_object:
		return
	tracked_object = null
