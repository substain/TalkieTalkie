class_name CommentsView
extends Control

## specifies the target slide for this component, relative to the current visible slide in the presentation
@export var offset_from_current_slide: int = 0
@export var comments_title: String
## if true, links in the comments are clickable
@export var enable_outgoing_links: bool = false
@export_category("internal nodes")
@export var title_label: Label
@export var comments_rtl: RichTextLabel

func _ready() -> void:
	SlideHelper.slide_changed.connect(_on_slide_changed)
	title_label.text = tr(comments_title)
	comments_rtl.text = ""
	
func _on_slide_changed(new_slide: Slide) -> void:
	var slide_index: int = new_slide.get_order_index() + offset_from_current_slide
	if slide_index < 0 || slide_index >= SlideHelper.slide_controller.slide_instances.size():
		comments_rtl.text = ""
		return
	var slide: Slide = SlideHelper.slide_controller.slide_instances.get(slide_index)
	comments_rtl.text = slide.get_comments()

func _on_comments_rtl_meta_clicked(meta: Variant) -> void:
	if !enable_outgoing_links:
		return
	OS.shell_open(str(meta))
