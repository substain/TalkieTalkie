class_name SlideLink extends RichTextLabel

@export var enable_links: bool = true

func _on_meta_clicked(meta: Variant) -> void:
	if !enable_links:
		return
	var meta_num: int = (meta as int)
	if meta_num >= 0:
		TTSlideHelper.presentation._on_ui_jump_to_slide(meta_num)
		get_viewport().set_input_as_handled()
