class_name TabNavigationBar extends Control

signal jump_to_slide(slide_index: int)

const _SLIDE_NAVIGATION_TAB: PackedScene = preload("res://engine/ui/slide_navigation_tab.tscn")

@export var _slide_navigation_hbox: HBoxContainer
@export var _slide_index_label: Label

var num_slides: int = 0
var current_slide_index: int = 0
var _slide_nav_dictionary: Dictionary[int, Button] = {} # slide-index -> SlideNavigationTab

var local_hidden_dir: Vector2 = Vector2.ZERO
	
func _ready() -> void:
	update_local_hidden_dir()

func set_ui_disabled(disabled_new: bool) -> void:
	if disabled_new:
		_slide_index_label.text = "no slides"

func set_available_slides(slides: Array[Slide]) -> void:
	var simple_slide_buttons: Array[Button] = []
	
	num_slides = slides.size()
	
	for slide: Slide in slides:
		var target_slide_index: int = slide.get_order_index()
		var slide_nav_button: Button = _SLIDE_NAVIGATION_TAB.instantiate()
		slide_nav_button.pressed.connect(_slide_nav_button_pressed.bind(target_slide_index))
		simple_slide_buttons.append(slide_nav_button)
		_slide_nav_dictionary[target_slide_index] = slide_nav_button
		_slide_navigation_hbox.add_child(slide_nav_button)
		_slide_navigation_hbox.move_child(slide_nav_button, target_slide_index)
		
	update_slide_index_label()
	
func _slide_nav_button_pressed(slide_index: int) -> void:
	jump_to_slide.emit(slide_index)
	
	
func set_current_slide(slide_index: int) -> void:
	current_slide_index = slide_index
	if !_slide_nav_dictionary[slide_index].button_pressed:
		_slide_nav_dictionary[slide_index].button_pressed = true
	_slide_nav_dictionary[slide_index].get("theme_override_styles/normal").bg_color = Color.html("636f63d3")

	update_slide_index_label()
	
func update_slide_index_label() -> void:
	_slide_index_label.text = str(current_slide_index+1) + " / " + str(num_slides)

var _visibility_tween: Tween = null
var is_visible_ui: bool = false


func set_visible_tween(is_visible_ui_new: bool, force_set: bool = false) -> void:
	if is_visible_ui_new == is_visible_ui && !force_set:
		return	

	var modulate_start: float = 0.0 if is_visible_ui_new else 1.0
	var modulate_target: float = 1.0 - modulate_start
	var start_pos: Vector2 = position
	var target_pos: Vector2 = Vector2.ZERO if is_visible_ui_new else local_hidden_dir
	
	UI.tween_ui_element(_visibility_tween, self, start_pos, target_pos, modulate_start, modulate_target)

func update_local_hidden_dir() -> void:
	local_hidden_dir = UI.get_direction_from_anchors(anchor_top, anchor_bottom, anchor_left, anchor_right)
