class_name PreviewCondensed
extends Control

@export var target_slide_preview: SlidePreview
@export var preview_title: String

@export_range(3, 100) var max_slide_title_length: int = 25

@export_category("Internal Nodes")
@export var title_label: Label
@export var slide_title_label: Label
@export var popup_button: Button

func _ready() -> void:
	title_label.text = tr(preview_title)
	popup_button.set_pressed_no_signal(!target_slide_preview.visible)
	target_slide_preview.slide_updated.connect(update_slide_title_text)
	update_popup_text()
	update_slide_title_text()

func _on_popup_button_toggled(toggled_on: bool) -> void:
	set_preview_visible(!toggled_on)

func set_preview_visible(is_visible_new: bool, update_button: bool = false) -> void:
	if update_button:
		popup_button.set_pressed_no_signal(!is_visible_new)

	update_popup_text()
	target_slide_preview.visible = is_visible_new

func update_popup_text() -> void:
	popup_button.text = tr("ui.preview.show_preview") if popup_button.button_pressed else tr("ui.preview.hide_preview")

func update_slide_title_text() -> void:
	if target_slide_preview.current_slide == null:
		slide_title_label.text = "-"
		return

	var slide_title: String = target_slide_preview.current_slide.get_title()
	if slide_title.length() > max_slide_title_length:
		slide_title = slide_title.substr(0, max_slide_title_length-3) + "..."
	slide_title_label.text = "?" if slide_title.is_empty() else slide_title
