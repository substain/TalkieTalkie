class_name SideWindowUI
extends CanvasLayer
	
@export var prev_slide_panel: SlidePreview
@export var current_slide_panel: SlidePreview
@export var next_slide_panel: SlidePreview

var slide_previews: Array[SlidePreview]

func _ready() -> void:
	slide_previews = [prev_slide_panel, current_slide_panel, next_slide_panel]
	
func quit() -> void:
	if Util.is_web():
		push_warning("Just close the browser / tab to quit the presentation.")
		return
	get_tree().quit()
	
func on_resize(new_window_size: Vector2) -> void:
	for slide_preview: SlidePreview in slide_previews:
		slide_preview.on_resize_parent_window(new_window_size)

func set_preview_window_resize_keep_rel_pos(keep_rel_pos_new: bool) -> void:
	for slide_preview: SlidePreview in slide_previews:
		slide_preview.set_preview_window_resize_keep_rel_pos(keep_rel_pos_new)
		
func set_preview_window_resize_scale(do_scale_new: bool) -> void:
	for slide_preview: SlidePreview in slide_previews:
		slide_preview.set_preview_window_resize_scale(do_scale_new)
		
