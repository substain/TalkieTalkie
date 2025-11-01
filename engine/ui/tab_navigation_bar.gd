class_name TabNavigationBar extends Control

signal jump_to_slide(slide_index: int)

const _SLIDE_NAVIGATION_TAB: PackedScene = preload("res://engine/ui/slide_navigation_tab.tscn")

@export var _slide_navigation_hbox: HBoxContainer
@export var _slide_index_label: Label

var num_slides: int = 0
var current_slide_index: int = 0
var _slide_nav_dictionary: Dictionary[int, Button] = {} # slide-index -> SlideNavigationTab
	
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
