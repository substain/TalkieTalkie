class_name ControlBar extends Control

signal continue_pressed
signal back_pressed
signal skip_pressed
signal quit_pressed
signal slideshow_toggled(toggled_on: bool)
signal slideshow_duration_changed(new_duration: float)

@export var back_button: BaseButton
@export var continue_button: BaseButton
@export var skip_button: BaseButton
@export var fullscreen_button: BaseButton
@export var quit_button: BaseButton
@export var slideshow_button: BaseButton
@export var slideshow_duration_spin_box: SpinBox

var fullscreen_active: bool

var is_first_slide: bool = false
var is_last_slide: bool = false
var is_slide_finished: bool = false
var is_slide_at_start: bool = true
var is_slideshow_active: bool = false
var slideshow_duration: float

func _ready() -> void:
	quit_button.visible = !OS.has_feature("web")
	set_fullscreen_active(Preferences.fullscreen_active)

func set_ui_disabled(is_disabled_new: bool) -> void:
	slideshow_button.disabled = is_disabled_new
	if is_disabled_new:
		set_slide_status_flags(true, true)
		set_slide_progress_flags(true, true)
		
func set_fullscreen_active(is_active_new: bool) -> void:
	fullscreen_active = is_active_new
	PreferencesClass.set_fullscreen(is_active_new)
	Preferences.set_fullscreen_active(is_active_new, true)
	fullscreen_button.set_pressed_no_signal(fullscreen_active)
	
func toggle_fullscreen() -> void:
	set_fullscreen_active(!fullscreen_active)
	
func _on_continue_button_pressed() -> void:
	continue_pressed.emit()
	
func _on_back_button_pressed() -> void:
	back_pressed.emit()

func _on_skip_button_pressed() -> void:
	skip_pressed.emit()

func _on_quit_button_pressed() -> void:
	quit_pressed.emit()

func _on_fullscreen_button_toggled(toggled_on: bool) -> void:
	set_fullscreen_active(toggled_on)
	
func _on_slideshow_button_toggled(toggled_on: bool) -> void:
	slideshow_toggled.emit(toggled_on)
	
func _on_slideshow_duration_spin_box_value_changed(value: float) -> void:
	slideshow_duration_changed.emit(value)

func set_slide_progress_flags(is_slide_at_start_new: bool, is_slide_finished_new: bool) -> void:
	is_slide_finished = is_slide_finished_new
	is_slide_at_start = is_slide_at_start_new
	update_navigation_buttons()

func set_slide_status_flags(is_first_slide_new: bool, is_last_slide_new: bool) -> void:
	is_first_slide = is_first_slide_new
	is_last_slide = is_last_slide_new
	update_navigation_buttons()
	
func update_navigation_buttons() -> void:
	back_button.disabled = is_first_slide && is_slide_at_start
	continue_button.disabled = is_last_slide && is_slide_finished
	skip_button.disabled = is_last_slide && is_slide_finished
	slideshow_button.disabled = is_last_slide && is_slide_finished
	
func set_slideshow_active(is_slideshow_active_new: bool) -> void:
	is_slideshow_active = is_slideshow_active_new
	slideshow_button.set_pressed_no_signal(is_slideshow_active_new)
	
func update_slideshow_duration(slideshow_duration_new: float) -> void:
	slideshow_duration = slideshow_duration_new
	slideshow_duration_spin_box.set_value_no_signal(slideshow_duration_new)
