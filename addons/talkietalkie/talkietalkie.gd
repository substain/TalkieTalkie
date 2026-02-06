@tool
extends EditorPlugin

## Autoloads used by the plugin
const AUTOLOADS: Dictionary[String,String] = {
	TTSetup.PLUGIN_ROOT + "engine/autoload/tt_preferences.gd": "TTPreferences",
	TTSetup.PLUGIN_ROOT + "engine/autoload/tt_slide_helper.gd": "TTSlideHelper"
}

func _enable_plugin() -> void:
	if OS.has_feature("editor"):
		print_rich("[color='88AAAA']Thank you for using [/color][img height=20]"+TTSetup.PLUGIN_ROOT+"style/tt_icon.svg[/img][b][color='99AABB']TalkieTalkie[/color][/b]. [color='88AAAA']More information about this plugin can be found in "+TTSetup.PLUGIN_ROOT+"README.md[/color]") # Prints "Hello world!", in green with a bold font.
	print("TalkieTalkie: adding autoloads...")
	add_autoloads()
	var ttsetup: TTSetup = TTSetup.new()
	print("TalkieTalkie: adding ", ttsetup.default_inputs.keys().size() ," inputs... ")
	add_inputs()
	print("finished _enable_plugin")

func _disable_plugin() -> void:
	print("TalkieTalkie: removing autoloads...")
	remove_autoloads()
	var ttsetup: TTSetup = TTSetup.new()
	print("TalkieTalkie: removing ", ttsetup.default_inputs.keys().size() ," inputs...")
	remove_inputs()
	print("finished _disable_plugin")

func _enter_tree() -> void:
	pass
	
func _exit_tree() -> void:
	pass

func add_autoloads() -> void:
	for autoload_path: String in AUTOLOADS.keys():
		add_autoload_singleton(AUTOLOADS[autoload_path], autoload_path)

func remove_autoloads() -> void:
	for autoload_name: String in AUTOLOADS.values():
		remove_autoload_singleton(autoload_name)

func add_inputs() -> void:
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
		print("adding input: ", input_name)
		ProjectSettings.set_setting("input/" + input_name, input)
		is_any_changed = true
		
		
	print("saving project settings (dirty: ", str(is_any_changed)+ ")")

	ProjectSettings.save()
	if TTSetup.RESTART_EDITOR_ON_PLUGIN_TOGGLED:
		EditorInterface.restart_editor(true)
	
func remove_inputs() -> void:
	var is_any_changed: bool = false
	var ttsetup: TTSetup = TTSetup.new()
	for input_name in ttsetup.default_inputs.keys():
		if !ProjectSettings.has_setting("input/" + input_name):
			print("TalkieTalkie.remove_inputs(): ProjectSettings does not have input '", input_name, "'. Skipped removing this input.")
			continue
			
		print("removing input: ", input_name)
		ProjectSettings.set_setting("input/" + input_name, null)
		is_any_changed = true
		
	if !is_any_changed:
		return

	print("saving project settings (dirty: ", str(is_any_changed)+ ")")
	ProjectSettings.save()
	if TTSetup.RESTART_EDITOR_ON_PLUGIN_TOGGLED:
		EditorInterface.restart_editor(true)
