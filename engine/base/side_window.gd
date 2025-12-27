class_name SideWindow
extends Window

signal input_received(event: InputEvent)

enum EnableOptions {
	ALWAYS,
	IF_SECOND_SCREEN_EXISTS,
	NEVER
}

@export var enabled: EnableOptions = EnableOptions.ALWAYS
@export var quit_on_close: bool = true
@export var ui: UI
@export_category("internal nodes")
@export var side_window_ui: SideWindowUI

var has_ui: bool = false

func _enter_tree() -> void:
	if enabled == EnableOptions.NEVER || (enabled == EnableOptions.IF_SECOND_SCREEN_EXISTS && DisplayServer.get_screen_count() < 2):
		queue_free()
	
func _ready() -> void:
	if is_queued_for_deletion():
		return
	
	title = ProjectSettings.get_setting("application/config/name", "TalkieTalkie") + " [SideWindow]"
	set_as_ui_parent(true)
	
func _input(event: InputEvent) -> void:
	input_received.emit(event)

func _on_close_requested() -> void:
	if quit_on_close:
		get_tree().quit()
	else:
		set_as_ui_parent(false)
		#hide()
		queue_free()
		
func set_as_ui_parent(is_ui_parent_new: bool) -> void:
	
	# ignore this warning since both values are nodes
	@warning_ignore("incompatible_ternary")
	var target_parent: Node = side_window_ui if is_ui_parent_new else ui
	
	reparent_ui_children(target_parent)
	has_ui = is_ui_parent_new
		
func reparent_ui_children(target: Node) -> void:
	for child: Node in ui.side_window_nodes:
		if !child is Control:
			continue
		var ctrl_child: Control = child as Control
		ctrl_child.call_deferred("reparent", target, false)
