class_name SideWindow
extends Window

signal input_received(event: InputEvent)

enum EnableOptions {
	ALWAYS,
	IF_SECOND_SCREEN_EXISTS,
	NEVER
}

@export var enabled: EnableOptions = EnableOptions.ALWAYS

func _enter_tree() -> void:
	if enabled == EnableOptions.NEVER || (enabled == EnableOptions.IF_SECOND_SCREEN_EXISTS && DisplayServer.get_screen_count() < 2):
		queue_free()
	
func _ready() -> void:
	title = ProjectSettings.get_setting("application/config/name", "TalkieTalkie") + " [SideWindow]"

func _input(event: InputEvent) -> void:
	input_received.emit(event)
