class_name PaintingPointer
extends Control

const MIN_DRAW_DIST: float = 5.0

## Backup icon
static var _CIRCLE_1X1: Texture2D = load(TTSetup.get_plugin_path() + "/style/ui/circle_1x1.svg")
static var _PAINT_GRADIENT: Gradient = load(TTSetup.get_plugin_path() + "/style/ui/paint_gradient.tres")

const DP_1_INDEX: int = 0
const DP_2_INDEX: int = 1

const META_IS_TRAIL: String = "is_trail_line"

var DEFAULT_DA_1: PaintProperties = PaintProperties.new(Color.html("ff9595"), 4.0, 100, 8.0, _CIRCLE_1X1, 0.5, true)
var DEFAULT_DA_2: PaintProperties = PaintProperties.new(Color.BLUE, 10.0, -1, 4.0, _CIRCLE_1X1, 1.0, true)

## The draw attributes. Currently only the first two are used and statically mapped to the two "draw_pointer" actions.
## If there are less than 2 entries, default draw attributes are used.
@export var all_paint_properties: Array[PaintProperties] = []

@export_category("internal nodes")
@export var icon_rect: TextureRect

var current_da_index: int = 0
var is_pointing: bool = false
var is_drawing: bool = false
var current_line: Line2D = null

var icon_offset: Vector2 = Vector2.ZERO

var managed_lines: Array[Line2D] = []

func _ready() -> void:
	TTSlideHelper.slide_changed.connect(_on_slide_changed)
	
	if all_paint_properties.size() < 1:
		all_paint_properties.append(DEFAULT_DA_1)
	
	if all_paint_properties.size() < 2:
		all_paint_properties.append(DEFAULT_DA_2)
	
	for paint_prop: PaintProperties in all_paint_properties:
		# fallback if no icon is provided
		if paint_prop.icon == null:
			paint_prop.icon = _CIRCLE_1X1


func _process(_delta: float) -> void:
	if managed_lines.size() > 0:
		for line: Line2D in managed_lines:
			var is_trail: bool = line.get_meta(META_IS_TRAIL, false) as bool
			if !is_trail: 
				continue
			
			if line.points.size() > 0:
				line.remove_point(0)
				
			if line.points.size() == 0:
				managed_lines.erase(line)
				line.queue_free()
			
	if !is_pointing:
		return
	var paint_props: PaintProperties = all_paint_properties[current_da_index]
	var target_pos: Vector2 = get_global_mouse_position()
	icon_rect.global_position = target_pos + icon_offset
	TTSlideHelper.pointing_at_pos.emit(target_pos, is_drawing, paint_props)

	if is_drawing:
		
		var point_moved: bool = false
		var cl_points_size: int = current_line.points.size()
		if cl_points_size > 2:
			var pp1: Vector2 = current_line.get_point_position(cl_points_size-1)
			var pp2: Vector2 = current_line.get_point_position(cl_points_size-2)
			if pp1.distance_to(target_pos) < MIN_DRAW_DIST && pp1.distance_to(pp2) < MIN_DRAW_DIST:
				current_line.set_point_position(cl_points_size-1, target_pos)
				point_moved = true
		
		if !point_moved:
			current_line.add_point(target_pos)
			
		var is_trail: bool = current_line.get_meta(META_IS_TRAIL, false) as bool
		if is_trail && paint_props.trail_points > 0 && current_line.points.size() > paint_props.trail_points:
			for i: int in current_line.points.size()-paint_props.trail_points:
				current_line.remove_point(0)

func _input(event: InputEvent) -> void:
	check_pointing(event)
	check_drawing(event)

func check_pointing(event: InputEvent) -> void:
	var da_index_before: int = current_da_index
	if event.is_action_pressed("tt_draw_pointer_1"):
		current_da_index = DP_1_INDEX
		is_pointing = true
	elif event.is_action_pressed("tt_draw_pointer_2"):
		current_da_index = DP_2_INDEX
		is_pointing = true

	elif event.is_action_released("tt_draw_pointer_1") && current_da_index == DP_1_INDEX:
		is_pointing = false
		TTSlideHelper.stop_drawing.emit()

	elif event.is_action_released("tt_draw_pointer_2") && current_da_index == DP_2_INDEX:
		is_pointing = false
		TTSlideHelper.stop_drawing.emit()
	
	else:
		return


	
	# update paint properties
	var paint_props: PaintProperties = all_paint_properties[current_da_index]
	icon_rect.texture = paint_props.icon
	icon_rect.scale = Vector2.ONE * paint_props.icon_scale
	if paint_props.modulate_icon_with_color:
		icon_rect.modulate = paint_props.color
	else:
		icon_rect.modulate = Color.WHITE
		
	icon_offset = -(icon_rect.size*icon_rect.scale) / 2
	icon_rect.visible = is_pointing
	
	if da_index_before != current_da_index && is_drawing:
		create_new_line(paint_props)

func check_drawing(event: InputEvent) -> void:
	var p_props: PaintProperties = all_paint_properties[current_da_index]
	if event is InputEventMouseButton:
		if is_pointing && (event as InputEventMouseButton).is_pressed():
			if !is_drawing:
				create_new_line(p_props)
			is_drawing = true
			get_viewport().set_input_as_handled()
						
		if (event as InputEventMouseButton).is_released():
			if is_instance_valid(current_line):
				managed_lines.append(current_line)
				set_line_timed(current_line, all_paint_properties[current_da_index].time_alive)
				current_line = null
			if is_drawing:
				get_viewport().set_input_as_handled()
			is_drawing = false

func create_new_line(p_props: PaintProperties) -> void:
	if is_instance_valid(current_line):
		managed_lines.append(current_line)
		set_line_timed(current_line, p_props.time_alive)
	current_line = get_line(p_props)
	add_child(current_line)

func set_line_timed(line: Line2D, time: float) -> void:
	await get_tree().create_timer(time).timeout
	if !is_instance_valid(line):
		return
	managed_lines.erase(line)
	line.queue_free()

func _on_slide_changed(_new_slide: Slide) -> void:
	is_drawing = false
	if current_line != null:
		current_line.queue_free()
	current_line = null
	for line: Line2D in managed_lines:
		line.queue_free()
	managed_lines.clear()

static func get_line(p_props: PaintProperties) -> Line2D:
	var line: Line2D = Line2D.new()
	line.width = p_props.thickness
	line.modulate = p_props.color
	line.begin_cap_mode = Line2D.LINE_CAP_ROUND
	line.end_cap_mode = Line2D.LINE_CAP_ROUND
	line.joint_mode = Line2D.LINE_JOINT_ROUND
	var is_trail: bool = p_props.trail_points >= 1
	line.set_meta(META_IS_TRAIL, is_trail)
	if is_trail:
		line.gradient = _PAINT_GRADIENT

	return line
