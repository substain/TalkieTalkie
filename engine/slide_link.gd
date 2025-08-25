class_name SlideLink extends RichTextLabel

@export var enable_links: bool = true

func _on_meta_clicked(meta: Variant) -> void:
	if !enable_links:
		return
	if int(meta) >= 0:
		SlideHelper.main._on_ui_jump_to_slide(int(meta))
		get_viewport().set_input_as_handled()
