class_name UI extends CanvasLayer

signal continue_slide
signal previous_slide
signal skip_slide
signal jump_to_slide(slide_index: int)
signal toggle_slideshow(slideshow_active: bool)
signal set_slideshow_duration(new_duration: float)

@export_category("internal nodes")
@export var control_bar: ControlBar
@export var tab_navigation_bar: TabNavigationBar
@export var settings: Settings
@export var _toggle_ui_button: Button

@export var about_overlay: AboutOverlay

@export var hidable_nodes: Array[HidableUI]

## nodes that may be part of the sidewindow, when it is in use
@export var side_window_nodes: Array[Node]

var has_overlay: bool = false
var is_ui_visible: bool = false

func _ready() -> void:
	TTSlideHelper.ui = self
	
	control_bar.visible = TTPreferences.tt_config.enable_control_bar
	tab_navigation_bar.visible = TTPreferences.tt_config.enable_tabnav_bar
	settings.visible = TTPreferences.tt_config.enable_settings
	
	settings.update_ui_button_position(!TTPreferences.tt_config.get_show_toggle_ui_button_bool(), _toggle_ui_button)
	
	set_ui_visible(TTPreferences.tt_config.get_open_ui_on_startup_bool(), true)
	set_about_overlay_visible(false)

func set_ui_disabled(is_disabled_new: bool) -> void:	
	tab_navigation_bar.set_ui_disabled(is_disabled_new)
	control_bar.set_ui_disabled(is_disabled_new)

func toggle_ui_visible() -> void:
	set_ui_visible(!is_ui_visible)
		
func set_ui_visible(visible_new: bool, force_set: bool = false) -> void:
	if visible_new == is_ui_visible && !force_set:
		return
		
	_toggle_ui_button.set_pressed_no_signal(visible_new)
	
	for hnode: HidableUI in hidable_nodes:
		hnode.set_visible_tween(visible_new, force_set)
		
	is_ui_visible = visible_new
	

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

func set_auto_slideshow_active(is_slideshow_active_new: bool) -> void:
	control_bar.set_auto_slideshow_active(is_slideshow_active_new)

func _on_show_ui_button_toggled(toggled_on: bool) -> void:
	set_ui_visible(toggled_on)

func _on_settings_show_about_window() -> void:
	set_about_overlay_visible(true)

func _on_about_overlay_close_overlay() -> void:
	set_about_overlay_visible(false)
	
func set_about_overlay_visible(is_visible_new: bool) -> void:
	about_overlay.visible = is_visible_new
	has_overlay = is_visible_new
