class_name TalkieSetup
extends RefCounted

## Automatically restart Godot if the Plugin is enabled or disabled to refresh the input map.
## You can set this to false if you don't need an updated input map with the default inputs below added/removed within the same session.
## https://github.com/godotengine/godot/issues/25865
const RESTART_EDITOR_ON_PLUGIN_TOGGLED: bool = false

## Fallback for builds in case the plugin.cfg is not exported
const CURRENT_VERSION: String = "0.0.93" 

## The inputs used by this addon. These will be added to the input map when the addon is activated. 
## You can change these in the input map in the project settings when the addon is active.
static func get_inputs() -> Dictionary[String, Array]:
	return {
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
	
## A placeholder for internal paths. Will be replaced with the path of the addon (see replace_addon_path())
const ADDON_PLACEHOLDER: String = "ttaddon://"

static var instance: TalkieSetup
static var addon_path: String = ""

static func get_addon_path() -> String:
	if addon_path.is_empty():
		addon_path = (TalkieSetup.new().get_script() as Script).resource_path.get_base_dir()
		
	return addon_path

static func replace_addon_path(ppstr: String) -> String:
	return ppstr.replace(ADDON_PLACEHOLDER, get_addon_path() + "/")

static func input_key(key_code: Key) -> InputEventKey:
	var in_event_key: InputEventKey = InputEventKey.new()
	in_event_key.keycode = key_code
	return in_event_key

static func input_mouse(mouse_button: MouseButton) -> InputEventMouse:
	var in_event_mouse: InputEventMouseButton = InputEventMouseButton.new()
	in_event_mouse.button_index = mouse_button
	return in_event_mouse
