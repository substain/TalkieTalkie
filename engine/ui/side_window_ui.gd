class_name SideWindowUI
extends CanvasLayer
	
signal continue_slide
signal previous_slide
signal skip_slide
signal jump_to_slide(slide_index: int)
signal toggle_slideshow(slideshow_active: bool)
signal set_slideshow_duration(new_duration: float)

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

	
func quit() -> void:
	if Util.is_web():
		push_warning("Just close the browser / tab to quit the presentation.")
		return
	get_tree().quit()
	
