class_name SideWindow
extends Window

signal input_received(event: InputEvent)

enum EnableOptions {
	ALWAYS,
	IF_SECOND_SCREEN_EXISTS,
	NEVER
}

@export var enabled: EnableOptions = EnableOptions.ALWAYS
@onready var ui: UI = $"../UI" #TODO test reparent
@onready var side_window_ui: SideWindowUI = $SideWindowUI

func _enter_tree() -> void:
	if enabled == EnableOptions.NEVER || (enabled == EnableOptions.IF_SECOND_SCREEN_EXISTS && DisplayServer.get_screen_count() < 2):
		queue_free()
	
func _ready() -> void:
	title = ProjectSettings.get_setting("application/config/name", "TalkieTalkie") + " [SideWindow]"
	for child: Node in ui.side_window_nodes:
		if !child is Control:
			continue
		var ctrl_child: Control = child as Control
		
		#reparent_control_with_anchors(ctrl_child)
		ctrl_child.call_deferred("reparent", side_window_ui, false) #TODO
		
		if ctrl_child.has_method("update_local_hidden_dir"):
			ctrl_child.update_local_hidden_dir()

func reparent_control_with_anchors(ctrl: Control) -> void:
	var anchor_top: float = ctrl.anchor_top
	var anchor_bot: float = ctrl.anchor_bottom
	var anchor_left: float = ctrl.anchor_left
	var anchor_right: float = ctrl.anchor_right
	ctrl.call_deferred("reparent", side_window_ui, false) #TODO
	ctrl.anchor_bottom = anchor_bot
	ctrl.anchor_bottom = anchor_top
	ctrl.anchor_left = anchor_left
	ctrl.anchor_right = anchor_right

func _input(event: InputEvent) -> void:
	input_received.emit(event)
