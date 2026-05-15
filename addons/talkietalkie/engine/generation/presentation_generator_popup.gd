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
@export var type_two_d_radio_button: CheckBox
@export var type_three_d_radio_button: CheckBox

@export var add_camera_check_button: CheckButton

@export var bg_none_radio_button: CheckBox
@export var bg_color_radio_button: CheckBox
@export var bg_scene_radio_button: CheckBox

@export var content_none_radio_button: CheckBox
@export var content_from_md_radio_button: CheckBox

@export var name_line_edit: LineEdit
@export var name_info_label: RichTextLabel

@export var markdown_vbc: VBoxContainer
@export var md_content_text_edit: TextEdit
@export var title_check_button: CheckButton

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

static var pg_data: PresentationGenerator.PresentationGenerationData = null
static var selected_theme_path: String

#var md_file_load_path: String = ""
#var selected_theme: Theme

func _ready() -> void:
	if pg_data == null:
		pg_data = PresentationGenerator.PresentationGenerationData.default()

	#popup_centered()
	
	if background_scene_file_dialog != null:
		background_scene_file_dialog.visible = false
		generate_scene_file_dialog.visible = false
		md_file_dialog.visible = false
	
	name_info_label.visible = false


	title_check_button.button_pressed = pg_data.create_title_slide

	match pg_data.presentation_type: 
		PresentationGenerator.PresentationType.CONTROL:
			type_control_radio_button.button_pressed = true
			_on_type_control_radio_button_pressed()
		PresentationGenerator.PresentationType.TWO_D:
			type_two_d_radio_button.button_pressed = true
		
			_on_type_two_d_radio_button_pressed()
		PresentationGenerator.PresentationType.THREE_D:
			type_three_d_radio_button.button_pressed = true
			
			_on_type_three_d_radio_button_pressed()
			
	add_camera_check_button.button_pressed = pg_data.add_camera_node
	_on_add_camera_check_button_toggled(pg_data.add_camera_node)

	match pg_data.background_type:
		PresentationGenerator.BackgroundType.NONE:
			bg_none_radio_button.button_pressed = true
			_on_bg_none_radio_button_pressed()
		PresentationGenerator.BackgroundType.COLOR:
			bg_color_radio_button.button_pressed = true
			_on_bg_color_radio_button_pressed()
			background_color_picker_button.color = pg_data.background_color
		PresentationGenerator.BackgroundType.SCENE:
			bg_scene_radio_button.button_pressed = true
			_on_bg_scene_radio_button_pressed()
			_on_background_scene_file_dialog_file_selected(pg_data.background_file_path)
			
			#_on_background_scene_file_dialog_file_selected()
	
	_on_name_line_edit_text_submitted(pg_data.presentation_name)
	name_line_edit.grab_focus()

	if pg_data.create_content_from_md:
		_on_content_from_md_radio_button_pressed()
		content_from_md_radio_button.button_pressed = true
		md_content_text_edit.text = pg_data.content_md_text
	else:
		_on_content_none_radio_button_pressed()
		content_none_radio_button.button_pressed = true

	if !selected_theme_path.is_empty():
		_on_theme_file_dialog_file_selected(selected_theme_path)
	else:
		_on_clear_theme_button_pressed()
		
func start_generate() -> void:
	await PresentationGenerator.do_generate(pg_data)

	pg_data = null

	## close this popup
	queue_free()

#region ui handling
func _on_generate_button_pressed() -> void:
	generate_scene_file_dialog.current_path = pg_data.presentation_name.to_snake_case()
	generate_scene_file_dialog.popup_centered() 
		
func _on_cancel_button_pressed() -> void:
	queue_free()

func _on_name_line_edit_text_changed(new_text: String) -> void:
	update_name_from_input(new_text)
	
func update_name_from_input(new_name: String) -> void:
	pg_data.presentation_name = clean_path(new_name)
	name_info_label.visible = pg_data.presentation_name.is_empty()
	if pg_data.presentation_name.is_empty():
		name_info_label.text = "[i]No presentation name specified[/i]"

	generate_button.disabled = pg_data.presentation_name.is_empty()

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
	pg_data.presentation_type = PresentationGenerator.PresentationType.CONTROL
	add_camera_check_button.visible = false

func _on_type_two_d_radio_button_pressed() -> void:
	pg_data.presentation_type = PresentationGenerator.PresentationType.TWO_D
	add_camera_check_button.text = "Add Camera2D"
	add_camera_check_button.visible = true

func _on_type_three_d_radio_button_pressed() -> void:
	pg_data.presentation_type = PresentationGenerator.PresentationType.THREE_D
	add_camera_check_button.text = "Add Camera3D"
	add_camera_check_button.visible = true

func _on_bg_none_radio_button_pressed() -> void:
	pg_data.background_type = PresentationGenerator.BackgroundType.NONE
	background_color_picker_button.visible = false
	background_scene_select_button.visible = false
	background_scene_label.visible = false
	background_scene_info_label.visible = false

func _on_bg_color_radio_button_pressed() -> void:
	pg_data.background_type = PresentationGenerator.BackgroundType.COLOR
	background_color_picker_button.visible = true
	background_scene_select_button.visible = false
	background_scene_label.visible = false
	background_scene_info_label.visible = false

func _on_bg_scene_radio_button_pressed() -> void:
	pg_data.background_type = PresentationGenerator.BackgroundType.SCENE
	background_color_picker_button.visible = false
	background_scene_select_button.visible = true
	background_scene_label.visible = !pg_data.background_file_path.is_empty()
	background_scene_info_label.visible = true

func _on_background_color_picker_button_color_changed(color: Color) -> void:
	pg_data.background_color = color

func _on_file_selection_button_pressed() -> void:
	background_scene_file_dialog.popup_centered()

func _on_background_scene_file_dialog_file_selected(path: String) -> void:
	if !FileAccess.file_exists(path):
		push_warning("PresentationGenerator: could not select background scene from '", path, "'")
		return
	
	background_scene_file_dialog.visible = false
	pg_data.background_file_path = path
	background_scene_label.visible = !path.is_empty()
	
	background_scene_label.text = shorten_path(path)
	
func _on_generate_scene_file_dialog_file_selected(path: String) -> void:
	if !path.get_file().is_valid_filename():
		push_warning("PresentationGenerator: invalid file path:", path)
		return
	pg_data.target_file_path = path

	start_generate()
	
func _on_load_md_file_button_pressed() -> void:
	md_file_dialog.popup_centered()

func _on_md_file_dialog_file_selected(path: String) -> void:
	if !FileAccess.file_exists(path):
		push_warning("PresentationGenerator: could not load markdown from '", path, "'")
		return

	var file_access: FileAccess = FileAccess.open(path, FileAccess.READ)
	md_content_text_edit.text = file_access.get_as_text()
	pg_data.content_md_text = md_content_text_edit.text

func _on_title_check_button_toggled(toggled_on: bool) -> void:
	pg_data.create_title_slide = toggled_on

func _on_add_camera_check_button_toggled(toggled_on: bool) -> void:
	pg_data.add_camera_node = toggled_on

func _on_content_none_radio_button_pressed() -> void:
	markdown_vbc.visible = false
	pg_data.create_content_from_md = false
	
func _on_content_from_md_radio_button_pressed() -> void:
	markdown_vbc.visible = true
	pg_data.create_content_from_md = true
	
func _on_theme_file_dialog_file_selected(path: String) -> void:
	if path.is_empty():
		return
		
	if !FileAccess.file_exists(path):
		push_warning("PresentationGenerator: could not load theme from '", path, "'")
		return
	
	pg_data.selected_theme = load(path) as Theme
	selected_theme_path = path
	selected_theme_label.text = shorten_path(path)
	clear_theme_button.visible = true

func _on_clear_theme_button_pressed() -> void:
	pg_data.selected_theme = null
	selected_theme_path = ""
	selected_theme_label.text = "No theme selected"
	clear_theme_button.visible = false

func _on_theme_select_button_pressed() -> void:
	theme_file_dialog.popup_centered()

static func shorten_path(path: String) -> String:
	if path.length() > MAX_PATH_LABEL_LENGTH:
		return "..." + path.substr(path.length()-(MAX_PATH_LABEL_LENGTH-3))
	
	return path

func _on_md_content_text_edit_text_changed() -> void:
	pg_data.content_md_text = md_content_text_edit.text
