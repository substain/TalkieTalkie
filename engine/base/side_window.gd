class_name SideWindow
extends Window

signal input_received(event: InputEvent)

enum EnableOptions {
	ALWAYS,
	IF_SECOND_SCREEN_EXISTS,
	NEVER
}

var enabled: EnableOptions = EnableOptions.ALWAYS
var quit_on_close: bool = true
@export_category("internal nodes")
@export var side_window_ui: SideWindowUI

func _ready() -> void:	
	title = ProjectSettings.get_setting("application/config/name", "TalkieTalkie") + " [SideWindow]"
	on_resize.call_deferred()

func on_resize() -> void:
	side_window_ui.on_resize(size)
	
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

func set_preview_window_resize_keep_rel_pos(keep_rel_pos_new: bool) -> void:
	side_window_ui.set_preview_window_resize_keep_rel_pos(keep_rel_pos_new)
		
func set_preview_window_resize_scale(do_scale_new: bool) -> void:
	side_window_ui.set_preview_window_resize_scale(do_scale_new)
