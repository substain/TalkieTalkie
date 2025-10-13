class_name ExamplePlayer
extends CharacterBody2D

const SPEED = 800.0
const JUMP_VELOCITY = -1200.0

@export var is_player_active: bool = true

@export var spawn_y_offset: float = -1000

@export var move_transition: MoveTransition2D

var move_tween: Tween = null
var current_slide: Slide
	
func _ready() -> void:
	SlideHelper.slide_changed.connect(teleport_to_slide)
	
func _physics_process(delta: float) -> void:	
	# ignore other movement if we're using a move tween
	if is_instance_valid(move_tween) && move_tween.is_running():
		return

	if !is_player_active:
		#var remove_this: bool = false
		#TODO: 
		return

	do_move(delta)

func do_move(delta: float) -> void:
	var has_moved: bool = false

	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta * 4

	# Handle jump.
	if Input.is_action_just_pressed("move_up") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction: float = Input.get_axis("move_left", "move_right")
	if !is_zero_approx(direction):
		has_moved = true
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
	
	if !has_moved:
		return

	update_camera()
	
	
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
		#var remove_this: bool = false
		#TODO: 
		return
	
	if is_instance_valid(move_tween) && move_tween.is_running():
		move_tween.kill()
		
	var slide_context: SlideContext2D = SlideHelper.get_context_2d()
	var target_pos: Vector2 = slide_context.get_slide_center_position(slide)
	var x_dist_to_slide: float = abs(global_position.x - target_pos.x)
	if x_dist_to_slide < slide_context.slide_center_offset.x:
		return
	
	if x_dist_to_slide < slide_context.slide_size.x * 1.5:
		walk_to_slide(target_pos, slide_context)
	else:
		fall_to_slide(target_pos)

func walk_to_slide(target_pos: Vector2, slide_context: SlideContext2D) -> void:
	move_tween = get_tree().create_tween()
	var target_pos_displaced: Vector2
	if target_pos.x-global_position.x > 0:
		target_pos_displaced = Vector2(target_pos.x - slide_context.slide_center_offset.x * 0.8, global_position.y)
	else:
		target_pos_displaced = Vector2(target_pos.x + slide_context.slide_center_offset.x * 0.8, global_position.y)
	move_tween.tween_property(self, "global_position", target_pos_displaced, 0.5)
	
func fall_to_slide(target_pos: Vector2) -> void:
	var random_x_displacement: float = randf_range(-400, 400)
	self.global_position = target_pos + Vector2(random_x_displacement, spawn_y_offset)
