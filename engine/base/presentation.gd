class_name Presentation
extends Node

## Main script for running the presentation. Handles slide navigation.
## A simple slideshow feature (automatic continueing slides) can be activated by enabling "Autostart"
## in the SlideshowTimer node, and setting "Wait Time" to the desired delay.

## the current index of the slide 
@export var slide_index: int = 0
## if true, the slide_index will be loaded from the last session if the presentation name matches
@export var remember_slide_index_from_last_session: bool = false
## Use the number of the slide nodes instead of the order in the tree (top to bottom)
@export var use_slide_numbering_order: bool = false
## If set to "true", using manual navigation (e.g. clicking the forward button) will stop the automatic slideshow.
@export var manual_navigation_stops_auto_slideshow: bool = true
@export var default_transition: Transition
@export var slide_size: Vector2 = Vector2(1920, 1080)

@export_category("internal nodes")
@export var ui: UI
@export var slide_controller: SlideController

var slide_instances: Array[Slide]
var current_slide: Slide = null

var transition_tween: Tween = null
var last_from_slide: Slide = null

func _ready() -> void:
	init_context()
	SlideHelper.presentation = self	
	
	var has_faulty_configuration: bool = false
	
	slide_instances = Util.collect_slides_in_children(self)
	
	if default_transition == null:
		default_transition = Transition.new()
	
	if remember_slide_index_from_last_session && Preferences.last_presentation_scene == get_tree().current_scene.scene_file_path:
		slide_index = Preferences.last_slide
	
	if slide_instances.size() == 0:
		push_error("No slides found in the tree of the '" + self.name + "' scene. This might produce erros. Add instances of Slide nodes as children to fix this.")
		ui.set_ui_disabled(true)
		has_faulty_configuration = true
		return

	if use_slide_numbering_order:
		slide_instances.sort_custom(Util.compare_by_last_number)
	
	for i: int in slide_instances.size():
		slide_instances[i].set_order_index(i)
	ui.set_available_slides(slide_instances)
	
	ui.control_bar.set_auto_slideshow_active(slide_controller.auto_slideshow_timer.autostart == true)
	ui.control_bar.update_auto_slideshow_duration(slide_controller.auto_slideshow_timer.wait_time)
	
	slide_controller.init(slide_instances, default_transition, manual_navigation_stops_auto_slideshow, has_faulty_configuration)
	slide_controller.setup_initial_state(slide_index)

func init_context() -> void:
	SlideHelper.set_context(SlideContext.new(slide_size))
	
func _input(event: InputEvent) -> void:
	handle_input(event)
	
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton && (event as InputEventMouseButton).button_index == MOUSE_BUTTON_LEFT && (event as InputEventMouseButton).pressed:
		slide_controller.do_continue()
		
func _on_ui_continue_slide() -> void:
	slide_controller.do_continue()

func _on_ui_previous_slide() -> void:
	slide_controller.go_back_slide()

func _on_ui_skip_slide() -> void:
	slide_controller.do_skip_slide()

func _on_slideshow_timer_timeout() -> void:
	slide_controller.do_continue(true)
	if slide_index == slide_instances.size()-1 && slide_instances[slide_index].is_finished():
		slide_controller.stop_auto_slideshow(true)  

func _on_ui_set_slideshow_duration(new_duration: float) -> void:
	slide_controller.auto_slideshow_timer.wait_time = new_duration

func _on_ui_toggle_slideshow(slideshow_active: bool) -> void:
	if slideshow_active:
		slide_controller.start_auto_slideshow(false)
	else:
		slide_controller.stop_auto_slideshow(false)

func _on_ui_jump_to_slide(new_slide_index: int) -> void:
	slide_controller.set_slide(new_slide_index)	
	slide_controller.skip_to_current_slide_full()
	if manual_navigation_stops_auto_slideshow:
		slide_controller.stop_auto_slideshow()


func _on_side_window_input_received(event: InputEvent) -> void:
	handle_input(event)
	
func handle_input(event: InputEvent) -> void:
	if ui.has_overlay:
		return
	
	if event.is_action_pressed("continue"):
		slide_controller.do_continue()
		
	if event.is_action_pressed("skip_slide"):
		slide_controller.do_skip_slide()
		
	if event.is_action_pressed("back"):
		slide_controller.go_back_slide()
	
	if event.is_action_pressed("toggle_ui"):
		ui.toggle_ui_visible()
		
	if event.is_action_pressed("fullscreen"):
		ui.control_bar.toggle_fullscreen()

	if event.is_action_pressed("quit"):
		ui.quit()		
