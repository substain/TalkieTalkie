class_name SideWindowBase extends Node
## Handles creation and removal of the side window.

enum EnableOptions {
	ALWAYS,
	IF_SECOND_SCREEN_EXISTS,
	NEVER
}

const SIDE_WINDOW_SCENE: PackedScene = preload("res://engine/base/side_window.tscn")
@export_category("SideWindow Settings")
@export var enabled: EnableOptions = EnableOptions.IF_SECOND_SCREEN_EXISTS
@export var quit_on_close: bool = true
## if true, resizing the side window should keep the relative position of the embedded preview windows
@export var preview_window_resize_keep_rel_pos: bool = true
## if true, resizing the side window should also scale the embedded preview windows
@export var preview_window_resize_scale: bool = true

@export_category("Node References")
@export var presentation: Presentation
@export var ui: UI

var _side_window: SideWindow
var is_side_window_active: bool = false

func _enter_tree() -> void:
	if enabled == EnableOptions.ALWAYS || (enabled == EnableOptions.IF_SECOND_SCREEN_EXISTS && DisplayServer.get_screen_count() >= 2):
		set_side_window_active(true)

func set_side_window_active(is_active_new: bool) -> void:
	is_side_window_active = is_active_new
	
	if is_active_new:
		_side_window = SIDE_WINDOW_SCENE.instantiate() as SideWindow
		add_child(_side_window)
		_side_window.close_requested.connect(_on_close_requested)
		_side_window.input_received.connect(presentation._on_side_window_input_received)
		_side_window.set_preview_window_resize_keep_rel_pos(preview_window_resize_keep_rel_pos)
		_side_window.set_preview_window_resize_scale(preview_window_resize_scale)
		_side_window.set_as_ui_parent(true, ui)
	else:
		_close_side_window()
		
func _on_close_requested() -> void:
	if quit_on_close:
		get_tree().quit()
	else:
		_close_side_window()
	
func _close_side_window() -> void:
	_side_window.set_as_ui_parent(false, ui)
	_side_window.queue_free()
	_side_window = null
