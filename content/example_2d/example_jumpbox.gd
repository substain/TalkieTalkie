class_name ExampleJumpbox
extends StaticBody2D

var activation_tween: Tween = null
var base_modulate: Color

@export var target_progress: float
@export var label_text: String = "?"
@export_category("internal nodes")
@export var overlay: Node2D
@export var label: Label

func _ready() -> void:
	label.text = label_text
	overlay.modulate = Color.TRANSPARENT

func on_hit() -> void:
	if is_instance_valid(activation_tween):
		activation_tween.kill()
		
	SlideHelper.slide_controller.set_current_slide_progress(target_progress)
	overlay.modulate = Color.WHITE
	activation_tween = create_tween()
	activation_tween.tween_property(overlay, "modulate", Color.TRANSPARENT, 0.5)
