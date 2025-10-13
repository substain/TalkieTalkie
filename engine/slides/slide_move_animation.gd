class_name SlideMoveAnimation extends SlideAnimation
## Implements move animations for slide elements.

@export var initial_element_offset: Vector2

var _target_base_positions: Array[Vector2] = []
var _target_start_positions: Array[Vector2] = []

@warning_ignore_start("unsafe_property_access")

var initialized: bool = false
var is_finished: bool = false

var was_drawn: bool = false

func _ready() -> void:
	super()
	
	if targets.is_empty():
		return
	
	await targets[0].draw
	was_drawn = true
	init_positions()

	#TODO maybe lazy init is more robust - see approach in animate() 
	if !is_finished:
		reset()
	else:
		skip_to_finish()

func init_positions() -> void:
	for target: CanvasItem in targets:
		if target.get_parent() is Container && target is Control:
			_insert_control_node_as_target_parent(target as Control)
		_target_base_positions.append(target.position)
		_target_start_positions.append(target.position + initial_element_offset)

	initialized = true
		
func reset() -> void:
	is_finished = false
	if !initialized:
		return

	_clear_tweens()

	for i: int in targets.size():
		if !is_instance_valid(targets[i]):
			push_warning("found invalid slide animation reference in ", self.name)
			return
		targets[i].position = _target_start_positions[i]
		
func animate() -> void:
	# Lazy init variant
	#if was_drawn && !initialized:
		#init_positions()
	
	if is_zero_approx(animation_dur):
		skip_to_finish()
		return
		
	_kill_current_tween()
	_current_tween = create_tween().set_parallel(true)
	
	for i: int in targets.size():
		_current_tween.tween_property(targets[i], "position", _target_base_positions[i], animation_dur)
	
	_anim_tweens.append(_current_tween)

func skip_to_finish() -> void:
	is_finished = true
	if !initialized:
		return
	
	_kill_current_tween()
		
	for i: int in targets.size():
		targets[i].position = _target_base_positions[i]

func is_valid() -> bool:
	return targets.size() > 0

func _insert_control_node_as_target_parent(target: Control) -> void:
	var node_to_insert: Control = Control.new()
	node_to_insert.name = target.name + "CP"
	node_to_insert.custom_minimum_size = target.size
	node_to_insert.anchor_bottom = target.anchor_bottom
	node_to_insert.anchor_left = target.anchor_left
	node_to_insert.anchor_right = target.anchor_right
	node_to_insert.anchor_top = target.anchor_top
	var child_index: int = target.get_index()
	target.get_parent().add_child(node_to_insert)
	target.get_parent().move_child(node_to_insert, child_index)
	node_to_insert.position = target.position

	target.reparent(node_to_insert)
	target.position = Vector2.ZERO

@warning_ignore_restore("unsafe_property_access")
