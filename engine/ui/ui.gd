class_name UI extends CanvasLayer

signal continue_slide
signal previous_slide
signal skip_slide
signal jump_to_slide(slide_index: int)
signal toggle_slideshow(slideshow_active: bool)
signal set_slideshow_duration(new_duration: float)

const VISIBILTY_TWEEN_DURATION: float = 0.2

## if true, the ui will be visible on start
@export var is_ui_visible: bool = false

## disables the control bar in the ui view
@export var control_bar_enabled: bool = true

## disables the tab navigation bar in the ui view
@export var tab_navigation_bar_enabled: bool = true

## disables settings in the ui view
@export var settings_enabled: bool = true

@export_category("internal nodes")
@export var control_bar: ControlBar
@export var control_bar_pivot: Control
@export var control_bar_hidden_pos_marker: Marker2D

@export var tab_navigation_bar: TabNavigationBar
@export var tab_navigation_pivot: Control
@export var tab_navigation_bar_hidden_marker: Marker2D

@export var settings: Settings
@export var settings_pivot: Control
@export var settings_hidden_marker: Marker2D

var visibility_tween: Tween = null

var control_bar_visible_pos: Vector2
var control_bar_hidden_pos: Vector2

var tab_navigation_bar_visible_pos: Vector2
var tab_navigation_bar_hidden_pos: Vector2

var settings_visible_pos: Vector2
var settings_hidden_pos: Vector2

func _ready() -> void:
	control_bar_visible_pos = control_bar_pivot.global_position
	control_bar_hidden_pos = control_bar_hidden_pos_marker.global_position
	tab_navigation_bar_visible_pos = tab_navigation_pivot.global_position
	tab_navigation_bar_hidden_pos = tab_navigation_bar_hidden_marker.global_position
	settings_visible_pos = settings_pivot.global_position
	settings_hidden_pos = settings_hidden_marker.global_position
	
	control_bar.visible = control_bar_enabled
	tab_navigation_bar.visible = tab_navigation_bar_enabled
	settings.visible = settings_enabled
	
	set_ui_visible(is_ui_visible, true)

func set_ui_disabled(is_disabled_new: bool) -> void:	
	tab_navigation_bar.set_ui_disabled(is_disabled_new)
	control_bar.set_ui_disabled(is_disabled_new)

func toggle_ui_visible() -> void:
	set_ui_visible(!is_ui_visible)
		
func set_ui_visible(visible_new: bool, force_set: bool = false) -> void:
	if visible_new == is_ui_visible && !force_set:
		return
	
	if is_instance_valid(visibility_tween):
		visibility_tween.kill()
	
	var modulate_start: float = 0.0 if visible_new else 1.0
	var modulate_target: float = 1.0 if visible_new else 0.0
	
	control_bar.modulate.a = modulate_start
	var control_bar_target_pos: Vector2 = control_bar_visible_pos if visible_new else control_bar_hidden_pos
	control_bar_pivot.global_position = control_bar_hidden_pos if visible_new else control_bar_visible_pos
	
	tab_navigation_bar.modulate.a = modulate_start
	var tab_navigation_bar_target_pos: Vector2 = tab_navigation_bar_visible_pos if visible_new else tab_navigation_bar_hidden_pos
	tab_navigation_pivot.global_position = tab_navigation_bar_hidden_pos if visible_new else tab_navigation_bar_visible_pos
	
	settings.modulate.a = modulate_start
	var settings_target_pos: Vector2 = settings_visible_pos if visible_new else settings_hidden_pos
	settings_pivot.global_position = settings_hidden_pos if visible_new else settings_visible_pos
	
	visibility_tween = create_tween().set_parallel(true)
	visibility_tween.tween_property(control_bar, "modulate:a", modulate_target, VISIBILTY_TWEEN_DURATION)
	visibility_tween.tween_property(control_bar_pivot, "global_position", control_bar_target_pos, VISIBILTY_TWEEN_DURATION)
	
	visibility_tween.tween_property(tab_navigation_bar, "modulate:a", modulate_target, VISIBILTY_TWEEN_DURATION)
	visibility_tween.tween_property(tab_navigation_pivot, "global_position", tab_navigation_bar_target_pos, VISIBILTY_TWEEN_DURATION)
	
	visibility_tween.tween_property(settings, "modulate:a", modulate_target, VISIBILTY_TWEEN_DURATION)
	visibility_tween.tween_property(settings_pivot, "global_position", settings_target_pos, VISIBILTY_TWEEN_DURATION)
	
	is_ui_visible = visible_new

func quit() -> void:
	if OS.has_feature("web"):
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
		
