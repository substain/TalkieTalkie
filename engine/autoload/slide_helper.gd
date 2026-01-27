extends Node
# Autoload

signal context_initialized

@warning_ignore_start("unused_signal")
signal slide_changed(new_slide: Slide)
signal progress_changed(new_progress: float)
signal pointing_at_pos(global_pos: Vector2, is_drawing: bool, paint_properties: PaintProperties)
signal stop_drawing()
signal restore_side_window()
@warning_ignore_restore("unused_signal")

var presentation: Presentation
var ui: UI
var slide_controller: SlideController
var current_slide: Slide
var has_context: bool
var _context: SlideContext

func is_2d_node_presentation() -> bool:
	return _context is SlideContext2D
	
func is_3d_node_presentation() -> bool:
	return _context is SlideContext3D
	
func is_control_node_presentation() -> bool:
	return !is_2d_node_presentation() && !is_3d_node_presentation()
	
func set_context(slide_context_new: SlideContext) -> void:
	_context = slide_context_new
	if _context != null:
		context_initialized.emit()
		has_context = true
	else:
		has_context = false
	
func get_context() -> SlideContext:
	return _context

func get_context_2d() -> SlideContext2D:
	assert(_context is SlideContext2D)
	return _context as SlideContext2D
	
func get_context_3d() -> SlideContext3D:
	assert(_context is SlideContext3D)
	return _context as SlideContext3D
