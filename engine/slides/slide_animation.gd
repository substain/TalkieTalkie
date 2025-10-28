class_name SlideAnimation extends Node

## Base class for animations for elements on slides.
## Implements fade animations.

@export var animation_dur: float = 0.0

## The targets to animate. If left empty, the parent of the node will be assigned as the animation target, if it is a canvas item
@export var targets: Array[CanvasItem] = []

## The order of animations. Higher sort order means later execution. For equal numbers, the tree order is used.
@export var sort_order: int = 0

## Set via AnimSlide, used for ordering
var tree_index: int = 0

#TODO: do we need both?
var _anim_tweens: Array[Tween] = []
var _current_tween: Tween = null

func _ready() -> void:
	ensure_targets_set()
		
func ensure_targets_set() -> void:
	if targets.size() == 0 && get_parent() is CanvasItem:
		targets = [get_parent()]

func reset() -> void:
	_clear_tweens()
	
	for target: CanvasItem in targets:
		if !is_instance_valid(target):
			push_warning("found invalid slide animation reference in ", self.name)
			return
		target.modulate.a = 0.0

func animate() -> void:
	if is_zero_approx(animation_dur):
		skip_to_finish()
		return
		
	_kill_current_tween()
	_current_tween = create_tween().set_parallel(true)
	
	for target: CanvasItem in targets:
		_current_tween.tween_property(target, "modulate:a", 1.0, animation_dur)
	
	_anim_tweens.append(_current_tween)

func skip_to_finish() -> void:
	_kill_current_tween()
		
	for target: CanvasItem in targets:
		target.modulate.a = 1.0
	
func is_valid() -> bool:
	return targets.size() > 0

func _clear_tweens() -> void:
	for tween: Tween in _anim_tweens:
		if is_instance_valid(tween):
			tween.kill()
		
	_anim_tweens.clear()

func _kill_current_tween() -> void:
	if is_instance_valid(_current_tween):
		_current_tween.kill()
