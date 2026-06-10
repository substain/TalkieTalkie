extends Node
# Autoload

signal context_initialized

@warning_ignore_start("unused_signal")
signal slide_changed(new_slide: TalkieSlide)
signal progress_changed(new_progress: float)
signal pointing_at_pos(global_pos: Vector2, is_drawing: bool, draw_properties: TalkieDrawProperties)
signal stop_drawing()
signal restore_side_window()
signal side_window_settings_updated()
@warning_ignore_restore("unused_signal")

var presentation: TalkiePresentation
var ui: TalkieUI
var slide_controller: TalkieSlideController
var current_slide: TalkieSlide
var has_context: bool
var _context: TalkieSlideContext
var is_side_window_restorable: bool = false
var is_tab_hover_active: bool = false

func is_2d_node_presentation() -> bool:
	return _context is TalkieSlideContext2D
	
func is_3d_node_presentation() -> bool:
	return _context is TalkieSlideContext3D
	
func is_control_node_presentation() -> bool:
	return !is_2d_node_presentation() && !is_3d_node_presentation()
	
func set_context(slide_context_new: TalkieSlideContext) -> void:
	_context = slide_context_new
	if _context != null:
		context_initialized.emit()
		has_context = true
	else:
		has_context = false
	
func get_context() -> TalkieSlideContext:
	return _context

func get_context_2d() -> TalkieSlideContext2D:
	assert(_context is TalkieSlideContext2D)
	return _context as TalkieSlideContext2D
	
func get_context_3d() -> TalkieSlideContext3D:
	assert(_context is TalkieSlideContext3D)
	return _context as TalkieSlideContext3D
