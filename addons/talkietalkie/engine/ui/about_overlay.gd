class_name AboutOverlay
extends CanvasLayer

signal close_overlay

const TT_GITHUB_URL: String = "https://github.com/substain/TalkieTalkie"
const TT_DESCRIPTION: String = "TalkieTalkie is a framework for creating presentations in the Godot Engine."

@export var enable_links: bool = true
@export_category("internal nodes")

@export var talkie_talkie_label: Label
@export var godot_label: Label

@export var about_talkie_talkie_label: RichTextLabel
@export var about_godot_label: RichTextLabel

func _ready() -> void:
	talkie_talkie_label.text = "TalkieTalkie " + Util.get_talkie_talkie_version()
	godot_label.text = "Godot " + Util.get_godot_version()
	about_talkie_talkie_label.text = get_about_talkie_talkie_text_rich()
	about_godot_label.text = get_about_godot_text_rich()

func get_about_talkie_talkie_text_rich() -> String:
	var result: String = TT_DESCRIPTION + "\n"
	result += "Github: [url='%s']https://github.com/substain/TalkieTalkie[/url]" % TT_GITHUB_URL
	return result

func get_about_godot_text_rich() -> String:
	return Engine.get_license_text()

func _on_meta_clicked(meta: Variant) -> void:
	if !enable_links:
		return
	OS.shell_open(str(meta))

func _on_close_button_pressed() -> void:
	close_overlay.emit()

func _on_background_gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		close_overlay.emit()
	if event is InputEventMouseButton:
		if (event as InputEventMouseButton).button_index == MOUSE_BUTTON_LEFT || (event as InputEventMouseButton).button_index == MOUSE_BUTTON_RIGHT:
			close_overlay.emit()
