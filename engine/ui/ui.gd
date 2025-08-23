class_name UI extends CanvasLayer

signal continue_slide
signal previous_slide
signal skip_slide
signal jump_to_slide(slide_index: int)
signal toggle_slideshow(slideshow_active: bool)
signal set_slideshow_duration(new_duration: float)

const VISIBILTY_TWEEN_DURATION: float = 0.2
const SIMPLE_SLIDE_NAV_BUTTON: PackedScene = preload("res://engine/ui/simple_slide_nav_button.tscn")

## if true, the ui will be visible on start
@export var is_ui_visible: bool

@export_category("internal nodes")
@export var navigation_bar: Control
@export var navigation_bar_hidden_pos_marker: Marker2D

@export var back_button: Button
@export var continue_button: Button
@export var skip_button: Button
@export var fullscreen_button: Button
@export var quit_button: Button
@export var slideshow_button: Button
@export var slideshow_duration_spin_box: SpinBox

@export var simple_slide_content_nav: MarginContainer
@export var slide_content_nav_hidden_marker: Marker2D

@export var slide_button_hbox: HBoxContainer
@export var slide_index_label: Label

var num_slides: int = 0
var is_first_slide: bool = false
var is_last_slide: bool = false
var is_slide_finished: bool = false
var is_slideshow_active: bool = false
var slideshow_duration: float
var current_slide_index: int = 0
var fullscreen_active: bool
var visibility_tween: Tween = null

var navigation_bar_hidden_pos: Vector2
var navigation_bar_visible_pos: Vector2

var simple_nav_visible_pos: Vector2
var simple_nav_hidden_pos: Vector2

var slide_nav_dictionary: Dictionary[int, Button] = {} # slide-index -> SimpleSlideNavButton

func _ready() -> void:
	quit_button.visible = !OS.has_feature("web")
	navigation_bar_visible_pos = navigation_bar.global_position
	navigation_bar_hidden_pos = navigation_bar_hidden_pos_marker.global_position
	simple_nav_visible_pos = simple_slide_content_nav.global_position
	simple_nav_hidden_pos = slide_content_nav_hidden_marker.global_position

	set_fullscreen_active(Preferences.fullscreen_active)
	#overall_volume_slider.set_value_no_signal(Preferences.overall_volume)
	#music_volume_slider.set_value_no_signal(Preferences.music_volume)
	#sfx_volume_slider.set_value_no_signal(Preferences.sfx_volume)
	set_ui_visible(is_ui_visible, true)

func set_ui_disabled(is_disabled_new: bool) -> void:
	if is_disabled_new:
		set_slide_status_flags(true, true)
		set_is_slide_finished(true)
		
	slide_index_label.text = "no slides"
	slideshow_button.disabled = is_disabled_new

func toggle_ui_visible() -> void:
	set_ui_visible(!is_ui_visible)
		
func set_ui_visible(visible_new: bool, force_set: bool = false) -> void:
	if visible_new == is_ui_visible && !force_set:
		return
	
	if is_instance_valid(visibility_tween):
		visibility_tween.kill()
	
	var modulate_start: float = 0.0 if visible_new else 1.0
	var modulate_target: float = 1.0 if visible_new else 0.0
	
	navigation_bar.modulate.a = modulate_start
	var navigation_bar_target_pos: Vector2 = navigation_bar_visible_pos if visible_new else navigation_bar_hidden_pos
	navigation_bar.global_position = navigation_bar_hidden_pos if visible_new else navigation_bar_visible_pos
	
	simple_slide_content_nav.modulate.a = modulate_start
	var simple_slide_content_nav_target_pos: Vector2 = simple_nav_visible_pos if visible_new else simple_nav_hidden_pos
	simple_slide_content_nav.global_position = simple_nav_hidden_pos if visible_new else simple_nav_visible_pos
	
	visibility_tween = create_tween().set_parallel(true)
	visibility_tween.tween_property(navigation_bar, "modulate:a", modulate_target, VISIBILTY_TWEEN_DURATION)
	visibility_tween.tween_property(navigation_bar, "global_position", navigation_bar_target_pos, VISIBILTY_TWEEN_DURATION)
	
	visibility_tween.tween_property(simple_slide_content_nav, "modulate:a", modulate_target, VISIBILTY_TWEEN_DURATION)
	visibility_tween.tween_property(simple_slide_content_nav, "global_position", simple_slide_content_nav_target_pos, VISIBILTY_TWEEN_DURATION)
	
	is_ui_visible = visible_new

func skip_pressed() -> void:
	skip_slide.emit()

func _on_back_button_pressed() -> void:
	previous_slide.emit()

func _on_continue_button_pressed() -> void:
	continue_slide.emit()

func _on_skip_button_pressed() -> void:
	skip_slide.emit()

func set_is_slide_finished(is_slide_finished_new: bool) -> void:
	is_slide_finished = is_slide_finished_new
	update_navigation_buttons()

func set_slide_status_flags(is_first_slide_new: bool, is_last_slide_new: bool) -> void:
	is_first_slide = is_first_slide_new
	is_last_slide = is_last_slide_new
	update_navigation_buttons()
	
func update_navigation_buttons() -> void:
	back_button.disabled = is_first_slide
	continue_button.disabled = is_last_slide && is_slide_finished
	skip_button.disabled = is_last_slide && is_slide_finished
	slideshow_button.disabled = is_last_slide && is_slide_finished
	
func set_slideshow_active(is_slideshow_active_new: bool) -> void:
	is_slideshow_active = is_slideshow_active_new
	slideshow_button.set_pressed_no_signal(is_slideshow_active_new)
	
func update_slideshow_duration(slideshow_duration_new: float) -> void:
	slideshow_duration = slideshow_duration_new
	slideshow_duration_spin_box.set_value_no_signal(slideshow_duration_new)

func _on_slideshow_button_toggled(toggled_on: bool) -> void:
	toggle_slideshow.emit(toggled_on)
	
func _on_slideshow_duration_spin_box_value_changed(value: float) -> void:
	set_slideshow_duration.emit(value)
	
func toggle_fullscreen() -> void:
	set_fullscreen_active(!fullscreen_active)

func _on_fullscreen_button_toggled(toggled_on: bool) -> void:
	set_fullscreen_active(toggled_on)
	
func set_fullscreen_active(is_active_new: bool) -> void:
	fullscreen_active = is_active_new
	PreferencesClass.set_fullscreen(is_active_new)
	Preferences.set_fullscreen_active(is_active_new, true)
	fullscreen_button.set_pressed_no_signal(fullscreen_active)

func _on_quit_button_pressed() -> void:
	quit()
	
func quit() -> void:
	if OS.has_feature("web"):
		push_warning("Just close the browser / tab to quit the presentation.")
		return
	get_tree().quit()

func set_available_slides(slides: Array[Slide]) -> void:
	
	var simple_slide_buttons: Array[Button] = []
	
	num_slides = slides.size()
	
	for slide: Slide in slides:
		var target_slide_index: int = slide.order_index
		var slide_nav_button: Button = SIMPLE_SLIDE_NAV_BUTTON.instantiate()
		slide_nav_button.pressed.connect(_slide_nav_button_pressed.bind(target_slide_index))
		simple_slide_buttons.append(slide_nav_button)
		slide_nav_dictionary[target_slide_index] = slide_nav_button
		slide_button_hbox.add_child(slide_nav_button)
		slide_button_hbox.move_child(slide_nav_button, target_slide_index)
	
	update_slide_index_label()
	
func set_current_slide(slide_index: int) -> void:
	current_slide_index = slide_index
	if !slide_nav_dictionary[slide_index].button_pressed:
		slide_nav_dictionary[slide_index].button_pressed = true
	slide_nav_dictionary[slide_index].get("theme_override_styles/normal").bg_color = Color.html("647a64dc")

	update_slide_index_label()
	
func update_slide_index_label() -> void:
	slide_index_label.text = str(current_slide_index+1) + " / " + str(num_slides)
	
func _slide_nav_button_pressed(slide_index: int) -> void:
	jump_to_slide.emit(slide_index)

## TODO
func update_progress() -> void:
	pass
	
## TODO: locale settings
#switch_locale button

## TODO: audio settings
#func on_update_overall_slider(value_new: float) -> void:
	#Preferences.set_bus_volume(Preferences.AudioType.MASTER, value_new)
	#Preferences.set_overall_volume(value_new, false)
	#
#func on_update_music_slider(value_new: float) -> void:
	#Preferences.set_bus_volume(Preferences.AudioType.MUSIC, value_new)
	#Preferences.set_music_volume(value_new, false)
#
#func on_update_sfx_slider(value_new: float) -> void:
	#Preferences.set_bus_volume(Preferences.AudioType.SFX, value_new)
	#Preferences.set_sfx_volume(value_new, false)
	#if block_sfx_update:
		#return
		#
	#block_sfx_update = true
	#hint_current_sfx();
	#await get_tree().create_timer(0.15).timeout
	#block_sfx_update = false
