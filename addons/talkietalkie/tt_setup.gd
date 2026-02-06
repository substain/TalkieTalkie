@tool
class_name TTSetup
extends RefCounted

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
var default_inputs: Dictionary[String, Array] = {
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
	
## A placeholder for internal paths. Will be replaced with PLUGIN_ROOT 
const PLUGIN_PLACEHOLDER: String = "ttplugin://"

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
