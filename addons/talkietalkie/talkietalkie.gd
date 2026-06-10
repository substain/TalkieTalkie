@tool
extends EditorPlugin

class ProjectSettingData:
	var setting_name: String
	var initial_value: Variant
	var type: Variant.Type
	var hint: PropertyHint
	var hint_string: String
	var description: String # unsupported yet: https://github.com/godotengine/godot-proposals/discussions/8224

	func _init(setting_name_new: String, initial_value_new: Variant, type_new: Variant.Type, hint_new: PropertyHint, hint_string_new: String, description_new: String) -> void:
		setting_name = setting_name_new
		initial_value = initial_value_new
		type = type_new
		hint = hint_new
		hint_string = hint_string_new
		description = description_new

const TOOL_MENU_ITEM_GENERATE_PRESENTATION: String = "TalkieTalkie: Generate Presentation"
const PRESENTATION_GENERATOR_POPUP_SCENE: PackedScene = preload("uid://db3b30nurj4it") #/engine/generation/presentation_generator_popup.tscn

const INPUT_DEADZONE: String = "deadzone"
const INPUT_EVENTS: String = "events"
const PROPERTY_INFO_NAME: String = "name"
const PROPERTY_INFO_TYPE: String = "type"
const PROPERTY_INFO_HINT: String = "hint"
const PROPERTY_INFO_HINT_STRING: String = "hint_string"

## Autoloads used by the addon
static var AUTOLOADS: Dictionary[String,String] = {
	TalkieSetup.get_addon_path() + "/engine/autoload/talkietalkie_preferences.gd": "TalkiePreferences",
	TalkieSetup.get_addon_path() + "/engine/autoload/talkietalkie_slide_helper.gd": "TalkieSlideHelper"
}

static var PROJECT_SETTINGS: Array[ProjectSettingData] = [
	ProjectSettingData.new("talkietalkie/general/remember_slide_on_close", false, TYPE_BOOL, PROPERTY_HINT_NONE, "", "Remember slide on close. When active, the slide index will be loaded from the last session if the presentation name matches."),
	ProjectSettingData.new("talkietalkie/general/stop_auto_slideshow_on_continue", true, TYPE_BOOL, PROPERTY_HINT_NONE, "", "When active, slideshows are stopped if an input is pressed"),
	ProjectSettingData.new("talkietalkie/general/continue_on_unhandled_left_click", true, TYPE_BOOL, PROPERTY_HINT_NONE, "", "When active, using an unhandled left click input events will continue slides (additional to the other inputs). This might not be work as intended if control nodes don't propagate mouse input."),
	
	ProjectSettingData.new("talkietalkie/ui/open_ui_on_startup", "on_mobile", TYPE_STRING, PROPERTY_HINT_ENUM, "false,on_mobile,true", "If 'true', the UI will show up on start, if 'on_mobile', this is only be true for mobile devices. Otherwise, UI will not automatically show up."),
	ProjectSettingData.new("talkietalkie/ui/show_toggle_ui_button", "on_mobile", TYPE_STRING, PROPERTY_HINT_ENUM, "false,on_mobile,true", "If 'true', the toggle button for the UI will show up on start, if 'on_mobile', this is only be true for mobile devices. Otherwise, the button will not be displayed."),
	ProjectSettingData.new("talkietalkie/ui/enable_control_bar", true, TYPE_BOOL, PROPERTY_HINT_NONE, "", "When active, the Control Bar is shown in the UI."),
	ProjectSettingData.new("talkietalkie/ui/enable_tabnav_bar", true, TYPE_BOOL, PROPERTY_HINT_NONE, "", "When active, the TabNavigation Bar is shown in the UI"),
	ProjectSettingData.new("talkietalkie/ui/enable_settings", true, TYPE_BOOL, PROPERTY_HINT_NONE, "", "When active, the Settings are shown in the UI"),
	ProjectSettingData.new("talkietalkie/ui/enable_about_window_links", true, TYPE_BOOL, PROPERTY_HINT_NONE, "", "Makes the links in the About section clickable, if activaed."),
	
	ProjectSettingData.new("talkietalkie/tab_navigation/max_visible_tabnav_elements", 12, TYPE_INT, PROPERTY_HINT_NONE, "", "The maximum amount of slides (i.e. tab nav elements) until a scroll bar is shown in the TabNavigation Bar"),
	ProjectSettingData.new("talkietalkie/tab_navigation/tabnav_width_on_scroll", 400, TYPE_INT, PROPERTY_HINT_NONE, "", "The width of the TabNavigation Bar if the scroll bar is visible"),
	ProjectSettingData.new("talkietalkie/tab_navigation/tabnav_indicator", "none", TYPE_STRING, PROPERTY_HINT_ENUM, "none,number,slide_title", "How tabs are labeled in the TabNavigation Bar. 'number' shows the slide number, 'slide_title' shows the first characters of the title. 'none' for no indication."),
	ProjectSettingData.new("talkietalkie/tab_navigation/tabnav_indicator_max_length", 3, TYPE_INT, PROPERTY_HINT_NONE, "", "The maximum allowed number of characters if the tabnav_indicator setting is set to 'slide_title'."),
	
	ProjectSettingData.new("talkietalkie/settings/show_translation_control", true, TYPE_BOOL, PROPERTY_HINT_NONE, "", "If true, show a setting for translating the slides."),
	ProjectSettingData.new("talkietalkie/settings/show_audio_for_bus", "Master", TYPE_STRING, PROPERTY_HINT_NONE, "", "The name of the audio bus you want to show audio settings for (e.g. 'Master'). Leave empty if you don't want to show audio controls."),

	ProjectSettingData.new("talkietalkie/side_window/enable_side_window", "true", TYPE_STRING, PROPERTY_HINT_ENUM, "false,on_multiple_monitors,true", "Defines when the side window should be enabled. Use 'on_multiple_monitors' if side window should only be enabled when multiple monitors are recognized. If 'true', the side window is enabled in any case. Use 'false' otherwise."),
	ProjectSettingData.new("talkietalkie/side_window/open_sw_on_start", false, TYPE_BOOL, PROPERTY_HINT_NONE, "", "When active, the side window will open on startup (if enabled)."),
	ProjectSettingData.new("talkietalkie/side_window/quit_on_close_sw", false, TYPE_BOOL, PROPERTY_HINT_NONE, "", "When actived, quitting the side window will also close the presentation."),
]

func _enable_plugin() -> void:
	if OS.has_feature("editor"):
		print_rich("[color='88AAAA']Thank you for using [/color][img height=20]"+TalkieSetup.get_addon_path()+"/style/tt_icon.svg[/img][b][color='99AABB']TalkieTalkie[/color][/b]. [color='88AAAA']More information about this plugin can be found in "+TalkieSetup.get_addon_path()+"/README.md[/color]")
	add_autoloads()
	var has_changed_inputs: bool = add_inputs()
	TalkieUtil.tt_printr("addon enabled.")

	ProjectSettings.save()
	if has_changed_inputs && TalkieSetup.RESTART_EDITOR_ON_PLUGIN_TOGGLED:
		EditorInterface.restart_editor(true)
		
func _disable_plugin() -> void:
	remove_autoloads()
	var has_changed_inputs: bool = remove_inputs()
	TalkieUtil.tt_printr("addon disabled.")

	ProjectSettings.save()
	if has_changed_inputs && TalkieSetup.RESTART_EDITOR_ON_PLUGIN_TOGGLED:
		EditorInterface.restart_editor(true)

func _enter_tree() -> void:
	if Engine.is_editor_hint():
		add_tool_menu_items()
	add_project_settings()

func _exit_tree() -> void:
	if Engine.is_editor_hint():
		remove_tool_menu_items()
	remove_project_settings()

func add_autoloads() -> void:
	TalkieUtil.tt_printr("adding autoloads...")
	for autoload_path: String in AUTOLOADS.keys():
		add_autoload_singleton(AUTOLOADS[autoload_path], autoload_path)

func remove_autoloads() -> void:
	TalkieUtil.tt_printr("removing autoloads...")
	for autoload_name: String in AUTOLOADS.values():
		remove_autoload_singleton(autoload_name)

func add_tool_menu_items() -> void:
	#TalkieUtil.tt_printr("TalkieTalkie: adding tool menu items...")
	add_tool_menu_item(TOOL_MENU_ITEM_GENERATE_PRESENTATION, on_generate_presentation_clicked)
	
func remove_tool_menu_items() -> void:
	#TalkieUtil.tt_printr("TalkieTalkie: removing tool menu items...")
	remove_tool_menu_item(TOOL_MENU_ITEM_GENERATE_PRESENTATION)

func on_generate_presentation_clicked() -> void:
	var pr_generator_popup: Popup = PRESENTATION_GENERATOR_POPUP_SCENE.instantiate() as Popup
	var scale: float = EditorInterface.get_editor_scale()
	pr_generator_popup.visible = false
	EditorInterface.get_base_control().add_child(pr_generator_popup)
	pr_generator_popup.popup_centered()

func add_inputs() -> bool:
	TalkieUtil.tt_printr("adding inputs...")
	var is_any_changed: bool = false
	var inputs: Dictionary[String, Array] = TalkieSetup.get_inputs()
	for input_name in inputs:
		if ProjectSettings.has_setting("input/" + input_name):
			TalkieUtil.tt_printr("ProjectSettings already has an input '" + input_name + "'. Skipped adding this input.")
			continue
		var input: Dictionary = {
			INPUT_DEADZONE: 0.5,
			INPUT_EVENTS: inputs[input_name]
		}
		ProjectSettings.set_setting("input/" + input_name, input)
		is_any_changed = true
	return is_any_changed

func remove_inputs() -> bool:
	TalkieUtil.tt_printr("removing inputs...")
	var is_any_changed: bool = false
	for input_name in TalkieSetup.get_inputs():
		if !ProjectSettings.has_setting("input/" + input_name):
			TalkieUtil.tt_printr("ProjectSettings does not have input '" + input_name + "'. Skipped removing this input.")
			continue
			
		ProjectSettings.set_setting("input/" + input_name, null)
		is_any_changed = true
	return is_any_changed

func add_project_settings() -> void:
	for setting: ProjectSettingData in PROJECT_SETTINGS:
		if !ProjectSettings.has_setting(setting.setting_name):
			ProjectSettings.set_setting(setting.setting_name, setting.initial_value)

		ProjectSettings.set_initial_value(setting.setting_name, setting.initial_value)
		var property_info: Dictionary = {
			PROPERTY_INFO_NAME: setting.setting_name,
			PROPERTY_INFO_TYPE: setting.type,
			PROPERTY_INFO_HINT: setting.hint,
			PROPERTY_INFO_HINT_STRING: setting.hint_string
		}
		ProjectSettings.add_property_info(property_info)
	
func remove_project_settings() -> void:
	for setting in PROJECT_SETTINGS:
		if !ProjectSettings.has_setting(setting.setting_name):
			continue
	
		#TODO: remove?
		#ProjectSettings.set_setting(setting.setting_name, null)
