class_name SideWindowBase extends Node
## Handles creation and removal of the side window.

static var SIDE_WINDOW_SCENE: PackedScene = load(TTSetup.get_plugin_path() + "/engine/side_window/side_window.tscn")

@export_category("SideWindow Settings")
@export var preview_theme_settings: PreviewThemeSettings

## Overwrites the default settings for the side window's time ui, if set.
@export var time_view_settings: TimeViewSettings

@export_category("Node References")
@export var presentation: Presentation
@export var ui: UI

var _side_window: SideWindow
var is_side_window_active: bool = false
var _is_windows_embedded = true
var _is_enabled_by_config: bool

func _enter_tree() -> void:
	_is_enabled_by_config = TTPreferences.tt_config.get_enable_side_window_bool()
	check_second_window_embedded()
	if TTPreferences.tt_config.open_sw_on_start:
		set_side_window_active(true)
	update_state_in_helper()
	
	TTSlideHelper.restore_side_window.connect(_on_restore_side_window)
	#DisplayServer.screenchanged.connect(update_state_in_helper)

func set_side_window_active(is_active_new: bool) -> void:
	if is_active_new && !is_side_window_allowed():
		return
	
	is_side_window_active = is_active_new
	update_state_in_helper()
	
	if is_active_new:
		_side_window = SIDE_WINDOW_SCENE.instantiate() as SideWindow
		add_child(_side_window)
		_side_window.close_requested.connect(_on_close_requested)
		_side_window.input_received.connect(presentation._on_side_window_input_received)
		configure_side_window(_side_window)
		_side_window.set_as_ui_parent(true, ui)
		if TTPreferences.side_window_layout_settings == null:
			set_initial_side_window_position()
	else:
		_close_side_window()

func configure_side_window(side_window: SideWindow) -> void:
	if preview_theme_settings == null:
		preview_theme_settings = PreviewThemeSettings.new()
	_side_window.side_window_ui.set_preview_theme_settings(preview_theme_settings)
	side_window.side_window_ui.time_view.override_settings(time_view_settings)

func update_state_in_helper() -> void:
	TTSlideHelper.is_side_window_restorable = is_side_window_restorable()
	TTSlideHelper.side_window_settings_updated.emit()

func _on_close_requested() -> void:
	if  TTPreferences.tt_config.quit_on_close_sw:
		get_tree().quit()
	else:
		set_side_window_active(false)
	
func _close_side_window() -> void:
	_side_window.set_as_ui_parent(false, ui)
	_side_window.queue_free()
	_side_window = null

func _on_restore_side_window() -> void:
	if !is_side_window_active:
		set_side_window_active(true)
	else:
		_side_window.center_to_current_screen()

func is_side_window_restorable() -> bool:
	return !is_side_window_active && is_side_window_allowed()

func check_second_window_embedded() -> void:
	if ProjectSettings.get("display/window/subwindows/embed_subwindows") as bool == true:
		push_warning("Your project settings embeds subwindows. To enable the preview window, set 'display/window/subwindows/embed_subwindows' to false.")
		_is_windows_embedded = true
		return
		
	_is_windows_embedded = false
	
func is_side_window_allowed() -> bool:
	return _is_enabled_by_config && !Util.is_web() && !_is_windows_embedded
	
func set_initial_side_window_position() -> void:
	var num_screens: int = DisplayServer.get_screen_count()
	if num_screens < 2:
		_side_window.center_to_current_screen()
		return
		
	var current_screen_id: int = DisplayServer.window_get_current_screen(get_window().get_window_id())
	var next_screen: int = (current_screen_id + 1) % num_screens
	
	DisplayServer.window_set_current_screen(next_screen, _side_window.get_window_id())
	_side_window.center_to_current_screen()
	
	#var : int = DisplayServer.get_screen_from_rect(Rect2(position, size_with_deco))
