class_name SideWindowUI
extends CanvasLayer

signal preview_layout_settings_updated(rel_index: int, settings: PreviewLayoutSettings)

@export_category("internal nodes")
@export var slide_previews_by_rel_index: Dictionary[int, SlidePreview]
@export var preview_condensed_by_rel_index: Dictionary[int, PreviewCondensed]
@export var time_view: TimeView 
@export var edit_button: TextureButton

func _ready() -> void:
	for rel_preview_index: int in slide_previews_by_rel_index.keys():
		slide_previews_by_rel_index[rel_preview_index].close_requested.connect(set_preview_visible.bind(false, rel_preview_index, true, true))
		slide_previews_by_rel_index[rel_preview_index].preview_layout_settings_updated.connect(_on_preview_layout_settings_updated.bind(rel_preview_index))
		preview_condensed_by_rel_index[rel_preview_index].toggle_preview_visible.connect(set_preview_visible.bind(rel_preview_index, false, true))
		preview_condensed_by_rel_index[rel_preview_index].toggle_preview_on_top.connect(set_preview_on_top.bind(rel_preview_index, false, true))

	edit_button.button_pressed = false
	set_preview_layouts_locked(true)
	
func quit() -> void:
	if Util.is_web():
		push_warning("Just close the browser / tab to quit the presentation.")
		return
	get_tree().quit()

func set_preview_visible(is_visible_new: bool, rel_preview_index: int, update_condensed_button: bool = true, update_settings: bool = true) -> void:
	slide_previews_by_rel_index[rel_preview_index].visible = is_visible_new

	preview_condensed_by_rel_index[rel_preview_index].set_preview_visible(is_visible_new, update_condensed_button)
	
	if update_settings:
		slide_previews_by_rel_index[rel_preview_index].update_is_shown(is_visible_new)
	
func set_preview_on_top(is_on_top_new: bool, rel_preview_index: int, update_condensed_button: bool = true, update_settings: bool = true) -> void:
	var target_preview: SlidePreview = slide_previews_by_rel_index[rel_preview_index]
	target_preview.always_on_top = is_on_top_new
	
	if is_on_top_new:
		target_preview.grab_focus()
		
	if update_settings:
		target_preview.update_is_on_top(is_on_top_new)
	
	if update_condensed_button:
		preview_condensed_by_rel_index[rel_preview_index].set_preview_on_top(is_on_top_new, update_condensed_button)

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
		set_preview_visible(preview_layout_settings_by_rel_index[rel_preview_index].is_shown, rel_preview_index, true, false)
		set_preview_on_top(preview_layout_settings_by_rel_index[rel_preview_index].is_on_top, rel_preview_index, true, false)
			
func _on_preview_layout_settings_updated(rel_preview_index: int) -> void:
	preview_layout_settings_updated.emit(rel_preview_index, slide_previews_by_rel_index[rel_preview_index].preview_layout_settings)

func set_preview_layouts_locked(is_layout_locked: bool) -> void:
	for rel_preview_index: int in slide_previews_by_rel_index.keys():
		var slide_preview: SlidePreview = slide_previews_by_rel_index[rel_preview_index]
		slide_preview.unresizable = is_layout_locked
		slide_preview.unfocusable = is_layout_locked
		slide_preview.borderless = is_layout_locked
		preview_condensed_by_rel_index[rel_preview_index].set_buttons_visible(!is_layout_locked)

func _on_edit_button_toggled(toggled_on: bool) -> void:
	set_preview_layouts_locked(!toggled_on)
