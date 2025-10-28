class_name Example2DPlayer
extends CharacterBody2D

const SPEED: float = 850.0
const JUMP_VELOCITY: float = -1200.0
const GRAVITY_MULTIPLIER: float = 6.0
const TELEPORT_MAX_DIST_FACTOR: float = 1.4
const SL_SWITCH_TARGET_POS: float = 0.9


@export var is_player_active: bool = true

@export var spawn_y_offset: float = -900

@export var move_transition: MoveTransition2D

var move_tween: Tween = null
var current_slide: Slide

var slide_switch_movement_x: float = 0.0
var slide_switch_target_pos_x: float = 0.0
	
func _ready() -> void:
	SlideHelper.slide_changed.connect(teleport_to_slide)
	
func _physics_process(delta: float) -> void:	
	# ignore other movement if we're using a move tween
	if is_instance_valid(move_tween) && move_tween.is_running():
		return

	if !is_player_active:
		return

	do_move(delta)

func do_move(delta: float) -> void:
	var has_moved_manually: bool = false
	
	if !is_zero_approx(slide_switch_movement_x) && has_slide_target_pos_reached():
		slide_switch_movement_x = 0.0

	if not is_on_floor():
		velocity += get_gravity() * delta * 6

	if Input.is_action_just_pressed("move_up") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		has_moved_manually = true

	var x_direction: float = Input.get_axis("move_left", "move_right")
	if !is_zero_approx(x_direction):
		#slide_switch_movement_x = 0.0
		has_moved_manually = true
	else:
		x_direction = slide_switch_movement_x	
	
	if !is_zero_approx(x_direction):
		velocity.x = x_direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
	
	if has_moved_manually:
		on_manual_move_pressed()

func on_manual_move_pressed() -> void:
	if is_instance_valid(move_tween) && move_tween.is_running():
		move_tween.kill()
	
	update_camera()
	
func has_slide_target_pos_reached() -> bool:
	var current_dist_x: float = abs(global_position.x - slide_switch_target_pos_x)
	
	var move_target_x: float = global_position.x + slide_switch_movement_x
	var target_dist_x: float = abs(move_target_x - slide_switch_target_pos_x)
	
	if target_dist_x > current_dist_x:
		return true

	return false	
	
func update_camera() -> void:
	var slide_context: SlideContext2D = SlideHelper.get_context_2d()
	var camera: Camera2D = slide_context.camera
	
	if slide_context.slide_center_locations.is_empty():
		return
	
	var closest_slide_pos: Vector2 = slide_context.get_sorted_slide_locations_by_center(self.global_position)[0]
	
	var target_slide: Slide = slide_context.slide_center_locations[closest_slide_pos]
	if target_slide == current_slide:
		return
		
	move_transition.start_transition(current_slide, target_slide)
	current_slide = target_slide
	
func teleport_to_slide(slide: Slide) -> void:

	if !is_player_active:
		return
	
	if is_instance_valid(move_tween) && move_tween.is_running():
		move_tween.kill()
		
	var slide_context: SlideContext2D = SlideHelper.get_context_2d()
	var target_pos: Vector2 = slide_context.get_slide_center_position(slide)
	var x_dist_to_slide: float = abs(global_position.x - target_pos.x)
	if x_dist_to_slide < slide_context.slide_center_offset.x:
		return
	
	if x_dist_to_slide < slide_context.slide_size.x * 1.8:
		walk_to_slide(target_pos, slide_context)
	else:
		fall_to_slide(target_pos)

func walk_to_slide(target_pos: Vector2, slide_context: SlideContext2D) -> void:
	var max_pos_x_distance: float = slide_context.slide_center_offset.x * TELEPORT_MAX_DIST_FACTOR
	var target_pos_x_distance: float = slide_context.slide_center_offset.x * SL_SWITCH_TARGET_POS
	#move_tween = get_tree().create_tween()
	var target_pos_displaced: Vector2
	if target_pos.x-global_position.x > 0: #target.x > global_pos.x, target is right from player
		
		# ensure player is close enough
		var min_target_pos_x: float = target_pos.x - max_pos_x_distance
		if global_position.x < min_target_pos_x:
			global_position.x = min_target_pos_x

		#target_pos_displaced = Vector2(target_pos.x - slide_context.slide_center_offset.x * 0.8, global_position.y)

		slide_switch_target_pos_x = target_pos.x - target_pos_x_distance
		slide_switch_movement_x = 1
		
	else:  #target.x < global_pos.x, target is left from player
		#target_pos_displaced = Vector2(target_pos.x + slide_context.slide_center_offset.x * 0.8, global_position.y)
		
		# ensure player is close enough
		var max_target_pos_x: float = target_pos.x + max_pos_x_distance
		if global_position.x > max_target_pos_x:
			global_position.x = max_target_pos_x

		slide_switch_target_pos_x = target_pos.x + target_pos_x_distance
		slide_switch_movement_x = -1
	
	#move_tween.tween_property(self, "global_position", target_pos_displaced, 0.5)
	
func fall_to_slide(target_pos: Vector2) -> void:
	slide_switch_movement_x = 0.0

	var random_x_displacement: float = randf_range(-400, 400)
	self.global_position = target_pos + Vector2(random_x_displacement, spawn_y_offset)
