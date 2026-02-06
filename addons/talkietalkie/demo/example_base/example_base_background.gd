class_name ExampleBaseBackground extends TextureRect

@export var slide_change_anim_duration: float = 1.5
@export var slide_change_anim_curve: Curve
@export var hue_values: Array[float] = [0.0, 0.3, 0.6]
@export var alpha_factor: float = 0.7
@export var hue_factor: float = 0.05

@onready var color_rect: ColorRect = $ColorRect
var change_slide_tween: Tween = null

func _ready() -> void:
	TTSlideHelper.slide_changed.connect(_on_slide_changed)
	color_rect.color.a = 0.0

func tween_overlay(hue: float) -> void:
	if is_instance_valid(change_slide_tween):
		change_slide_tween.kill()
		
	color_rect.color = Color.from_hsv(hue, hue_factor, 1.0, 0.0)
	change_slide_tween = create_tween()
	change_slide_tween.tween_method(custom_overlay_tween, 0.0, 1.0, slide_change_anim_duration)

func custom_overlay_tween(progress: float) -> void:
	color_rect.color.a = slide_change_anim_curve.sample(progress) * alpha_factor


func _on_slide_changed(new_slide: Slide) -> void:
	tween_overlay(hue_values[new_slide.get_order_index() % hue_values.size()])
