@tool
extends EditorPlugin

const TOOL_MENU_ITEM_GENERATE_PRESENTATION: String = "TalkieTalkie: Generate Presentation"
static var PRESENTATION_GENERATOR_POPUP_SCENE = load(TTSetup.get_plugin_path() + "/engine/generation/presentation_generator_popup.tscn")

## Autoloads used by the plugin
static var AUTOLOADS: Dictionary[String,String] = {
	TTSetup.get_plugin_path() + "/engine/autoload/tt_preferences.gd": "TTPreferences",
	TTSetup.get_plugin_path() + "/engine/autoload/tt_slide_helper.gd": "TTSlideHelper"
}

func _enable_plugin() -> void:
	if OS.has_feature("editor"):
		print_rich("[color='88AAAA']Thank you for using [/color][img height=20]"+TTSetup.get_plugin_path()+"/style/tt_icon.svg[/img][b][color='99AABB']TalkieTalkie[/color][/b]. [color='88AAAA']More information about this plugin can be found in "+TTSetup.get_plugin_path()+"/README.md[/color]") # Prints "Hello world!", in green with a bold font.
	add_autoloads()
	var ttsetup: TTSetup = TTSetup.new()
	add_inputs()
	print("TalkieTalkie addon enabled.")

func _disable_plugin() -> void:
	remove_autoloads()
	var ttsetup: TTSetup = TTSetup.new()
	remove_inputs()
	print("TalkieTalkie addon disabled.")

func _enter_tree() -> void:
	if Engine.is_editor_hint():
		add_tool_menu_items()

func _exit_tree() -> void:
	if Engine.is_editor_hint():
		remove_tool_menu_items()

func add_autoloads() -> void:
	print("TalkieTalkie: adding autoloads...")
	for autoload_path: String in AUTOLOADS.keys():
		add_autoload_singleton(AUTOLOADS[autoload_path], autoload_path)

func remove_autoloads() -> void:
	print("TalkieTalkie: removing autoloads...")
	for autoload_name: String in AUTOLOADS.values():
		remove_autoload_singleton(autoload_name)

func add_tool_menu_items() -> void:
	#print("TalkieTalkie: adding tool menu items...")
	add_tool_menu_item(TOOL_MENU_ITEM_GENERATE_PRESENTATION, on_generate_presentation_clicked)
	
func remove_tool_menu_items() -> void:
	#print("TalkieTalkie: removing tool menu items...")
	remove_tool_menu_item(TOOL_MENU_ITEM_GENERATE_PRESENTATION)

func on_generate_presentation_clicked() -> void:
	var pr_generator_popup: Popup = PRESENTATION_GENERATOR_POPUP_SCENE.instantiate() as Popup
	var scale: float = EditorInterface.get_editor_scale()
	pr_generator_popup.visible = false
	EditorInterface.get_base_control().add_child(pr_generator_popup)
	pr_generator_popup.popup_centered()

func add_inputs() -> void:
	print("TalkieTalkie: adding inputs...")
	var is_any_changed: bool = false
	var ttsetup: TTSetup = TTSetup.new()
	for input_name in ttsetup.default_inputs.keys():
		if ProjectSettings.has_setting("input/" + input_name):
			print("TalkieTalkie.add_inputs(): ProjectSettings already has an input '", input_name, "'. Skipped adding this input.")
			continue
		var input: Dictionary = {
			"deadzone": 0.5,
			"events": ttsetup.default_inputs[input_name]
		}
		ProjectSettings.set_setting("input/" + input_name, input)
		is_any_changed = true
		
	
	ProjectSettings.save()
	if TTSetup.RESTART_EDITOR_ON_PLUGIN_TOGGLED:
		EditorInterface.restart_editor(true)
	
func remove_inputs() -> void:
	print("TalkieTalkie: removing inputs...")
	var is_any_changed: bool = false
	var ttsetup: TTSetup = TTSetup.new()
	for input_name in ttsetup.default_inputs.keys():
		if !ProjectSettings.has_setting("input/" + input_name):
			print("TalkieTalkie.remove_inputs(): ProjectSettings does not have input '", input_name, "'. Skipped removing this input.")
			continue
			
		ProjectSettings.set_setting("input/" + input_name, null)
		is_any_changed = true
		
	if !is_any_changed:
		return

	ProjectSettings.save()
	if TTSetup.RESTART_EDITOR_ON_PLUGIN_TOGGLED:
		EditorInterface.restart_editor(true)
