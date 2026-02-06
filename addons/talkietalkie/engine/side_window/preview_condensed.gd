class_name PreviewCondensed
extends Control

const TEX_EYE: Texture2D = preload(TalkieTalkie.PLUGIN_ROOT + "style/ui/eye.svg")
const TEX_EYE_HOVER: Texture2D = preload(TalkieTalkie.PLUGIN_ROOT + "style/ui/eye_hover.svg")
const TEX_EYE_PRESSED: Texture2D = preload(TalkieTalkie.PLUGIN_ROOT + "style/ui/eye_pressed.svg")

const TEX_EYE_CROSSED: Texture2D = preload(TalkieTalkie.PLUGIN_ROOT + "style/ui/eye_crossed.svg")
const TEX_EYE_CROSSED_HOVER: Texture2D = preload(TalkieTalkie.PLUGIN_ROOT + "style/ui/eye_crossed_hover.svg")
const TEX_EYE_CROSSED_PRESSED: Texture2D = preload(TalkieTalkie.PLUGIN_ROOT + "style/ui/eye_crossed_pressed.svg")

signal toggle_preview_visible(is_visible_new: bool)
signal toggle_preview_on_top(is_on_top_new: bool)

@export var target_slide_preview: SlidePreview
@export var preview_title: String

@export_range(3, 100) var max_slide_title_length: int = 25

@export_category("Internal Nodes")
@export var title_label: Label
@export var slide_title_label: Label
@export var popup_button: TextureButton
@export var preview_on_top_button: BaseButton

var popup_button_tr_key: String

func _ready() -> void:
	popup_button.set_pressed_no_signal(!target_slide_preview.visible)
	preview_on_top_button.set_pressed_no_signal(target_slide_preview.always_on_top)

	target_slide_preview.slide_updated.connect(update_slide_title_text)
	#set_preview_on_top(false, true)
	update_slide_title_text()
	TTPreferences.language_changed.connect(translate)
	translate()
	
func set_preview_visible(is_visible_new: bool, update_button: bool = false) -> void:
	if update_button:
		popup_button.set_pressed_no_signal(!is_visible_new)

	popup_button.texture_normal = TEX_EYE if is_visible_new else TEX_EYE_CROSSED
	popup_button.texture_pressed = TEX_EYE_PRESSED if is_visible_new else TEX_EYE_CROSSED_PRESSED
	popup_button.texture_hover = TEX_EYE_HOVER if is_visible_new else TEX_EYE_CROSSED_HOVER
	
	preview_on_top_button.disabled = !is_visible_new
	translate()

func set_preview_on_top(is_preview_on_top_new: bool, update_button: bool = false) -> void:
	if update_button:
		preview_on_top_button.set_pressed_no_signal(is_preview_on_top_new)

func set_buttons_visible(are_buttons_visible_new: bool) -> void:
	popup_button.visible = are_buttons_visible_new
	preview_on_top_button.visible = are_buttons_visible_new

func update_slide_title_text() -> void:
	if target_slide_preview.current_slide == null:
		slide_title_label.text = "-"
		return

	var slide_title: String = target_slide_preview.current_slide.get_title()
	if slide_title.length() > max_slide_title_length:
		slide_title = slide_title.substr(0, max_slide_title_length-3) + "..."
	slide_title_label.text = "?" if slide_title.is_empty() else slide_title

func _on_popup_button_toggled(toggled_on: bool) -> void:
	toggle_preview_visible.emit(!toggled_on)

func _on_preview_on_top_button_toggled(toggled_on: bool) -> void:
	toggle_preview_on_top.emit(toggled_on)
	
func translate() -> void:
	title_label.text = tr(preview_title)
