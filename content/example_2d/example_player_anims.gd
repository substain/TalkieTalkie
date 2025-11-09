class_name ExamplePlayerAnims 
extends AnimationPlayer

const LAND_ANIM: String = "land"
const JUMP_ANIM: String = "jump"
const FALL_ANIM: String = "fall"
const MOVE_ANIM: String = "walk"
const IDLE_ANIM: String = "idle"
const POINT_ANIM: String = "point"
const STUCK_ANIM: String = "stuck"

const BASE_ARM_ROTATION: float = 1.5 * PI

@export var player_sprite: Sprite2D
@export var arm_sprite: Sprite2D
@export var arm_pivot_left: Node2D
@export var arm_pivot_right: Node2D

var is_jumping: bool = false
var is_grounded: bool = true
var is_falling: bool = false
var is_landing: bool = false
var x_velocity: float = 0.0
var is_pointing: bool = false
var point_position: Vector2 = Vector2.ZERO
var arm_sprite_is_left: bool = true
var is_stuck: bool

func _ready() -> void:
	SlideHelper.pointing_at_pos.connect(_on_pointing_at_pos)
	SlideHelper.stop_drawing.connect(_on_stop_pointing)

func set_stuck(is_stuck_new: bool) -> void:
	is_stuck = is_stuck_new

func set_jumping() -> void:
	is_jumping = true

func set_grounded(is_grounded_new: bool) -> void:
	if !is_grounded && is_grounded_new:
		is_landing = true
		is_jumping = false
	
	is_grounded = is_grounded_new

func set_y_velocity(y_velocity: float) -> void:
	is_falling = y_velocity > 0
	#var is_falling: bool = !is_grounded && velocity.y < 0

func set_x_velocity(x_velocity_new: float) -> void:
	x_velocity = x_velocity_new
	
func _on_pointing_at_pos(point_pos: Vector2, _is_drawing: bool, _paint_properties: PaintProperties) -> void:
	is_pointing = true
	point_position = point_pos

func _on_stop_pointing() -> void:
	is_pointing = false
	
func update_anim() -> void:
	arm_sprite.visible = false
	
	if is_stuck:
		player_sprite.modulate = Color.LIGHT_GRAY
		play(STUCK_ANIM)
		return
	else:
		player_sprite.modulate = Color.WHITE

	var has_x_movement: bool = !is_zero_approx(x_velocity)
	if has_x_movement:
		player_sprite.flip_h = x_velocity < 0.0

	if !is_grounded:
		if is_jumping && !is_falling:
			play(JUMP_ANIM)
			return
		
		#if is_falling:?
		play(FALL_ANIM)
		return
		
	if is_landing:
		play(LAND_ANIM)
		return
		
	if !is_zero_approx(x_velocity):
		play(MOVE_ANIM)
		return
		
	if is_pointing:
		var is_right_point_pos: bool = flip_player_by_point_position() 
			
		play(POINT_ANIM)
		arm_sprite.visible = true
		arm_sprite.rotation = get_arm_rotation_rad(is_right_point_pos)
		return
		
	play(IDLE_ANIM)

func get_arm_rotation_rad(is_right_point_pos: bool) -> float:
	var target_pos: Vector2 = player_sprite.get_global_mouse_position()
	var arm_origin: Node2D = arm_pivot_right if is_right_point_pos else arm_pivot_left
	return BASE_ARM_ROTATION + arm_origin.global_position.angle_to_point(target_pos)

## returns true, if the point position is right from the player
func flip_player_by_point_position() -> bool:
	if point_position.x > player_sprite.global_position.x:
		if arm_sprite_is_left:
			arm_sprite.reparent(arm_pivot_right)
			arm_sprite.position = Vector2.ZERO
			arm_sprite.offset.x = -arm_sprite.offset.x
			arm_sprite_is_left = false
		
		player_sprite.flip_h = true
		arm_sprite.flip_h = true
		
		return false
		
	else:
		if !arm_sprite_is_left:
			arm_sprite.reparent(arm_pivot_left)
			arm_sprite.position = Vector2.ZERO
			arm_sprite.offset.x = -arm_sprite.offset.x
			arm_sprite_is_left = true

		player_sprite.flip_h = false
		arm_sprite.flip_h = false
		return true

func _on_animation_finished(anim_name: StringName) -> void:
	if anim_name == LAND_ANIM:
		is_landing = false
