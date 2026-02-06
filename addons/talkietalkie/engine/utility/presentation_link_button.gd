class_name PresentationLinkButton
extends Button

## Switches to the specified presentation.

@export_file_path("*.tscn") var presentation_scene: String

func _ready() -> void:
	presentation_scene = TalkieTalkie.replace_plugin_path(presentation_scene)
	
	if presentation_scene.is_empty():
		push_warning(name, ": This presentation link button has no scene set up!")
		return
		
	pressed.connect(_on_button_pressed)

func _on_button_pressed() -> void:
	TTSlideHelper.set_context(null)
	get_tree().change_scene_to_file.call_deferred(presentation_scene)
