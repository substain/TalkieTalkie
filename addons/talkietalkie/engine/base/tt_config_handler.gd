class_name TTConfigHandler
extends Object

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

class Config:
	
	# General
	var remember_slide: bool
	var stop_auto_slideshow_on_continue: bool
	var continue_on_unhandled_left_click: bool
	
	# UI
	var open_ui_on_startup: SystemConditional
	var show_toggle_ui_button: SystemConditional
	var enable_control_bar: bool
	var enable_tabnav_bar: bool
	var enable_settings: bool
	var enable_about_window_links: bool

	# TabNavigation
	var max_visible_tabnav_elements: int
	var tabnav_width_on_scroll: int
	var tabnav_indicator: TabNavIndication
	var tabnav_indicator_max_length: int

	# Settings
	var show_translation_control: bool
	var show_audio_controls: bool
	var target_audio_bus: StringName
	
	# SideWindow
	var enable_side_window: WindowConditional
	var open_sw_on_start: bool
	var quit_on_close_sw: bool
	
	static func get_default() -> Config:
		var default_config: Config = Config.new()
		default_config.remember_slide = false
		default_config.stop_auto_slideshow_on_continue = true
		default_config.continue_on_unhandled_left_click = true
		default_config.open_ui_on_startup = SystemConditional.ON_MOBILE
		default_config.show_toggle_ui_button = SystemConditional.ON_MOBILE
		default_config.enable_control_bar = true
		default_config.enable_tabnav_bar = true
		default_config.enable_settings = true
		default_config.enable_about_window_links = true
		default_config.max_visible_tabnav_elements = false
		default_config.tabnav_width_on_scroll = 400
		default_config.tabnav_indicator = TabNavIndication.NONE
		default_config.tabnav_indicator_max_length = 3
		default_config.show_translation_control = true
		default_config.show_audio_controls = true
		default_config.target_audio_bus = &"Master"
		default_config.enable_side_window = WindowConditional.ON_MULTIPLE_MONITORS
		default_config.open_sw_on_start = false
		default_config.quit_on_close_sw = true

		return default_config
		
		
	func get_open_ui_on_startup_bool() -> bool:
		return is_system_conditional_true(open_ui_on_startup)
		
	func get_show_toggle_ui_button_bool() -> bool:
		return is_system_conditional_true(show_toggle_ui_button)
		
	func get_enable_side_window_bool() -> bool:
		return is_window_conditional_true(enable_side_window)

	static func is_system_conditional_true(system_conditional: SystemConditional) -> bool:
		return system_conditional == SystemConditional.TRUE || (system_conditional == SystemConditional.ON_MOBILE && Util.is_mobile())
		
	static func is_window_conditional_true(window_conditional: WindowConditional) -> bool:
		return window_conditional == WindowConditional.TRUE || (window_conditional == WindowConditional.ON_MULTIPLE_MONITORS && DisplayServer.get_screen_count() >= 2)
	
## The file path for the configuration file below the addon path. This will usually be addons/talkietalkie/ADDON_CFG_PATH
const ADDON_CFG_PATH: String = "/tt_config.cfg"

static func load_config() -> Config:
	# default configuration
	var config: Config = Config.get_default()

	var default_filepath: String = TTSetup.get_plugin_path() + ADDON_CFG_PATH

	var config_file: ConfigFile = get_config_file(default_filepath)
	if config_file == null:
		push_warning("TalkieTalkie: Could not determine config file. Using default configuration.")
		return config

	# loaded configuration
	_update_config_from_cfg_file(config, config_file)

	return config
	
static func _update_config_from_cfg_file(config: Config, config_file: ConfigFile) -> void:

	# General
	var remember_slide: String = _load_value(config_file, "General", "remember_slide")
	if !remember_slide.is_empty():
		config.remember_slide = str_to_var(remember_slide)
	
	var stop_auto_slideshow_on_continue: String = _load_value(config_file, "General", "stop_auto_slideshow_on_continue")
	if !stop_auto_slideshow_on_continue.is_empty():
		config.stop_auto_slideshow_on_continue = str_to_var(stop_auto_slideshow_on_continue)
	
	var continue_on_unhandled_left_click: String = _load_value(config_file, "General", "continue_on_unhandled_left_click")
	if !continue_on_unhandled_left_click.is_empty():
		config.continue_on_unhandled_left_click = str_to_var(continue_on_unhandled_left_click)

	var open_ui_on_startup: String = _load_value(config_file, "UI", "open_ui_on_startup")
	if !open_ui_on_startup.is_empty():
		config.open_ui_on_startup = _to_system_conditional(open_ui_on_startup)

	var show_toggle_ui_button: String = _load_value(config_file, "UI", "show_toggle_ui_button")
	if !show_toggle_ui_button.is_empty():
		config.show_toggle_ui_button = _to_system_conditional(show_toggle_ui_button)

	var enable_control_bar: String = _load_value(config_file, "UI", "enable_control_bar")
	if !enable_control_bar.is_empty():
		config.enable_control_bar = str_to_var(enable_control_bar)


	var enable_tabnav_bar: String = _load_value(config_file, "UI", "enable_tabnav_bar")
	if !enable_tabnav_bar.is_empty():
		config.enable_tabnav_bar = str_to_var(enable_tabnav_bar)


	var enable_settings: String = _load_value(config_file, "UI", "enable_settings")
	if !enable_settings.is_empty():
		config.enable_settings = str_to_var(enable_settings)


	var enable_about_window_links: String = _load_value(config_file, "UI", "enable_about_window_links")
	if !enable_about_window_links.is_empty():
		config.enable_about_window_links = str_to_var(enable_about_window_links)

	var max_visible_tabnav_elements: String = _load_value(config_file, "TabNavigation", "max_visible_tabnav_elements")
	if !max_visible_tabnav_elements.is_empty():
		config.max_visible_tabnav_elements = str_to_var(max_visible_tabnav_elements)
#
	var tabnav_width_on_scroll: String = _load_value(config_file, "TabNavigation", "tabnav_width_on_scroll")
	if !tabnav_width_on_scroll.is_empty():
		config.tabnav_width_on_scroll = str_to_var(tabnav_width_on_scroll)
		
	var tabnav_indicator: String = _load_value(config_file, "TabNavigation", "tabnav_indicator")
	if !tabnav_indicator.is_empty():
		config.tabnav_indicator = _to_tab_nav_indication(tabnav_indicator)
		
	var tabnav_indicator_max_length: String = _load_value(config_file, "TabNavigation", "tabnav_indicator_max_length")
	if !tabnav_indicator_max_length.is_empty():
		config.tabnav_indicator_max_length = str_to_var(tabnav_indicator_max_length)

	var show_translation_control: String = _load_value(config_file, "Settings", "show_translation_control")
	if !show_translation_control.is_empty():
		config.show_translation_control = str_to_var(show_translation_control)


	var show_audio_controls: String = _load_value(config_file, "Settings", "show_audio_controls")
	if !show_audio_controls.is_empty():
		config.show_audio_controls = str_to_var(show_audio_controls)
		
	var target_audio_bus: String = _load_value(config_file, "Settings", "target_audio_bus")
	if !target_audio_bus.is_empty():
		config.target_audio_bus = target_audio_bus

	var enable_side_window: String = _load_value(config_file, "SideWindow", "enable_side_window")
	if !enable_side_window.is_empty():
		config.enable_side_window = _to_window_conditional(enable_side_window)
		
	var open_sw_on_start: String = _load_value(config_file, "SideWindow", "open_sw_on_start")
	if !open_sw_on_start.is_empty():
		config.open_sw_on_start = str_to_var(open_sw_on_start)
		
	var quit_on_close_sw: String = _load_value(config_file, "SideWindow", "quit_on_close_sw")
	if !quit_on_close_sw.is_empty():
		config.quit_on_close_sw = str_to_var(quit_on_close_sw)

static func _load_value(config: ConfigFile, config_section: String, config_value: String) -> String:
	var cfg_value: Variant = config.get_value(config_section, config_value, "")
	if !cfg_value is String:
		cfg_value = var_to_str(config.get_value(config_section, config_value, ""))
	if cfg_value.strip_edges().is_empty():
		return ""
	return cfg_value
	
static func get_config_file(path: String) -> ConfigFile:
	if !FileAccess.file_exists(path):
		push_warning("TalkieTalkie: Could not load TT configuration file from '", path, "', file does not exist.")
		return null

	var config_file: ConfigFile = ConfigFile.new()
	var status: Error = config_file.load(path)
	if status != OK:
		push_warning("TalkieTalkie: Could not load TT configuration file from '", path, "', error was: ", status)
		return null
	
	return config_file

static func _to_system_conditional(nrd_string: String) -> SystemConditional:
	if nrd_string.to_lower().strip_edges() == "true":
		return SystemConditional.TRUE
	elif nrd_string.to_lower().strip_edges() == "on_mobile":
		return SystemConditional.ON_MOBILE

	return SystemConditional.FALSE

static func _to_window_conditional(ado_string: String) -> WindowConditional:
	if ado_string.to_lower().strip_edges() == "true":
		return WindowConditional.TRUE
	elif ado_string.to_lower().strip_edges() == "on_multiple_monitors":
		return WindowConditional.ON_MULTIPLE_MONITORS

	return WindowConditional.FALSE
	
static func _to_tab_nav_indication(tni_string: String) -> TabNavIndication:
	if tni_string.to_lower().strip_edges() == "number":
		return TabNavIndication.NUMBER
	elif tni_string.to_lower().strip_edges() == "slide_title":
		return TabNavIndication.SLIDE_TITLE

	return TabNavIndication.NONE
