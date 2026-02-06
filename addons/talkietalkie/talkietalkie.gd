@tool
class_name TalkieTalkie
extends EditorPlugin

#region modifiable plugin variables

## Used for preloaded assets. 
## Update this if you have changed the name or location of this addon's directory.
const PLUGIN_ROOT: String = "res://addons/talkietalkie/"

## Automatically restart Godot if the Plugin is enabled or disabled to refresh the input map.
## You can set this to false if you don't need an updated input map with the default inputs below added/removed.
const RESTART_EDITOR_ON_PLUGIN_TOGGLED: bool = true

## The audio bus that will be affected by the audio slider, if the bus exists. 
## Update this if you want to target a different bus.
const TARGET_AUDIO_BUS: StringName = &"Master"

## If enabled, unhandled left click input events trigger a slide continue as well.
## You can set this to false if you want to disable this behavior
const CONTINUE_ON_UNHANDLED_LEFT_CLICK: bool = true

## The inputs used by this plugin. These will be added to the input map when the plugin is activated. 
## You can change these in the input map in the project settings when the plugin is active.
var DEFAULT_INPUTS: Dictionary[String, Array] = {
	"tt_continue": [input_key(KEY_RIGHT), input_key(KEY_DOWN), input_key(KEY_SPACE)],
	"tt_back": [input_key(KEY_LEFT), input_key(KEY_UP), input_key(KEY_PAGEUP),input_mouse(MOUSE_BUTTON_WHEEL_UP)],
	"tt_skip_slide": [input_key(KEY_PAGEDOWN),input_mouse(MOUSE_BUTTON_WHEEL_DOWN)],
	"tt_draw_pointer_1": [input_key(KEY_CTRL)],
	"tt_draw_pointer_2": [input_key(KEY_ALT)],
	"tt_move_left": [input_key(KEY_A)],
	"tt_move_right": [input_key(KEY_D)],
	"tt_move_up": [input_key(KEY_W)],
	"tt_move_down": [input_key(KEY_S)],
	"tt_toggle_ui": [input_key(KEY_F1), input_key(KEY_TAB), input_mouse(MOUSE_BUTTON_RIGHT)],
	"tt_restore_side_window": [input_key(KEY_F11)],
	"tt_fullscreen": [input_key(KEY_F12)],
	"tt_quit": [input_key(KEY_ESCAPE)],
}
#endregion



## Autoloads used by the plugin
const AUTOLOADS: Dictionary[String,String] = {
	PLUGIN_ROOT + "engine/autoload/tt_preferences.gd": "TTPreferences",
	PLUGIN_ROOT + "engine/autoload/tt_slide_helper.gd": "TTSlideHelper"
}

## A placeholder for internal paths. Will be replaced with PLUGIN_ROOT 
const PLUGIN_PLACEHOLDER: String = "ttplugin://"

func _enable_plugin() -> void:
	print_rich("[color='557778'][b]Thank you for using [img]"+PLUGIN_ROOT+"style/tt_icon.svg[/img][b][color='112233']TalkieTalkie[/color][/b]. If you need help, have a look at the README.md[/color]") # Prints "Hello world!", in green with a bold font.
	print("add autoloads...")
	add_autoloads()
	print("add inputs...")
	add_inputs()
	
func _disable_plugin() -> void:
	print("remove autoloads...")
	remove_autoloads()
	print("remove inputs...")
	remove_inputs()
			
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
	for input_name in DEFAULT_INPUTS.keys():
		if ProjectSettings.has_setting("input/" + input_name):
			print("TalkieTalkie.add_inputs(): ProjectSettings already has an input '", input_name, "'. Skipped adding this input.")
			continue
		var input: Dictionary = {
			"deadzone": 0.5,
			"events": DEFAULT_INPUTS[input_name]
		}
		ProjectSettings.set_setting("input/" + input_name, input)
		is_any_changed = true
		
	ProjectSettings.save()
	if RESTART_EDITOR_ON_PLUGIN_TOGGLED:
		EditorInterface.restart_editor(true)
	
func remove_inputs() -> void:
	var is_any_changed: bool = false
	for input_name in DEFAULT_INPUTS.keys():
		if !ProjectSettings.has_setting("input/" + input_name):
			print("TalkieTalkie.remove_inputs(): ProjectSettings does not have input '", input_name, "'. Skipped removing this input.")
			continue
			
		ProjectSettings.set_setting("input/" + input_name, null)
		is_any_changed = true
	if !is_any_changed:
		return
	
	ProjectSettings.save()
	if RESTART_EDITOR_ON_PLUGIN_TOGGLED:
		EditorInterface.restart_editor(true)
	
static func replace_plugin_path(str: String) -> String:
	return str.replace(PLUGIN_PLACEHOLDER, PLUGIN_ROOT)

static func input_key(key_code: Key) -> InputEventKey:
	var in_event_key: InputEventKey = InputEventKey.new()
	in_event_key.keycode = key_code
	return in_event_key

static func input_mouse(mouse_button: MouseButton) -> InputEventMouse:
	var in_event_mouse: InputEventMouseButton = InputEventMouseButton.new()
	in_event_mouse.button_index = mouse_button
	return in_event_mouse
