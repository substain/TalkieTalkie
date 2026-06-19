class_name TalkiePreferencesClass extends Node

enum SystemConditional {
	FALSE,
	ON_MOBILE,
	TRUE
}

enum WindowConditional {
	FALSE,
	ON_MULTIPLE_MONITORS,
	TRUE
}

enum TabNavIndication {
	NONE,
	NUMBER,
	SLIDE_TITLE
}

const FULLSCREEN_IS_BORDERLESS: bool = true

const SETTINGS_PATH: String = "user://tt_preferences.save"
static var PLUGIN_CFG_PATH: String = TalkieSetup.get_addon_path()+"/plugin.cfg"

signal language_changed

var preferences_version: StringName
var audio_volume: float = 0.5
var audio_muted: bool = false
var language: StringName = &"en"
var fullscreen_active: bool = false

var side_window_layout_settings: SideWindowLayoutSettings

var last_slide: int = 0
var last_presentation_scene: StringName = &""

#var tt_config: TTConfigHandler.Config

static var TRANSLATION_PATHS: Array[String] = [TalkieSetup.get_addon_path()+ "/localization/talkie_talkie_translation.en.translation", TalkieSetup.get_addon_path()+ "/localization/talkie_talkie_translation.de.translation"]

func _enter_tree() -> void:
	for tr_path: String in TRANSLATION_PATHS:
		var translation: Translation = load(tr_path) as Translation
		TranslationServer.add_translation(translation)
		
	#tt_config = TTConfigHandler.load_config()

func _ready() -> void:
	preferences_version = TalkiePreferencesClass.load_version_from_plugin_cfg()
	load_from_file()
	apply_values()

func apply_values() -> void:
	var show_audio_for_bus: String = ProjectSettings.get_setting("talkietalkie/settings/show_audio_for_bus", "Master") as String
	if !show_audio_for_bus.is_empty():
		set_bus_volume(show_audio_for_bus, audio_volume)	
		set_bus_muted(show_audio_for_bus, audio_muted)
	
	TranslationServer.set_locale(language)
	set_fullscreen(fullscreen_active)

func reset(do_save: bool = true) -> void:
	set_audio_volume(0.75, false)	
	set_audio_muted(false, false)
	set_language("en", false)
	set_fullscreen_active(false, false)
	set_presentation_progress(0, &"", false)

	if do_save:
		save_to_file()

func save_to_file() -> void:
	var settings_file_access: FileAccess = FileAccess.open(SETTINGS_PATH, FileAccess.WRITE)
	var save_dict: Dictionary = {
		"preferences_version": preferences_version,
		"audio_volume": audio_volume,
		"audio_muted": audio_muted,
		"language": language,
		"fullscreen_active": fullscreen_active,
		"last_slide": last_slide,
		"last_presentation_scene": last_presentation_scene,
		"side_window_layout_settings": var_to_str(side_window_layout_settings)
	}

	var json_string: String = JSON.stringify(save_dict)
	settings_file_access.store_line(json_string)
	settings_file_access.close()

func load_from_file() -> void:
	if !FileAccess.file_exists(SETTINGS_PATH):
		return # We don't have a file to load.

	var save_game: FileAccess = FileAccess.open(SETTINGS_PATH, FileAccess.READ)
	while save_game.get_position() < save_game.get_length():
		var json_string: String = save_game.get_line()
		var json: JSON = JSON.new()
		var parse_result: Error = json.parse(json_string)
		if parse_result != OK:
			push_warning("TTPreferences: JSON Parse Error: '" + json.get_error_message() + "'  at line " + str(json.get_error_line()))
			continue
		var save_dict: Dictionary = json.get_data()
##
		if save_dict.has("preferences_version"):
			var loaded_preferences_version: StringName = save_dict["preferences_version"]
			if loaded_preferences_version != preferences_version:
				push_warning("last preferences were saved with a version '"+loaded_preferences_version+"', but the current version is '"+preferences_version+"'. You can usually ignore this warning.")
		if save_dict.has("audio_volume"):
			audio_volume = save_dict["audio_volume"]
		if save_dict.has("audio_muted"):
			audio_muted = save_dict["audio_muted"]
		if save_dict.has("language"):
			language = save_dict["language"]
		if save_dict.has("fullscreen_active"):
			fullscreen_active = save_dict["fullscreen_active"]
		if save_dict.has("last_slide"):
			last_slide = save_dict["last_slide"]
		if save_dict.has("last_presentation_scene"):
			last_presentation_scene = save_dict["last_presentation_scene"]
		if save_dict.has("side_window_layout_settings"):
			side_window_layout_settings = str_to_var(save_dict["side_window_layout_settings"] as String)
		
	save_game.close()
			
func set_audio_volume(vol_new: float, do_save: bool = true) -> void:
	audio_volume = vol_new
	if do_save:
		save_to_file()

func set_audio_muted(is_muted_new: bool, do_save: bool = true) -> void:
	audio_muted = is_muted_new
	if do_save:
		save_to_file()

func set_fullscreen_active(fs_active_new: bool, do_save: bool = true) -> void:
	fullscreen_active = fs_active_new
	if do_save:
		save_to_file()

func set_language(lang_new: StringName, do_save: bool = true) -> void:
	language = lang_new
	language_changed.emit()
	if do_save:
		save_to_file()
		
func set_presentation_progress(last_slide_new: int, last_presentation_scene_new: StringName, do_save: bool = true) -> void:
	last_slide = last_slide_new
	last_presentation_scene = last_presentation_scene_new
	if do_save:
		save_to_file()
		
func set_side_window_layout_settings(side_window_layout_settings_new: SideWindowLayoutSettings, do_save: bool = true) -> void:
	side_window_layout_settings = side_window_layout_settings_new
	if do_save:
		save_to_file()

static func set_bus_volume(audio_bus_name: String, volume_linear: float) -> void:
	if audio_bus_name.is_empty():
		return
	var vol_to_use: float = volume_linear
	if vol_to_use <= 0:
		vol_to_use = 0.00001
	var bus_index: int = AudioServer.get_bus_index(audio_bus_name)
	if bus_index < 0:
		push_warning("No bus with name '" + audio_bus_name + "' exists. Make sure that talkietalkie/settings/show_audio_for_bus is set to a valid bus.")
		return
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(vol_to_use))
	
static func set_bus_muted(audio_bus_name: String, is_muted_new: bool) -> void:
	if audio_bus_name.is_empty():
		return
	var bus_index: int = AudioServer.get_bus_index(audio_bus_name)
	if bus_index < 0:
		push_warning("No bus with name '" + audio_bus_name + "' exists. Make sure that talkietalkie/settings/show_audio_for_bus is set to a valid bus.")
		return
	AudioServer.set_bus_mute(bus_index, is_muted_new)
	
static func is_bus_muted(audio_bus_name: String) -> bool:
	if audio_bus_name.is_empty():
		return true
	var bus_index: int = AudioServer.get_bus_index(audio_bus_name)
	if bus_index < 0:
		push_warning("No bus with name '" + audio_bus_name + "' exists. Make sure that talkietalkie/settings/show_audio_for_bus is set to a valid bus.")
		return true
	return AudioServer.is_bus_mute(bus_index)
	
static func set_fullscreen(is_fullscreen: bool) -> void:
	if is_fullscreen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, FULLSCREEN_IS_BORDERLESS)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
		
static func load_version_from_plugin_cfg() -> String:
	var conf: ConfigFile = ConfigFile.new()
	conf.load(PLUGIN_CFG_PATH)
	return (conf.get_value("plugin", "version", TalkieSetup.CURRENT_VERSION) as String).strip_edges()

static func is_str_as_system_conditional_true(system_conditional_str: String) -> bool:
	return is_system_conditional_true(to_system_conditional(system_conditional_str))

static func is_str_as_window_conditional_true(window_conditional_str: String) -> bool:
	return is_window_conditional_true(to_window_conditional(window_conditional_str))

static func is_system_conditional_true(system_conditional: SystemConditional) -> bool:
	return system_conditional == SystemConditional.TRUE || (system_conditional == SystemConditional.ON_MOBILE && TalkieUtil.is_mobile())
	
static func is_window_conditional_true(window_conditional: WindowConditional) -> bool:
	return window_conditional == WindowConditional.TRUE || (window_conditional == WindowConditional.ON_MULTIPLE_MONITORS && DisplayServer.get_screen_count() >= 2)
	
static func to_system_conditional(sc_string: String) -> SystemConditional:
	if sc_string.to_lower().strip_edges() == "true":
		return SystemConditional.TRUE
	elif sc_string.to_lower().strip_edges() == "on_mobile":
		return SystemConditional.ON_MOBILE

	return SystemConditional.FALSE

static func to_window_conditional(ado_string: String) -> WindowConditional:
	if ado_string.to_lower().strip_edges() == "true":
		return WindowConditional.TRUE
	elif ado_string.to_lower().strip_edges() == "on_multiple_monitors":
		return WindowConditional.ON_MULTIPLE_MONITORS

	return WindowConditional.FALSE
	
static func to_tab_nav_indication(tni_string: String) -> TabNavIndication:
	if tni_string.to_lower().strip_edges() == "number":
		return TabNavIndication.NUMBER
	elif tni_string.to_lower().strip_edges() == "slide_title":
		return TabNavIndication.SLIDE_TITLE

	return TabNavIndication.NONE
