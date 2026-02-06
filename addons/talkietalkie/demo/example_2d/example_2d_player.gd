class_name Example2DPlayer
extends CharacterBody2D

const UNSTUCK_WIGGLE_SPEED: float = 40.0
const UNSTUCK_WIGGLE_STRENGTH: float = 10.0
	
const SPEED: float = 850.0
const JUMP_VELOCITY: float = -1200.0
const GRAVITY_MULTIPLIER: float = 6.0
const TELEPORT_MAX_DIST_FACTOR: float = 1.4
const SL_SWITCH_TARGET_POS: float = 0.9

## if false, player does not process input / movement
@export var is_player_active: bool = true

@export var spawn_y_offset: float = -900

@export var move_transition: MoveTransition2D

## if true, player needs to hold any movement key to "escape" being stuck
@export var is_stuck: bool = false
@export var unstuck_duration: float = 1.2
@export var show_all_on_unstuck: bool = true

@export_category("internal nodes")
@export var anim_player: ExamplePlayerAnims

var current_slide: Slide

var is_jumping: bool = false

var _slide_switch_movement_x: float = 0.0
var _slide_switch_target_pos_x: float = 0.0
var _unstuck_progress: float = 0.0

var player_stuck_pos: Vector2
var player_start_pos: Vector2
	
func _ready() -> void:

	TTSlideHelper.slide_changed.connect(teleport_to_slide)
	player_start_pos = global_position
	if is_stuck:
		set_stuck()
	
func reset() -> void:
	global_position = player_start_pos
	if is_stuck:
		set_stuck()
	
func _physics_process(delta: float) -> void:
	if !is_player_active:
		return
		
	if is_stuck:
		handle_stuck_player(delta)
		return

	do_move(delta)
	
func set_stuck() -> void:
	player_stuck_pos = global_position
	_unstuck_progress = 0.0
	anim_player.set_stuck(true)
	anim_player.update_anim()
	is_stuck = true

func handle_stuck_player(delta: float) -> void:
	var direction: Vector2 = Input.get_vector("move_left", "move_right", "move_down", "move_up")
	
	if direction.is_zero_approx():
		_unstuck_progress = max(0, _unstuck_progress - delta)
	else:
		_unstuck_progress += delta

	# visuals for being stuck
	var relative_progress: float = _unstuck_progress / unstuck_duration
	var wiggle_offset: float = sin(relative_progress * UNSTUCK_WIGGLE_SPEED) * relative_progress * UNSTUCK_WIGGLE_STRENGTH
	global_position.x = global_position.x + wiggle_offset
	
	if _unstuck_progress >= unstuck_duration:
		_unstuck_progress = 0
		is_stuck = false
		anim_player.set_stuck(false)
		anim_player.update_anim()
		if show_all_on_unstuck:
			TTSlideHelper.slide_controller.set_current_slide_progress(1.0)
			
func do_move(delta: float) -> void:
	var has_moved_manually: bool = false
	
	var is_grounded: bool = is_on_floor()

	if is_grounded:
		is_jumping = false

	if !is_zero_approx(_slide_switch_movement_x) && has_slide_target_pos_reached():
		_slide_switch_movement_x = 0.0

	if !is_grounded:
		velocity += get_gravity() * delta * 6

	if Input.is_action_just_pressed("move_up") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		is_jumping = true
		is_grounded = false
		has_moved_manually = true
		anim_player.set_jumping()
		_slide_switch_movement_x = 0.0

	anim_player.set_grounded(is_grounded)
	anim_player.set_y_velocity(velocity.y)

	var x_direction: float = Input.get_axis("move_left", "move_right")
	if !is_zero_approx(x_direction):
		_slide_switch_movement_x = 0.0
		has_moved_manually = true
	else:
		x_direction = _slide_switch_movement_x	
	
	if !is_zero_approx(x_direction):
		velocity.x = x_direction * SPEED
		anim_player.set_x_velocity(velocity.x)
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		anim_player.set_x_velocity(0.0)

	move_and_slide()
	
	if get_slide_collision_count() > 0:
		var slide_collision: KinematicCollision2D = get_slide_collision(0)
		if slide_collision.get_collider() != null && slide_collision.get_collider() is ExampleJumpbox:
			(slide_collision.get_collider() as ExampleJumpbox).on_hit()
	
	anim_player.update_anim()
	
	if has_moved_manually:
		on_manual_move_pressed()


func on_manual_move_pressed() -> void:
	update_camera()
	
	
func has_slide_target_pos_reached() -> bool:
	var current_dist_x: float = abs(global_position.x - _slide_switch_target_pos_x)
	
	var move_target_x: float = global_position.x + _slide_switch_movement_x
	var target_dist_x: float = abs(move_target_x - _slide_switch_target_pos_x)
	
	if target_dist_x > current_dist_x:
		return true

	return false	
	
func update_camera() -> void:
	var slide_context: SlideContext2D = TTSlideHelper.get_context_2d()
	#var camera: Camera2D = slide_context.camera TODO: needed?
	
	if slide_context.slide_center_locations.is_empty():
		return
	
	var closest_slide_pos: Vector2 = slide_context.get_sorted_slide_locations_by_center(self.global_position)[0]
	
	var target_slide: Slide = slide_context.slide_center_locations[closest_slide_pos]
	if target_slide == current_slide:
		return
		
	move_transition.start_transition(current_slide, target_slide)
	current_slide = target_slide
	TTSlideHelper.slide_controller.set_slide(target_slide.get_order_index())
	
func teleport_to_slide(slide: Slide) -> void:
	if !is_player_active || is_stuck:
		return
		
	var slide_context: SlideContext2D = TTSlideHelper.get_context_2d()
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
	if target_pos.x-global_position.x > 0: #  target is right from player
		
		# ensure player is close enough
		var min_target_pos_x: float = target_pos.x - max_pos_x_distance
		if global_position.x < min_target_pos_x:
			global_position.x = min_target_pos_x

		_slide_switch_target_pos_x = target_pos.x - target_pos_x_distance
		_slide_switch_movement_x = 1
		
	else:  # target is left from player
				
		# ensure player is close enough
		var max_target_pos_x: float = target_pos.x + max_pos_x_distance
		if global_position.x > max_target_pos_x:
			global_position.x = max_target_pos_x

		_slide_switch_target_pos_x = target_pos.x + target_pos_x_distance
		_slide_switch_movement_x = -1
		
func fall_to_slide(target_pos: Vector2) -> void:
	_slide_switch_movement_x = 0.0

	var random_x_displacement: float = randf_range(-400, 400)
	self.global_position = target_pos + Vector2(random_x_displacement, spawn_y_offset)
