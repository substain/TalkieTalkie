class_name SideWindow
extends Window

signal input_received(event: InputEvent)

const MIN_ALLOWED_VISIBLE_PIXEL: int = 200

enum EnableOptions {
	ALWAYS,
	IF_SECOND_SCREEN_EXISTS,
	NEVER
}

@export_category("internal nodes")
@export var side_window_ui: SideWindowUI
@export var update_settings_timer: Timer

var enabled: EnableOptions = EnableOptions.ALWAYS
var quit_on_close: bool = true
var side_window_layout_settings: SideWindowLayoutSettings
var ignore_next_signal_update: bool = false

func _ready() -> void:	
	title = ProjectSettings.get_setting("application/config/name", "TalkieTalkie") + " [SideWindow]"
	on_resize.call_deferred()
	
	load_side_window_layout_settings()
	side_window_ui.preview_layout_settings_updated.connect(_on_preview_layout_settings_updated)

func on_resize() -> void:
	if !is_node_ready():
		return
	
	side_window_ui.on_resize(size)
	update_side_window_settings()
			
func _input(event: InputEvent) -> void:
	input_received.emit(event)

func set_as_ui_parent(is_ui_parent_new: bool, ui: UI) -> void:
	var target_parent: Node = side_window_ui as Node if is_ui_parent_new else ui as Node
	
	reparent_ui_children(target_parent, ui)
	
func reparent_ui_children(target: Node, ui: UI) -> void:
	for child: Node in ui.side_window_nodes:
		child.call_deferred("reparent", target, false)

func _on_size_changed() -> void:
	on_resize() 

func update_side_window_settings() -> void:
	# ensure we don't save with continuous changes
	if !is_instance_valid(update_settings_timer):
		return
	
	if !update_settings_timer.is_inside_tree():
		update_settings_timer.autostart = true
		return
		
	update_settings_timer.start()

func _on_update_settings_timer_timeout() -> void:
	save_side_window_layout_settings()
	
func save_side_window_layout_settings() -> void:
	update_settings_by_current_values()
	Preferences.set_side_window_layout_settings(side_window_layout_settings)
	
func load_side_window_layout_settings() -> void:
	if Preferences.side_window_layout_settings == null || !debug_is_valid(Preferences.side_window_layout_settings):
		side_window_layout_settings = SideWindowLayoutSettings.new()
		update_settings_by_current_values()
	else:
		side_window_layout_settings = Preferences.side_window_layout_settings

	var matching_screen_id: int = DisplayServer.get_screen_from_rect(Rect2(side_window_layout_settings.side_window_pos, side_window_layout_settings.side_window_size))
	if matching_screen_id == -1:
		var max_screen_id: int = DisplayServer.get_screen_count()-1
		var target_screen: int = side_window_layout_settings.screen_index

		if target_screen > max_screen_id:
			target_screen = max_screen_id

		matching_screen_id = target_screen
	
	current_screen = matching_screen_id
	var target_pos: Vector2i = side_window_layout_settings.side_window_pos
	size = side_window_layout_settings.side_window_size.min(DisplayServer.screen_get_usable_rect(current_screen).size)
	position = constrain_to_bounds(target_pos, get_size_with_deco(), DisplayServer.screen_get_usable_rect(matching_screen_id))
	side_window_ui.load_side_window_layout_settings(side_window_layout_settings.preview_layout_settings_by_rel_index)
	
func debug_is_valid(side_window_layout_settings_to_test: SideWindowLayoutSettings) -> bool:
	return side_window_layout_settings_to_test.preview_layout_settings_by_rel_index.size() == 3
	
func update_settings_by_current_values() -> void:
	side_window_layout_settings.side_window_pos = position
	side_window_layout_settings.side_window_size = size
	if current_screen != -1:
		side_window_layout_settings.screen_index = current_screen

func _on_preview_layout_settings_updated(rel_index: int, preview_layout_settings: PreviewLayoutSettings) -> void:
	side_window_layout_settings.preview_layout_settings_by_rel_index[rel_index] = preview_layout_settings
	update_side_window_settings()
	
func _notification(what: int) -> void:	
	if !is_node_ready():
		return
		
	if what == NOTIFICATION_WM_POSITION_CHANGED:
		update_side_window_settings()
		
	if what == NOTIFICATION_WM_SIZE_CHANGED:
		on_resize()


func center_to_current_screen() -> void:
	var size_with_deco: Vector2i = get_size_with_deco()
	var target_screen: int = DisplayServer.get_screen_from_rect(Rect2(position, size_with_deco))
	var target_screen_center: Vector2i = DisplayServer.screen_get_position(target_screen) + (DisplayServer.screen_get_size(target_screen) / 2)
	position = target_screen_center - size_with_deco/2
	
func get_size_with_deco() -> Vector2:
	return DisplayServer.window_get_size_with_decorations(get_window_id())

static func constrain_to_bounds(target_position: Vector2, target_size: Vector2, bounds: Rect2, min_allowed_pixels: int = MIN_ALLOWED_VISIBLE_PIXEL) -> Vector2:
	return target_position.clamp(bounds.position - target_size + Vector2.ONE * min_allowed_pixels, bounds.end - Vector2.ONE * min_allowed_pixels)
