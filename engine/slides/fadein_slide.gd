class_name FadeInSlide extends Slide

var anim_steps: int = 0
var current_anim_step: int = 0

@export var elements_to_fade_in: Array[CanvasItem]
@export var element_fade_in_time: float = 0.5

var fade_tween: Tween = null

var fade_tweens: Array[Tween] = []

func _ready() -> void:
	super()
	anim_steps = elements_to_fade_in.size()

func reset() -> void:
	for tween in fade_tweens:
		tween.kill()
		
	fade_tweens.clear()
		
	for element: CanvasItem in elements_to_fade_in:
		element.modulate.a = 0.0
		
	current_anim_step = 0
	
func show_full() -> void:
	for element: CanvasItem in elements_to_fade_in:
		element.modulate.a = 1.0
	current_anim_step = anim_steps

func continue_slide() -> bool:
	if is_finished(): 
		return true
		
	if is_instance_valid(fade_tween):
		fade_tween.set_speed_scale(2.0)
	
	fade_tween = create_tween()
	fade_tween.tween_property(elements_to_fade_in[current_anim_step], "modulate:a", 1.0, element_fade_in_time)
	fade_tweens.append(fade_tween)
	current_anim_step += 1		
	return false

func is_finished() -> bool:
	return current_anim_step >= anim_steps
