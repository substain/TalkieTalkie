class_name PreviewLayoutSettings extends RefCounted

var is_shown: bool
var size: Vector2i
var position: Vector2i


func init2(is_shown_new: bool, size_new: Vector2i, position_new: Vector2i) -> void:
	is_shown = is_shown_new
	size = size_new
	position = position_new

static func load_default(relative_index: int) -> PreviewLayoutSettings:
	var used_size: Vector2i
	var used_position: Vector2i
	match relative_index:
		SlidePreview.REL_INDEX_PREVIOUS:
			used_size = Vector2i(240, 135)
			used_position = Vector2i(0, 227)
		SlidePreview.REL_INDEX_NEXT:
			used_size = Vector2i(240, 135)
			used_position = Vector2i(560, 227)
		SlidePreview.REL_INDEX_CURRENT:
			used_size = Vector2i(320, 180)
			used_position = Vector2i(240, 210)
		_:
			push_warning("No default settings defined for relative index '", relative_index, "'.")
			used_size = Vector2i(320, 180)
			used_position = Vector2i(240, 210)

	var res: PreviewLayoutSettings = PreviewLayoutSettings.new()
	res.is_shown = true
	res.size = used_size
	res.position = used_position
	
	return res
