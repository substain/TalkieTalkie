class_name TabNavigationBar extends Control

signal jump_to_slide(slide_index: int)

const SLIDE_NAVIGATION_TAB: PackedScene = preload("res://engine/ui/slide_navigation_tab.tscn")

@export var slide_navigation_hbox: HBoxContainer
@export var slide_index_label: Label

var num_slides: int = 0
var current_slide_index: int = 0
var slide_nav_dictionary: Dictionary[int, Button] = {} # slide-index -> SlideNavigationTab
	
func set_ui_disabled(disabled_new: bool) -> void:
	if disabled_new:
		slide_index_label.text = "no slides"

func set_available_slides(slides: Array[Slide]) -> void:
	var simple_slide_buttons: Array[Button] = []
	
	num_slides = slides.size()
	
	for slide: Slide in slides:
		var target_slide_index: int = slide.order_index
		var slide_nav_button: Button = SLIDE_NAVIGATION_TAB.instantiate()
		slide_nav_button.pressed.connect(_slide_nav_button_pressed.bind(target_slide_index))
		simple_slide_buttons.append(slide_nav_button)
		slide_nav_dictionary[target_slide_index] = slide_nav_button
		slide_navigation_hbox.add_child(slide_nav_button)
		slide_navigation_hbox.move_child(slide_nav_button, target_slide_index)
	
	#simple_slide_content_nav.custom_minimum_size.x = slide_content_nav_mc.size.x
	#
	#simple_slide_content_nav.size.x = simple_slide_content_nav.custom_minimum_size.x
	#simple_slide_content_nav.set_anchors_and_offsets_preset(Control.PRESET_CENTER, Control.LayoutPresetMode.PRESET_MODE_MINSIZE)
	#simple_slide_content_nav.offset_left = 0
	#simple_slide_content_nav.offset_right = 0
	#simple_slide_content_nav.offset_top = 0
	#simple_slide_content_nav.offset_bottom = 0
	#simple_slide_content_nav.queue_sort()
	#simple_slide_content_nav.queue_redraw()
	#slide_button_hbox.update_minimum_size()
	#slide_button_hbox.reset_size()
		
	update_slide_index_label()
	
func _slide_nav_button_pressed(slide_index: int) -> void:
	jump_to_slide.emit(slide_index)
	
	
func set_current_slide(slide_index: int) -> void:
	current_slide_index = slide_index
	if !slide_nav_dictionary[slide_index].button_pressed:
		slide_nav_dictionary[slide_index].button_pressed = true
	slide_nav_dictionary[slide_index].get("theme_override_styles/normal").bg_color = Color.html("636f63d3")

	update_slide_index_label()
	
func update_slide_index_label() -> void:
	slide_index_label.text = str(current_slide_index+1) + " / " + str(num_slides)
