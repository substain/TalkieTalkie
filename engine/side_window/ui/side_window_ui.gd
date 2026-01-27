class_name SideWindowUI
extends CanvasLayer

signal preview_layout_settings_updated(rel_index: int, settings: PreviewLayoutSettings)

@export_category("internal nodes")
@export var slide_previews_by_rel_index: Dictionary[int, SlidePreview]
@export var preview_condensed_by_rel_index: Dictionary[int, PreviewCondensed]
@export var time_view: TimeView 

func _ready() -> void:
	for rel_preview_index: int in slide_previews_by_rel_index.keys():
		slide_previews_by_rel_index[rel_preview_index].close_requested.connect(set_preview_visible.bind(rel_preview_index, false, true))
		slide_previews_by_rel_index[rel_preview_index].preview_layout_settings_updated.connect(_on_preview_layout_settings_updated.bind(rel_preview_index))
		
func quit() -> void:
	if Util.is_web():
		push_warning("Just close the browser / tab to quit the presentation.")
		return
	get_tree().quit()

func set_preview_visible(rel_preview_index: int, is_visible_new: bool, update_condensed_button: bool) -> void:
	preview_condensed_by_rel_index[rel_preview_index].set_preview_visible(is_visible_new, update_condensed_button)
	slide_previews_by_rel_index[rel_preview_index].set_shown(is_visible_new, false)

func on_resize(new_window_size: Vector2) -> void:
	for slide_preview: SlidePreview in slide_previews_by_rel_index.values():
		slide_preview.on_resize_parent_window(new_window_size)

func set_preview_theme_settings(preview_theme_settings: PreviewThemeSettings) -> void:
	await ready
	for slide_preview: SlidePreview in slide_previews_by_rel_index.values():
		slide_preview.set_preview_theme_settings(preview_theme_settings)


func load_side_window_layout_settings(preview_layout_settings_by_rel_index: Dictionary[int, PreviewLayoutSettings]) -> void:
	for rel_preview_index: int in slide_previews_by_rel_index.keys():
		slide_previews_by_rel_index[rel_preview_index].load_settings(preview_layout_settings_by_rel_index[rel_preview_index])

func _on_preview_layout_settings_updated(rel_preview_index: int) -> void:
	preview_layout_settings_updated.emit(rel_preview_index, slide_previews_by_rel_index[rel_preview_index].preview_layout_settings)
