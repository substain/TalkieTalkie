class_name SideWindowBase extends Node
## Handles creation and removal of the side window.

enum EnableOptions {
	ALWAYS,
	IF_SECOND_SCREEN_EXISTS,
	NEVER
}

static var SIDE_WINDOW_SCENE: PackedScene = load(TTSetup.get_plugin_path() + "/engine/side_window/side_window.tscn")

@export_category("SideWindow Settings")
@export var enabled: EnableOptions = EnableOptions.IF_SECOND_SCREEN_EXISTS
@export var quit_on_close: bool = false
@export var preview_theme_settings: PreviewThemeSettings

## Overwrites the default settings for the side window's time ui, if set.
@export var time_view_settings: TimeViewSettings

@export_category("Node References")
@export var presentation: Presentation
@export var ui: UI

var _side_window: SideWindow
var is_side_window_active: bool = false

func _enter_tree() -> void:
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
	if quit_on_close:
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

func is_side_window_allowed() -> bool:
	return enabled == EnableOptions.ALWAYS || (enabled == EnableOptions.IF_SECOND_SCREEN_EXISTS && DisplayServer.get_screen_count() >= 2)
