class_name UI extends CanvasLayer

signal continue_slide
signal previous_slide
signal skip_slide
signal jump_to_slide(slide_index: int)
signal toggle_slideshow(slideshow_active: bool)
signal set_slideshow_duration(new_duration: float)

const _VISIBILTY_TWEEN_DURATION: float = 0.2

## if true, the ui will be visible on start
@export var is_ui_visible: bool = false

## always show a button to toggle the ui for non-mobile presentations
@export var _always_show_toggle_ui_button: bool = false

## always show a button to toggle the ui on mobile devices. 
@export var _always_show_toggle_ui_button_on_mobile: bool = true

## disables the control bar in the ui view
@export var control_bar_enabled: bool = true

## disables the tab navigation bar in the ui view
@export var tab_navigation_bar_enabled: bool = true

## disables settings in the ui view
@export var settings_enabled: bool = true

@export_category("internal nodes")
@export var control_bar: ControlBar
@export var _control_bar_pivot: Control
@export var _control_bar_hidden_pos_marker: Marker2D

@export var tab_navigation_bar: TabNavigationBar
@export var _tab_navigation_pivot: Control
@export var _tab_navigation_bar_hidden_marker: Marker2D

@export var settings: Settings
@export var _settings_pivot: Control
@export var _settings_hidden_marker: Marker2D
@export var _toggle_ui_button: Button

@export var about_overlay: AboutOverlay

var _visibility_tween: Tween = null

var _control_bar_visible_pos: Vector2
var _control_bar_hidden_pos: Vector2

var _tab_navigation_bar_visible_pos: Vector2
var _tab_navigation_bar_hidden_pos: Vector2

var _settings_visible_pos: Vector2
var _settings_hidden_pos: Vector2

var has_overlay: bool = false

func _ready() -> void:
	setup_mobile()
	
	_control_bar_visible_pos = _control_bar_pivot.global_position
	_control_bar_hidden_pos = _control_bar_hidden_pos_marker.global_position
	_tab_navigation_bar_visible_pos = _tab_navigation_pivot.global_position
	_tab_navigation_bar_hidden_pos = _tab_navigation_bar_hidden_marker.global_position
	_settings_visible_pos = _settings_pivot.global_position
	_settings_hidden_pos = _settings_hidden_marker.global_position
	
	control_bar.visible = control_bar_enabled
	tab_navigation_bar.visible = tab_navigation_bar_enabled
	settings.visible = settings_enabled
	
	settings.update_ui_button_position(!_always_show_toggle_ui_button, _toggle_ui_button)

	set_ui_visible(is_ui_visible, true)
	set_about_overlay_visible(false)
	
func setup_mobile() -> void:
	if Util.is_mobile():
		_always_show_toggle_ui_button = _always_show_toggle_ui_button_on_mobile
		
func set_ui_disabled(is_disabled_new: bool) -> void:	
	tab_navigation_bar.set_ui_disabled(is_disabled_new)
	control_bar.set_ui_disabled(is_disabled_new)

func toggle_ui_visible() -> void:
	set_ui_visible(!is_ui_visible)
		
func set_ui_visible(visible_new: bool, force_set: bool = false) -> void:
	if visible_new == is_ui_visible && !force_set:
		return
	_toggle_ui_button.set_pressed_no_signal(visible_new)

	var modulate_start: float = 0.0 if visible_new else 1.0
	var modulate_target: float = 1.0 if visible_new else 0.0

	var control_bar_start_pos: Vector2 = _control_bar_hidden_pos if visible_new else _control_bar_visible_pos 
	var control_bar_target_pos: Vector2 = _control_bar_visible_pos if visible_new else _control_bar_hidden_pos
	
	var tab_navigation_bar_start_pos: Vector2 = _tab_navigation_bar_hidden_pos if visible_new else _tab_navigation_bar_visible_pos 
	var tab_navigation_bar_target_pos: Vector2 = _tab_navigation_bar_visible_pos if visible_new else _tab_navigation_bar_hidden_pos
	
	var settings_start_pos: Vector2 = _settings_hidden_pos if visible_new else _settings_visible_pos 
	var settings_target_pos: Vector2 = _settings_visible_pos if visible_new else _settings_hidden_pos
	
	if is_instance_valid(_visibility_tween):
		_visibility_tween.kill()
	_visibility_tween = create_tween().set_parallel(true)
	
	tween_ui_element(_visibility_tween, control_bar, _control_bar_pivot, control_bar_start_pos, control_bar_target_pos, modulate_start, modulate_target)
	tween_ui_element(_visibility_tween, tab_navigation_bar, _tab_navigation_pivot, tab_navigation_bar_start_pos, tab_navigation_bar_target_pos, modulate_start, modulate_target)
	tween_ui_element(_visibility_tween, settings, _settings_pivot, settings_start_pos, settings_target_pos, modulate_start, modulate_target)
	
	is_ui_visible = visible_new

func tween_ui_element(ui_tween: Tween, target_control: Control, pivot_node: Control, start_pos: Vector2, target_pos: Vector2, modulate_start: float, modulate_target: float) -> void:
	pivot_node.global_position = start_pos
	target_control.modulate.a = modulate_start
	ui_tween.tween_property(target_control, "modulate:a", modulate_target, _VISIBILTY_TWEEN_DURATION)
	ui_tween.tween_property(pivot_node, "global_position", target_pos, _VISIBILTY_TWEEN_DURATION)
	
func quit() -> void:
	if Util.is_web():
		push_warning("Just close the browser / tab to quit the presentation.")
		return
	get_tree().quit()
	
func set_available_slides(slides: Array[Slide]) -> void:
	tab_navigation_bar.set_available_slides(slides)
	
func set_current_slide(slide_index: int) -> void:
	tab_navigation_bar.set_current_slide(slide_index)
	
func _on_tab_navigation_bar_jump_to_slide(slide_index: int) -> void:
	jump_to_slide.emit(slide_index)
	
func _on_control_bar_back_pressed() -> void:
	previous_slide.emit()

func _on_control_bar_continue_pressed() -> void:
	continue_slide.emit()

func _on_control_bar_quit_pressed() -> void:
	quit()

func _on_control_bar_skip_pressed() -> void:
	skip_slide.emit()

func _on_control_bar_slideshow_duration_changed(new_duration: float) -> void:
	set_slideshow_duration.emit(new_duration)

func _on_control_bar_slideshow_toggled(toggled_on: bool) -> void:
	toggle_slideshow.emit(toggled_on)

func set_slideshow_active(is_slideshow_active_new: bool) -> void:
	control_bar.set_slideshow_active(is_slideshow_active_new)

func _on_show_ui_button_toggled(toggled_on: bool) -> void:
	set_ui_visible(toggled_on)

func _on_settings_show_about_window() -> void:
	set_about_overlay_visible(true)

func _on_about_overlay_close_overlay() -> void:
	set_about_overlay_visible(false)
	
func set_about_overlay_visible(is_visible_new: bool) -> void:
	about_overlay.visible = is_visible_new
	has_overlay = is_visible_new
