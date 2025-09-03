class_name SlideAnimation extends Node

@export var animation_dur: float = 0.0

## The targets to animate. If left empty, the parent of the node will be assigned as the animation target, if it is a canvas item
@export var targets: Array[CanvasItem] = []

## The order of animations. Higher sort order means later execution. For equal numbers, the tree order is used.
@export var sort_order: int = 0

var _fade_tweens: Array[Tween] = []

## Set via AnimSlide, used for ordering
var tree_index: int = 0

var _fade_tween: Tween = null

func _ready() -> void:
	assign_target()
		
func assign_target() -> void:
	if targets.size() == 0 && get_parent() is CanvasItem:
		targets = [get_parent()]

func reset() -> void:
	for tween in _fade_tweens:
		if is_instance_valid(tween):
			tween.kill()
		
	_fade_tweens.clear()
	for target: CanvasItem in targets:
		if !is_instance_valid(target):
			push_warning("found invalid slide animation reference in ", self.name)
			return
		target.modulate.a = 0.0

func animate() -> void:
	if is_zero_approx(animation_dur):
		skip_to_finish()
		return
		
	if is_instance_valid(_fade_tween):
		_fade_tween.kill()
		
	_fade_tween = create_tween().set_parallel(true)
	
	for target: CanvasItem in targets:
		_fade_tween.tween_property(target, "modulate:a", 1.0, animation_dur)
	
	_fade_tweens.append(_fade_tween)

func skip_to_finish() -> void:
	if is_instance_valid(_fade_tween):
		_fade_tween.kill()
		
	for target: CanvasItem in targets:
		target.modulate.a = 1.0
	
func is_valid() -> bool:
	return targets.size() > 0
