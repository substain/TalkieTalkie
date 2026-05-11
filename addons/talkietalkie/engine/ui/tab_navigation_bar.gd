class_name TabNavigationBar extends HidableUI

signal jump_to_slide(slide_index: int)

static var _SLIDE_NAVIGATION_TAB_SCENE: PackedScene = load(TTSetup.get_plugin_path() + "/engine/ui/slide_navigation_tab.tscn")

@export var _slide_index_label: Label
@export var _slide_navigation_button_hbox: HBoxContainer

@export var scroll_container: ManualScrollContainer

#DEBUG

var num_slides: int = 0
var current_slide_index: int = 0
var _slide_nav_dictionary: Dictionary[int, Button] = {} # slide-index -> SlideNavigationTab

func _ready() -> void:
	
	scroll_container.set_scroll_active(false) 
	scroll_container.set_hovered(false)

	super()

func set_ui_disabled(disabled_new: bool) -> void:
	if disabled_new:
		_slide_index_label.text = "no slides"

func set_available_slides(slides: Array[Slide]) -> void:
	var simple_slide_buttons: Array[Button] = []
		
	num_slides = slides.size()
	
	for slide: Slide in slides:
		var target_slide_index: int = slide.get_order_index()

		var slide_nav_button: Button = _SLIDE_NAVIGATION_TAB_SCENE.instantiate()
		set_slide_nav_button_indication(slide_nav_button, slide, target_slide_index)
		
		slide_nav_button.pressed.connect(_slide_nav_button_pressed.bind(target_slide_index))
		simple_slide_buttons.append(slide_nav_button)
		_slide_nav_dictionary[target_slide_index] = slide_nav_button
		_slide_navigation_button_hbox.add_child(slide_nav_button)
		_slide_navigation_button_hbox.move_child(slide_nav_button, target_slide_index)
		slide_nav_button.mouse_entered.connect(_on_mouse_entered)

	update_threshold()
	update_slide_index_label()

	set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	update_base_pos(position)


func _slide_nav_button_pressed(slide_index: int) -> void:
	jump_to_slide.emit(slide_index)
	
func set_current_slide(slide_index: int) -> void:

	current_slide_index = slide_index
	if !_slide_nav_dictionary[slide_index].button_pressed:
		_slide_nav_dictionary[slide_index].button_pressed = true
	_slide_nav_dictionary[slide_index].get("theme_override_styles/normal").bg_color = Color.html("636f63d3")

	update_slide_index_label()
	scroll_container.set_current_slide_tab.call_deferred(_slide_nav_dictionary[slide_index])

	
func update_slide_index_label() -> void:
	_slide_index_label.text = str(current_slide_index+1) + " / " + str(num_slides)

func update_threshold() -> void:
	scroll_container.set_scroll_active(num_slides >= TTPreferences.tt_config.max_visible_tabnav_elements) 

	if num_slides >= TTPreferences.tt_config.max_visible_tabnav_elements:
		scroll_container.custom_minimum_size.x = TTPreferences.tt_config.tabnav_width_on_scroll

func _on_mouse_entered() -> void:
	scroll_container.set_hovered(true)

func set_visible_tween(is_visible_ui_new: bool, force_set: bool = false) -> void:
	super(is_visible_ui_new, force_set)
	
	if !is_visible_ui_new:
		scroll_container.set_hovered(false)

func set_slide_nav_button_indication(button: Button, slide: Slide, index: int) -> void:
	match TTPreferences.tt_config.tabnav_indicator:
		TTConfigHandler.TabNavIndication.SLIDE_TITLE:
			print("slide title:", slide.get_title())
			button.text = slide.get_title().substr(0, min(slide.get_title().length(), TTPreferences.tt_config.tabnav_indicator_max_length))

		TTConfigHandler.TabNavIndication.NUMBER:
			button.text = str(index + 1)
