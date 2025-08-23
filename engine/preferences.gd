class_name PreferencesClass extends Node
		
enum AudioType
{
	MASTER,
	MUSIC,
	SFX,
}

signal language_changed

const FULLSCREEN_IS_BORDERLESS: bool = true
const SETTINGS_PATH: String = "user://preferences.save"

var overall_volume: float = 0.75
var music_volume: float = 1
var sfx_volume: float = 1
var language: StringName = &"en"
var fullscreen_active: bool = false

var last_slide: int = 0
var last_presentation_scene: StringName = &""

func _ready() -> void:
	load_from_file()
	apply_values()
	
func apply_values() -> void:
	set_bus_volume(AudioType.MASTER, overall_volume)
	set_bus_volume(AudioType.MUSIC, music_volume)
	set_bus_volume(AudioType.SFX, sfx_volume)
	TranslationServer.set_locale(language)
	set_fullscreen(fullscreen_active)

func reset(do_save: bool = true) -> void:

	set_overall_volume(0.75, false)
	set_music_volume(1, false)
	set_sfx_volume(1, false)
	set_language("en", false)
	set_fullscreen_active(false, false)
	set_presentation_progress(0, &"", false)

	if do_save:
		save_to_file()
		
		
func save_to_file() -> void:
	var settings_file_access: FileAccess = FileAccess.open(SETTINGS_PATH, FileAccess.WRITE)
	var save_dict: Dictionary = {
		"overall_volume": overall_volume,
		"music_volume": music_volume,
		"sfx_volume": sfx_volume,
		"language": language,
		"fullscreen_active": fullscreen_active,
		"last_slide": last_slide,
		"last_presentation_scene": last_presentation_scene
	}
	
	var json_string: String = JSON.stringify(save_dict)
	settings_file_access.store_line(json_string)
	
func load_from_file() -> void:
	if not FileAccess.file_exists(SETTINGS_PATH):
		return # We don't have a file to load.

	var save_game: FileAccess = FileAccess.open(SETTINGS_PATH, FileAccess.READ)
	while save_game.get_position() < save_game.get_length():
		var json_string: String = save_game.get_line()
		var json: JSON = JSON.new()
		var parseResult: Error = json.parse(json_string)
		if not parseResult == OK:
			push_warning("Preferences: JSON Parse Error: '" + json.get_error_message() + "'  at line " + str(json.get_error_line()))
			continue
		var save_dict: Dictionary = json.get_data()
##
		if save_dict.has("overall_volume"):
			overall_volume = save_dict["overall_volume"]
		if save_dict.has("music_volume"):
			music_volume = save_dict["music_volume"]
		if save_dict.has("sfx_volume"):
			sfx_volume = save_dict["sfx_volume"]
		if save_dict.has("language"):
			language = save_dict["language"]
		if save_dict.has("fullscreen_active"):
			fullscreen_active = save_dict["fullscreen_active"]
		if save_dict.has("last_slide"):
			last_slide = save_dict["last_slide"]
		if save_dict.has("last_presentation_scene"):
			last_presentation_scene = save_dict["last_presentation_scene"]
			
func set_overall_volume(vol_new: float, do_save: bool = true) -> void:
	overall_volume = vol_new
	if do_save:
		save_to_file()

func set_music_volume(vol_new: float, do_save: bool = true) -> void:
	music_volume = vol_new
	if do_save:
		save_to_file()

func set_sfx_volume(vol_new: float, do_save: bool = true) -> void:
	sfx_volume = vol_new
	if do_save:
		save_to_file()

func set_language(langNew: StringName, do_save: bool = true) -> void:
	language = langNew
	language_changed.emit()
	if do_save:
		save_to_file()

func set_fullscreen_active(fs_active_new: bool, do_save: bool = true) -> void:
	fullscreen_active = fs_active_new
	if do_save:
		save_to_file()

func set_presentation_progress(last_slide_new: int, last_presentation_scene_new: StringName, do_save: bool = true) -> void:
	last_slide = last_slide_new
	last_presentation_scene = last_presentation_scene_new
	if do_save:
		save_to_file()

static func set_bus_volume(audio_type: AudioType, volume_linear: float) -> void:
	var vol_to_use: float = volume_linear
	if vol_to_use <= 0:
		vol_to_use = 0.00001
	var bus_index: int = AudioServer.get_bus_index(get_audio_type_string(audio_type))	
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(vol_to_use))
	
static func set_bus_muted(audio_type: AudioType, is_muted_new: bool) -> void:
	var bus_index: int = AudioServer.get_bus_index(get_audio_type_string(audio_type))
	AudioServer.set_bus_mute(bus_index, is_muted_new)
	
static func is_bus_muted(audio_type: AudioType) -> bool:
	var bus_index: int = AudioServer.get_bus_index(get_audio_type_string(audio_type))
	return AudioServer.is_bus_mute(bus_index)
	
static func get_audio_type_string(audio_type: AudioType) -> String:
	match audio_type:
		AudioType.MUSIC:
			return "Music"
		AudioType.SFX:
			return "SoundEffects"
	return "Master"
	
static func set_fullscreen(is_fullscreen: bool) -> void:
	if is_fullscreen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, FULLSCREEN_IS_BORDERLESS)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
