class_name SlideController
extends Node

@export var auto_slideshow_timer: Timer
@export var color_picker: Color

var manual_navigation_stops_slideshow: bool
var slide_instances: Array[Slide]
var slide_index: int = 0
var current_slide: Slide
var default_transition: Transition

var transition_tween: Tween = null
var last_from_slide: Slide = null
var last_transition: Transition

func init(slide_instances_new: Array[Slide], default_transition_new: Transition, manual_navigation_stops_slideshow_new: bool, has_faulty_configuration: bool) -> void:
	slide_instances = slide_instances_new
	default_transition = default_transition_new
	manual_navigation_stops_slideshow = manual_navigation_stops_slideshow_new
	SlideHelper.slide_controller = self
	if has_faulty_configuration:
		auto_slideshow_timer.stop()
		
func setup_initial_state(slide_index_new: int) -> void:
	set_slide(slide_index_new, true)
	show_only_current_slide()

func do_continue(automatic: bool = false) -> void:
	if !automatic && manual_navigation_stops_slideshow:
		stop_auto_slideshow()
	
	if slide_index == slide_instances.size()-1 && slide_instances[slide_index].is_finished():
		return
	
	var was_finished: bool = current_slide.continue_slide()
	SlideHelper.ui.control_bar.set_slide_progress_flags(current_slide.is_at_start(), current_slide.is_finished())
	if !was_finished:
		return
		
	var previous_slide: Slide = current_slide
	var has_next_slide: bool = change_slide(1)
	if !has_next_slide:
		return

	var used_transition: Transition = current_slide.get_in_transition_override() if current_slide.get_in_transition_override() != null else default_transition
	transition_to_slide(previous_slide, current_slide, used_transition)

func set_slide_progress(slide_index_new: int, rel_progress: float) -> void:
	if manual_navigation_stops_slideshow:
		stop_auto_slideshow()
		
	var used_slide_index: int = clampi(slide_index_new, 0, slide_instances.size()-1)
	set_slide(used_slide_index)
	_set_progress(rel_progress)

func set_current_slide_progress(rel_progress: float) -> void:
	if manual_navigation_stops_slideshow:
		stop_auto_slideshow()
	_set_progress(rel_progress)

func _set_progress(rel_progress: float) -> void:
	current_slide.set_progress(rel_progress)
	SlideHelper.ui.control_bar.set_slide_progress_flags(current_slide.is_at_start(), current_slide.is_finished())

func do_skip_slide(automatic: bool = false) -> void:
	if !automatic && manual_navigation_stops_slideshow:
		stop_auto_slideshow()
	if !current_slide.is_finished():
		current_slide.show_full()
		return	
		
	change_slide(1)	
	skip_to_current_slide_full()

func go_back_slide(automatic: bool = false) -> void:
	if !automatic && manual_navigation_stops_slideshow:
		stop_auto_slideshow()
		
	if slide_index == 0:
		current_slide.reset()
		SlideHelper.ui.control_bar.set_slide_progress_flags(current_slide.is_at_start(), current_slide.is_finished())
		return
		
	change_slide(-1)
	skip_to_current_slide_full()

func skip_to_current_slide_full() -> void:
	current_slide.show_full()
	SlideHelper.ui.control_bar.set_slide_progress_flags(current_slide.is_at_start(), true)
	show_only_current_slide()
	
func transition_to_slide(from_slide: Slide, to_slide: Slide, transition: Transition) -> void:
	if is_instance_valid(transition_tween):
		transition_tween.kill()
		last_transition.on_finish_transition.call(last_from_slide)
		
	transition_tween = transition.start_transition.call(from_slide, to_slide)
	last_from_slide = from_slide
	last_transition = transition

func show_only_current_slide() -> void:
	if is_instance_valid(transition_tween):
		transition_tween.kill()
	
	match SlideHelper.get_context().slide_context_type:
		SlideContext.SlideContextType.CONTROL:
			show_only_current_slide_control()
		SlideContext.SlideContextType.NODE_2D:
			show_only_current_slide_2d()
		SlideContext.SlideContextType.NODE_3D:
			show_only_current_slide_3d()
			
func show_only_current_slide_control() -> void:
	for i: int in slide_instances.size():
		if slide_index != i:
			slide_instances[i].visible = false
	
	slide_instances[slide_index].visible = true
	slide_instances[slide_index].modulate.a = 1.0
		
func show_only_current_slide_2d() -> void:
	SlideHelper.get_context_2d().camera.global_position = SlideHelper.get_context_2d().get_slide_center_position(slide_instances[slide_index])

func show_only_current_slide_3d() -> void:
	SlideHelper.get_context_3d().camera.global_position = SlideHelper.get_context_3d().get_slide_center_position(slide_instances[slide_index])

## returns true if the slide was changed
func change_slide(change: int) -> bool:
	var previous_slide_index: int = slide_index
	change_slide_index(change)
	if previous_slide_index == slide_index:
		return false
	set_current_slide(slide_instances[slide_index])
	return true

## returns true if the slide was changed
func set_slide(new_index: int, force_set: bool = false) -> bool:
	var previous_slide_index: int = slide_index
	set_slide_index(new_index)
	if previous_slide_index == slide_index && !force_set:
		return false
	set_current_slide(slide_instances[slide_index])
	return true
	
func set_current_slide(slide_new: Slide) -> void:
	if is_instance_valid(current_slide):
		current_slide.is_currently_active_slide = false
	current_slide = slide_new
	current_slide.is_currently_active_slide = true
	SlideHelper.current_slide = slide_new
	current_slide.reset()
	update_ui_slide_status()
	current_slide.activate_slide.emit()
	SlideHelper.slide_changed.emit(current_slide)

func change_slide_index(change: int) -> void:
	set_slide_index(slide_index + change)
	
func set_slide_index(new_index: int) -> void:
	slide_index = clamp(new_index, 0, slide_instances.size()-1)
	Preferences.set_presentation_progress(slide_index, get_tree().current_scene.scene_file_path)

	SlideHelper.ui.set_current_slide(slide_index)
	
func start_auto_slideshow(update_ui: bool = true) -> void:
	auto_slideshow_timer.start()
	if update_ui:
		SlideHelper.ui.set_auto_slideshow_active(true)

func stop_auto_slideshow(update_ui: bool = true) -> void:
	auto_slideshow_timer.stop()
	if update_ui:
		SlideHelper.ui.set_auto_slideshow_active(false)
		
func update_ui_slide_status() -> void:
	SlideHelper.ui.control_bar.set_slide_status_flags(slide_index == 0, slide_index == slide_instances.size()-1)
	SlideHelper.ui.control_bar.set_slide_progress_flags(slide_instances[slide_index].is_at_start(), slide_instances[slide_index].is_finished())

func _on_auto_slideshow_timer_timeout() -> void:
	do_continue(true)
	if slide_index == slide_instances.size()-1 && slide_instances[slide_index].is_finished():
		stop_auto_slideshow(true)
