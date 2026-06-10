class_name SideWindowLayoutSettings extends RefCounted

var screen_index: int
var side_window_pos: Vector2i
var side_window_size: Vector2i

var preview_layout_settings_by_rel_index: Dictionary[int, TalkiePreviewLayoutSettings]

func _init() -> void:
	_init_default_preview_layout_settings()

func _init_default_preview_layout_settings() -> void:
	preview_layout_settings_by_rel_index = {}
	preview_layout_settings_by_rel_index[TalkieSlidePreview.REL_INDEX_PREVIOUS] = TalkiePreviewLayoutSettings.load_default(TalkieSlidePreview.REL_INDEX_PREVIOUS)
	preview_layout_settings_by_rel_index[TalkieSlidePreview.REL_INDEX_CURRENT] = TalkiePreviewLayoutSettings.load_default(TalkieSlidePreview.REL_INDEX_CURRENT)
	preview_layout_settings_by_rel_index[TalkieSlidePreview.REL_INDEX_NEXT] = TalkiePreviewLayoutSettings.load_default(TalkieSlidePreview.REL_INDEX_NEXT)
