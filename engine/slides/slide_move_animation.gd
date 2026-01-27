class_name SlideMoveAnimation extends SlideAnimation
## Implements move animations for slide elements.

@export var initial_element_offset: Vector2

var _target_base_positions: Array[Vector2] = []
var _target_start_positions: Array[Vector2] = []

var initialized: bool = false
var is_finished: bool = false

var was_drawn: bool = false

var ci_targets: Array[CanvasItem] = []

func _ready() -> void:
	super()
	
	for target: Node in targets:
		if target is CanvasItem:
			ci_targets.append(target)
			_target_base_positions.append(ci_get_position(target as CanvasItem))
		else:
			push_warning("SlideMoveAnimation expects CanvasItem targets. Ignoring '", target.name, "'.")
			
	if ci_targets.is_empty():
		return

	#await ci_targets[0].draw
	await get_tree().process_frame
	was_drawn = true
	init_positions()

	if !is_finished:
		reset()
	else:
		skip_to_finish()

func init_positions() -> void:
	
	for target: CanvasItem in ci_targets:
		if target.get_parent() is Container && target is Control:
			_insert_control_node_as_target_parent(target as Control)
		_target_start_positions.append(ci_get_position(target) + initial_element_offset)

	initialized = true
		
func reset() -> void:
	is_finished = false
	if !initialized:
		return

	_clear_tweens()
	
	for i: int in ci_targets.size():
		if !is_instance_valid(ci_targets[i]):
			push_warning("found invalid slide animation reference in ", self.name)
			return
		ci_set_position(ci_targets[i], _target_start_positions[i])
		
func animate() -> void:
	if is_zero_approx(animation_dur):
		skip_to_finish()
		return
		
	_kill_current_tween()
	_current_tween = create_tween().set_parallel(true)
	
	for i: int in ci_targets.size():
		_current_tween.tween_property(ci_targets[i], "position", _target_base_positions[i], animation_dur)
	
	_anim_tweens.append(_current_tween)

func skip_to_finish() -> void:
	is_finished = true
	_kill_current_tween()
		
	for i: int in ci_targets.size():
		ci_set_position(ci_targets[i], _target_base_positions[i])

func is_valid() -> bool:
	return ci_targets.size() > 0

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

# ignore warnings for these property accesses since we know they are valid
@warning_ignore_start("unsafe_property_access")
func ci_set_position(target: CanvasItem, new_pos: Vector2) -> void:
	target.position = new_pos

func ci_get_position(target: CanvasItem) -> Vector2:
	return target.position
@warning_ignore_restore("unsafe_property_access")
