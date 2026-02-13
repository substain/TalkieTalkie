class_name Presentation2D
extends Presentation

## Adds 2D functionality to the main presentation script.

## This presentation type expects a Camera2D to work properly.
## If this is null, a new Camera2D node will be added during initialization
@export var camera: Camera2D
	
func ensure_basic_setup() -> void:
	if default_transition == null:
		default_transition = MoveTransition2D.new()
	if camera == null:
		var cam2D: Camera2D = Camera2D.new()
		add_child(cam2D)
		camera = cam2D
	
func init_context() -> void:
	TTSlideHelper.set_context(SlideContext2D.new(slide_size, camera))
