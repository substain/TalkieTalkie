@tool
class_name PresentationGeneratorPopup
extends PopupPanel

static var _PRESENTATION_BASE_PATH: String = TTSetup.get_plugin_path() + "/engine/base/presentation.tscn"
static var _PRESENTATION_BASE_SCENE: PackedScene = load(_PRESENTATION_BASE_PATH)
static var _DEFAULT_TITLE_LAYOUT_SCENE: PackedScene = load(TTSetup.get_plugin_path() + "/engine/default_template/default_title_layout.tscn")

static var _DEFAULT_TRANSITION_2D: Resource = load(TTSetup.get_plugin_path() + "/engine/transitions/move_transition_2d.gd")
static var _DEFAULT_TRANSITION_3D: Resource = load(TTSetup.get_plugin_path() + "/engine/transitions/move_transition_2d.gd")

const MAX_PATH_LABEL_LENGTH: int = 40

@export var target_scene_line_edit: LineEdit

@export var type_control_radio_button: CheckBox
@export var add_camera_check_button: CheckButton

@export var bg_none_radio_button: CheckBox
@export var content_none_radio_button: CheckBox
@export var content_from_md_radio_button: CheckBox

@export var name_line_edit: LineEdit
@export var name_info_label: RichTextLabel

@export var markdown_vbc: VBoxContainer
@export var md_content_text_edit: TextEdit

@export var background_color_picker_button: ColorPickerButton
@export var background_scene_label: Label
@export var background_scene_select_button: Button
@export var background_scene_info_label: RichTextLabel

@export var background_scene_file_dialog: FileDialog
@export var generate_scene_file_dialog: FileDialog
@export var md_file_dialog: FileDialog
@export var theme_file_dialog: FileDialog

@export var selected_theme_label: Label
@export var clear_theme_button: Button

@export var generate_button: Button
	
var presentation_name: String = ""
var target_file_path: String = ""
var background_file_path: String = ""
var md_file_load_path: String = ""
var selected_theme: Theme

var create_title_slide: bool = false
var add_camera_node: bool = false

var presentation_type: PresentationGenerator.PresentationType = PresentationGenerator.PresentationType.CONTROL
var background_type: PresentationGenerator.BackgroundType = PresentationGenerator.BackgroundType.NONE

func _ready() -> void:
	
	#popup_centered()
	type_control_radio_button.button_pressed = true
	bg_none_radio_button.button_pressed = true
	content_none_radio_button.button_pressed = true
	
	markdown_vbc.visible = false

	background_color_picker_button.visible = false
	background_scene_select_button.visible = false
	background_scene_info_label.visible = false
	background_scene_label.visible = false
	clear_theme_button.visible = false
	selected_theme_label.text = "No theme selected"
	
	if background_scene_file_dialog != null:
		background_scene_file_dialog.visible = false
		generate_scene_file_dialog.visible = false
		md_file_dialog.visible = false
	
	update_name_from_input("")
	name_info_label.visible = false
	add_camera_check_button.visible = false

	name_line_edit.grab_focus()

func start_generate() -> void:
		
	var pg_data: PresentationGenerator.PresentationGenerationData = PresentationGenerator.PresentationGenerationData.new(
		target_file_path,
		presentation_name,
		presentation_type,
		add_camera_node,
		background_type,
		background_file_path,
		background_color_picker_button.color,
		create_title_slide,
		content_from_md_radio_button.button_pressed,
		md_content_text_edit.text,
		selected_theme
	)
	
	await PresentationGenerator.do_generate(pg_data)

	## close this popup
	queue_free()

#region ui handling
func _on_generate_button_pressed() -> void:
	generate_scene_file_dialog.current_path = presentation_name.to_snake_case()
	generate_scene_file_dialog.popup_centered() 
		
func _on_cancel_button_pressed() -> void:
	queue_free()

func _on_name_line_edit_text_changed(new_text: String) -> void:
	update_name_from_input(new_text)
	
func update_name_from_input(new_name: String) -> void:
	presentation_name = clean_path(new_name)
	name_info_label.visible = presentation_name.is_empty()
	if presentation_name.is_empty():
		name_info_label.text = "[i]No presentation name specified[/i]"

	generate_button.disabled = presentation_name.is_empty()

func check_path_validity(path: String) -> bool:
	return !FileAccess.file_exists(path)

func get_name_path_combined(target_text: String) -> String:
	return "res://" + target_text + ".tscn"
	
func clean_path(path: String) -> String:
	#TODO: also remove other characters such as .,; etc?
	var cleaned_path: String = path.strip_edges()
	return cleaned_path

func _on_name_line_edit_text_submitted(new_text: String) -> void:
	name_line_edit.text = clean_path(new_text)
	update_name_from_input(name_line_edit.text)

func _on_name_line_edit_focus_exited() -> void:
	name_line_edit.text = clean_path(name_line_edit.text)
	update_name_from_input(name_line_edit.text)

func _on_type_control_radio_button_pressed() -> void:
	presentation_type = PresentationGenerator.PresentationType.CONTROL
	add_camera_check_button.visible = false

func _on_type_two_d_radio_button_pressed() -> void:
	presentation_type = PresentationGenerator.PresentationType.TWO_D
	add_camera_check_button.text = "Add Camera2D"
	add_camera_check_button.visible = true

func _on_type_three_d_radio_button_pressed() -> void:
	presentation_type = PresentationGenerator.PresentationType.THREE_D
	add_camera_check_button.text = "Add Camera3D"
	add_camera_check_button.visible = true

func _on_bg_none_radio_button_pressed() -> void:
	background_type = PresentationGenerator.BackgroundType.NONE
	background_color_picker_button.visible = false
	background_scene_select_button.visible = false
	background_scene_label.visible = false
	background_scene_info_label.visible = false

func _on_bg_color_radio_button_pressed() -> void:
	background_type = PresentationGenerator.BackgroundType.COLOR
	background_color_picker_button.visible = true
	background_scene_select_button.visible = false
	background_scene_label.visible = false
	background_scene_info_label.visible = false

func _on_bg_scene_radio_button_pressed() -> void:
	background_type = PresentationGenerator.BackgroundType.SCENE
	background_color_picker_button.visible = false
	background_scene_select_button.visible = true
	background_scene_label.visible = !background_file_path.is_empty()
	background_scene_info_label.visible = true

func _on_file_selection_button_pressed() -> void:
	background_scene_file_dialog.popup_centered()

func _on_background_scene_file_dialog_file_selected(path: String) -> void:
	if !FileAccess.file_exists(path):
		push_warning("could not select background scene from '", path, "'")
		return
	
	background_scene_file_dialog.visible = false
	background_file_path = path
	background_scene_label.visible = !path.is_empty()
	
	background_scene_label.text = shorten_path(path)
	
func _on_generate_scene_file_dialog_file_selected(path: String) -> void:
	target_file_path = path
	start_generate()
	
func _on_load_md_file_button_pressed() -> void:
	md_file_dialog.popup_centered()

func _on_md_file_dialog_file_selected(path: String) -> void:
	if !FileAccess.file_exists(path):
		push_warning("could not load markdown from '", md_file_load_path, "'")
		return
	md_file_load_path = path

	var file_access: FileAccess = FileAccess.open(md_file_load_path, FileAccess.READ)
	md_content_text_edit.text = file_access.get_as_text()

func _on_title_check_button_toggled(toggled_on: bool) -> void:
	create_title_slide = toggled_on

func _on_add_camera_check_button_toggled(toggled_on: bool) -> void:
	add_camera_node = toggled_on

func _on_content_none_radio_button_pressed() -> void:
	markdown_vbc.visible = false

func _on_content_from_md_radio_button_pressed() -> void:
	markdown_vbc.visible = true

func _on_theme_file_dialog_file_selected(path: String) -> void:
	if path.is_empty():
		return
		
	if !FileAccess.file_exists(path):
		push_warning("could not load thene from '", path, "'")
		return
	
	selected_theme = load(path) as Theme
	selected_theme_label.text = shorten_path(path)
	clear_theme_button.visible = true

func _on_clear_theme_button_pressed() -> void:
	selected_theme = null
	selected_theme_label.text = "No theme selected"
	clear_theme_button.visible = false

func _on_theme_select_button_pressed() -> void:
	theme_file_dialog.popup_centered()

static func shorten_path(path: String) -> String:
	if path.length() > MAX_PATH_LABEL_LENGTH:
		return "..." + path.substr(path.length()-(MAX_PATH_LABEL_LENGTH-3))
	
	return path
