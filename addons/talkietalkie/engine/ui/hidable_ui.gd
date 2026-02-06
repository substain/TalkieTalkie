class_name HidableUI extends Control

const _VISIBILTY_TWEEN_DURATION: float = 0.2

var _visibility_tween: Tween = null
var _is_visible_ui: bool = false
var _base_pos: Vector2
var _hidden_pos: Vector2

func _ready() -> void:
	_base_pos = position
	update_positions()
	
func update_positions() -> void:
	var local_hidden_dir: Vector2 = get_direction_from_anchors(anchor_top, anchor_bottom, anchor_left, anchor_right)
	_hidden_pos = _base_pos + (local_hidden_dir * 100)
	
func set_visible_tween(is_visible_ui_new: bool, force_set: bool = false) -> void:
	if is_visible_ui_new == _is_visible_ui && !force_set:
		return	

	var modulate_start: float = 0.0 if is_visible_ui_new else 1.0
	var modulate_target: float = 1.0 - modulate_start
	var start_pos: Vector2 = position
	var target_pos: Vector2 = _base_pos if is_visible_ui_new else _hidden_pos
	
	if _visibility_tween:
		_visibility_tween.kill()
	
	_visibility_tween = create_tween()
			
	tween_ui_element(_visibility_tween, self, start_pos, target_pos, modulate_start, modulate_target)
	_is_visible_ui = is_visible_ui_new

static func tween_ui_element(ui_tween: Tween, target_control: Control, start_pos: Vector2, target_pos: Vector2, modulate_start: float, modulate_target: float) -> void:
	ui_tween.set_parallel(true)
	target_control.position = start_pos
	target_control.modulate.a = modulate_start
	ui_tween.tween_property(target_control, "modulate:a", modulate_target, _VISIBILTY_TWEEN_DURATION)
	ui_tween.tween_property(target_control, "position", target_pos, _VISIBILTY_TWEEN_DURATION)

static func get_direction_from_anchors(an_top: float, an_bot: float, an_left: float, an_right: float) -> Vector2:
	var lr_pos: float = (an_left + an_right)/2 - 0.5
	var bt_pos: float = (an_bot + an_top)/2 - 0.5
	
	if is_zero_approx(lr_pos) && is_zero_approx(bt_pos):
		return Vector2.ZERO
	
	if abs(lr_pos) > abs(bt_pos):
		#use side directions only if anchors for left/right are greater than up/down
		if lr_pos < 0:
			return Vector2.LEFT
		return Vector2.RIGHT
	
	if bt_pos < 0:
		return Vector2.UP
	return Vector2.DOWN
