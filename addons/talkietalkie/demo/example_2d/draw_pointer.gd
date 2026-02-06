class_name DrawPointer
extends Control

const DP_1_INDEX: int = 0
const DP_2_INDEX: int = 1

class DrawAttributes extends Resource:
	var color: Color = Color.RED
	var thickness: float = 1.0
	var max_trail_points: int = 5
	var icon: Texture2D
	var modulate_icon_with_color: bool = true
	
	func _init(color_new: Color, thickness_new: float) -> void:
		color = color_new
		thickness = thickness_new
	
var DEFAULT_DA_1: DrawAttributes = DrawAttributes.new(Color.RED, 1.0)
var DEFAULT_DA_2: DrawAttributes = DrawAttributes.new(Color.BLUE, 2.0)

## The draw attributes. Currently only the first two are used and statically mapped to the two "draw_pointer" actions.
## If there are less than 2 entries, default draw attributes are used.
@export var all_draw_attributes: Array[DrawAttributes] = []

var current_da_index: int = 0
var is_pointing: bool = false
var is_drawing: bool = false
var current_line: Line2D = null

func _ready() -> void:
	if all_draw_attributes.size() < 1:
		all_draw_attributes.append(DEFAULT_DA_1)
	
	if all_draw_attributes.size() < 2:
		all_draw_attributes.append(DEFAULT_DA_2)
	
func _process(delta: float) -> void:
	if !is_pointing:
		return
	var draw_attrs: DrawAttributes = all_draw_attributes[current_da_index]
	var target_pos: Vector2 = get_global_mouse_position()
	TTSlideHelper.pointing_at_pos.emit(target_pos, is_drawing, draw_attrs)

	if is_drawing:
		current_line.add_point(target_pos)
		
	if current_line.points.size() > draw_attrs.max_line_points:
		for i in current_line.points.size()-draw_attrs.max_trail_points:
			current_line.points.remove_at(0)

func _input(event: InputEvent) -> void:
	
	if event.is_action_pressed("draw_pointer_1"):
		current_da_index = DP_1_INDEX
		is_pointing = true
	if event.is_action_released("draw_pointer_1") && current_da_index == DP_1_INDEX:
		is_pointing = false
		TTSlideHelper.stop_drawing.emit()
		
				
	if event.is_action_pressed("draw_pointer_2"):
		current_da_index = DP_2_INDEX
		is_pointing = true
	if event.is_action_released("draw_pointer_2") && current_da_index == DP_2_INDEX:
		is_pointing = false
		TTSlideHelper.stop_drawing.emit()

	if is_pointing && event is InputEventMouseButton:
		if (event as InputEventMouseButton).is_pressed():
			if !is_drawing:
				current_line = Line2D.new()
				add_child(current_line)
				current_line.modulate = all_draw_attributes[current_da_index].color
				is_drawing = true
						
		elif (event as InputEventMouseButton).is_released():
			is_drawing = false
			
