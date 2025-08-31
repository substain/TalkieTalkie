class_name Main
extends Node

## Main script for running the presentation. Handles slide navigation.
## A simple slideshow feature (automatic continueing slides) can be activated by enabling "Autostart"
## in the SlideshowTimer node, and setting "Wait Time" to the desired delay.

static var extract_num_regex: RegEx = RegEx.new()

## the current index of the slide 
@export var slide_index: int = 0

## if true, the slide_index will be loaded from the last session if the presentation name matches
@export var override_slide_index_from_last_session: bool = false

## Use the number of the slide nodes instead of the order in the tree (top to bottom)
@export var use_slide_numbering_order: bool = false

## If set to "true", using manual navigation (e.g. clicking the forward button) will stop the slideshow.
@export var manual_navigation_stops_slideshow: bool = true

@export var transition_duration: float = 0.5

## slide resources to load. Alternative to directly adding slides in the scene
#@export var slides_to_load: Array[SlideResource] = []

@onready var ui: UI = $UI
@onready var background: Background = $Background
@onready var slideshow_timer: Timer = $SlideshowTimer

var slide_instances: Array[Slide]
var current_slide: Slide = null

var transition_tween: Tween = null
var last_from_slide: Slide = null

func _ready() -> void:
	SlideHelper.main = self
	extract_num_regex.compile("\\d+")
	slide_instances = collect_slides_in_children(self)
	
	if override_slide_index_from_last_session && Preferences.last_presentation_scene == get_tree().current_scene.scene_file_path:
		slide_index = Preferences.last_slide
	
	if slide_instances.size() == 0:
		push_error("No slides found in the tree of the '" + self.name + "' scene. This might produce erros. Add instances of Slide nodes as children to fix this.")
		ui.set_ui_disabled(true)
		slideshow_timer.stop()
		return

	if use_slide_numbering_order:
		slide_instances.sort_custom(compare_by_last_number)
	
	for i: int in slide_instances.size():
		slide_instances[i].order_index = i 
	ui.set_available_slides(slide_instances)

	set_slide(slide_index, true)
	show_only_current_slide()
		
	ui.control_bar.set_slideshow_active(slideshow_timer.autostart == true)
	ui.control_bar.update_slideshow_duration(slideshow_timer.wait_time)
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("continue"):
		do_continue()
		
	if event.is_action_pressed("skip_slide"):
		do_skip_slide()
		
	if event.is_action_pressed("back"):
		go_back_slide()
	
	if event.is_action_pressed("toggle_ui"):
		ui.toggle_ui_visible()
	
	if event.is_action_pressed("show_ui"):
		ui.set_ui_visible(true)
		
	if event.is_action_pressed("fullscreen"):
		ui.control_bar.toggle_fullscreen()

	if event.is_action_pressed("quit"):
		ui.quit()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton && (event as InputEventMouseButton).button_index == MOUSE_BUTTON_LEFT && (event as InputEventMouseButton).pressed:
		do_continue()
		
func do_continue(automatic: bool = false) -> void:
	if !automatic && manual_navigation_stops_slideshow:
		stop_slideshow()
	
	if slide_index == slide_instances.size()-1 && slide_instances[slide_index].is_finished():
		return
	
	var was_finished: bool = current_slide.continue_slide()
	ui.control_bar.set_slide_progress_flags(current_slide.is_at_start(), current_slide.is_finished())
	if !was_finished:
		return
		
	var previous_slide: Slide = current_slide
	
	change_slide(1)

	#print("fade to slide: ", slide_index)
	transition_to_slide(previous_slide, current_slide, Transitions.mix_transition.bind(transition_duration))

func do_skip_slide(automatic: bool = false) -> void:
	if !automatic && manual_navigation_stops_slideshow:
		stop_slideshow()
	if !current_slide.is_finished():
		current_slide.show_full()
		return	
		
	change_slide(1)	
	skip_to_current_slide_full()

func go_back_slide(automatic: bool = false) -> void:
	if !automatic && manual_navigation_stops_slideshow:
		stop_slideshow()
		
	if slide_index == 0:
		current_slide.reset()
		ui.control_bar.set_slide_progress_flags(current_slide.is_at_start(), current_slide.is_finished())
		return
		
	change_slide(-1)
	skip_to_current_slide_full()

func skip_to_current_slide_full() -> void:
	#print("skip to slide: ", new_index)
	current_slide.show_full()
	ui.control_bar.set_slide_progress_flags(current_slide.is_at_start(), true)
	show_only_current_slide()
	
func transition_to_slide(from_slide: Slide, to_slide: Slide, transition: Callable) -> void:
	if is_instance_valid(transition_tween):
		transition_tween.kill()
		if is_instance_valid(last_from_slide):
			last_from_slide.modulate.a = 0.0
	transition_tween = transition.call(from_slide, to_slide)
	last_from_slide = from_slide
	#await transition_tween.finished
	#from_slide.visible = false

func show_only_current_slide() -> void:
	if is_instance_valid(transition_tween):
		transition_tween.kill()
	for i: int in slide_instances.size():
		if slide_index != i:
			slide_instances[i].visible = false
			
	slide_instances[slide_index].visible = true
	slide_instances[slide_index].modulate.a = 1.0
	
## returns true if the slide was changed
func change_slide(change: int) -> bool:
	var previous_slide_index: int = slide_index
	change_slide_index(change)
	if previous_slide_index == slide_index:
		return false
	current_slide = slide_instances[slide_index]
	SlideHelper.current_slide = slide_instances[slide_index]
	current_slide.reset()
	update_ui_slide_status()
	background.slide_changed.emit(current_slide)
	return true

## returns true if the slide was changed
func set_slide(new_index: int, force_set: bool = false) -> bool:
	var previous_slide_index: int = slide_index
	set_slide_index(new_index)
	if previous_slide_index == slide_index && !force_set:
		return false
	current_slide = slide_instances[slide_index]
	SlideHelper.current_slide = slide_instances[slide_index]
	current_slide.reset()
	update_ui_slide_status()
	background.slide_changed.emit(current_slide)
	return true
	
func change_slide_index(change: int) -> void:
	set_slide_index(slide_index + change)
	
func set_slide_index(new_index: int) -> void:
	slide_index = clamp(new_index, 0, slide_instances.size()-1)
	Preferences.set_presentation_progress(slide_index, get_tree().current_scene.scene_file_path)
	
	ui.set_current_slide(slide_index)
	
func update_ui_slide_status() -> void:
	ui.control_bar.set_slide_status_flags(slide_index == 0, slide_index == slide_instances.size()-1)
	ui.control_bar.set_slide_progress_flags(slide_instances[slide_index].is_at_start(), slide_instances[slide_index].is_finished())

func _on_ui_continue_slide() -> void:
	do_continue()

func _on_ui_previous_slide() -> void:
	go_back_slide()

func _on_ui_skip_slide() -> void:
	do_skip_slide()

	
static func compare_by_last_number(a: Slide, b: Slide) -> int:
	return last_number_or_zero(a.name) < last_number_or_zero(b.name)
	
static func last_number_or_zero(str_name: String) -> int:
	var numbers_in_string: Array[RegExMatch] = extract_num_regex.search_all(str_name)
	if numbers_in_string.size() == 0:
		return 0
	var res: int = int(numbers_in_string[numbers_in_string.size()-1].subject)
	return res
		
static func collect_slides_in_children(node: Node) -> Array[Slide]:
	var res: Array[Slide] = []
	if node is Slide:
		res.append(node as Slide)
		
	for child: Node in node.get_children():
		var children_nodes: Array[Slide]= collect_slides_in_children(child)
		res.append_array(children_nodes)
				
	return res
	
func _on_slideshow_timer_timeout() -> void:
	do_continue(true)
	if slide_index == slide_instances.size()-1 && slide_instances[slide_index].is_finished():
		stop_slideshow(true)

func start_slideshow(update_ui: bool = true) -> void:
	slideshow_timer.start()
	if update_ui:
		ui.set_slideshow_active(true)

func stop_slideshow(update_ui: bool = true) -> void:
	slideshow_timer.stop()
	if update_ui:
		ui.set_slideshow_active(false)
		
func _on_ui_set_slideshow_duration(new_duration: float) -> void:
	slideshow_timer.wait_time = new_duration

func _on_ui_toggle_slideshow(slideshow_active: bool) -> void:
	if slideshow_active:
		start_slideshow(false)
	else:
		stop_slideshow(false)

func _on_ui_jump_to_slide(new_slide_index: int) -> void:
	set_slide(new_slide_index)	
	skip_to_current_slide_full()
	if manual_navigation_stops_slideshow:
		stop_slideshow()
