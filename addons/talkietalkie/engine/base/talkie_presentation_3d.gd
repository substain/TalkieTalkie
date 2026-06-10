class_name TalkiePresentation3D
extends TalkiePresentation

## Adds 3D functionality to the main presentation script.

## This presentation type expects a Camera3D to work properly.
## If this is null, a new Camera3D node will be added during initialization
@export var camera: Camera3D
	
func ensure_basic_setup() -> void:
	if default_transition == null:
		default_transition = TalkieMoveTransition3D.new()
		
	if camera == null:
		var cam3D: Camera3D = Camera3D.new()
		add_child(cam3D)
		camera = cam3D

func init_context() -> void:
	TalkieSlideHelper.set_context(TalkieSlideContext3D.new(slide_size, camera))
