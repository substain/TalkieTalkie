class_name LinearProgressTracker2D extends Area2D

# Tracks the position of an object and changes the current slide's progress accordingly.
# Currently, this only tracks from left to right, i.e. this is not generalized behavior.

@export var start_point: Marker2D
@export var end_point: Marker2D

## which slide this refers to. If no slide is set, this tries to infer the slide from the parent
@export var slide_target: Slide

var slide_index: int

var tracked_object: Node2D
var start_pos_x: float
var end_pos_x: float
var previous_progress: float = 0.0

func _ready() -> void:

	if slide_target == null:
		var parent: Node = get_parent()
		if parent == null:
			push_warning("Could not infer target slide for LinearProgressTracker2D '", self.name, "'. This node will not work.")
			return
		else:
			slide_target = parent
	
	slide_target.index_initialized.connect(_on_slide_target_index_initialized)

func _physics_process(_delta: float) -> void:
	if tracked_object == null:
		return
		
	if !is_instance_valid(tracked_object):
		tracked_object = null
		return

	var current_x_pos: float = tracked_object.position.x
	if current_x_pos < start_pos_x || current_x_pos > end_pos_x:
		return
		
	var current_progress: float = inverse_lerp(start_pos_x, end_pos_x, current_x_pos)
	if is_equal_approx(previous_progress, current_progress):
		return
		
	previous_progress = current_progress
	TTSlideHelper.slide_controller.set_slide_progress(slide_index, current_progress)
		
func _on_body_entered(body: Node2D) -> void:
	tracked_object = body

func _on_body_exited(body: Node2D) -> void:
	if body != tracked_object:
		return
	tracked_object = null

func _on_slide_target_index_initialized() -> void:
	slide_index = slide_target.get_order_index()
	start_pos_x = start_point.global_position.x
	end_pos_x = end_point.global_position.x
