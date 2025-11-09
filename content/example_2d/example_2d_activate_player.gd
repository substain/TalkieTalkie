class_name Example2DActivatePlayer
extends Node

@export var player: Example2DPlayer
@export var slide_for_activation: Slide

@export var target_parent: Node

func _ready() -> void:
	slide_for_activation.activate_slide.connect(_on_target_slide_activated)
	
func _on_target_slide_activated() -> void:
	player.is_player_active = true
	if target_parent != null:
		player.reparent(target_parent)
