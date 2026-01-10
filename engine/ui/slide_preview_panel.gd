class_name SlidePreview extends Window

signal slide_updated

## specifies the target slide for this component, relative to the current visible slide in the presentation
@export var offset_from_current_slide: int = 0
@export var bg_color: Color
@export_range(5, 100) var max_slide_title_length: int = 15
@export var min_y_pos: int = 140
@export_category("internal nodes")
@export var color_rect: ColorRect
#@export var bg_color: Color = Color("9999BBDD")
#@export var preview_current_slide_bg_color: Color = Color("DDDDEEDD")
#@export var preview_next_slide_bg_color: Color = Color("AAAABBDD")

var preview_window_resize_keep_rel_pos: bool = true
var preview_window_resize_scale: bool = true

var current_slide: Slide = null
var parent_window: Window

var slide_size: Vector2 = Vector2.ZERO
var current_window_size: Vector2 = Vector2.ZERO

var rel_center_target: Vector2
var rel_base_size: Vector2 = Vector2.ONE
var start_pos: Vector2

var target_resolution: float

var window_title_prefix: String

# used to ensure resize signals by code are not triggered
var ignore_next_resize_signal: bool = false

func _enter_tree() -> void:
	start_pos = position
	SlideHelper.context_initialized.connect(_on_slide_context_initialized)
	SlideHelper.slide_changed.connect(_on_slide_changed)
	parent_window = get_parent().get_window()
	rel_center_target = get_rel_center_pos()
	update_relative_size()

	window_title_prefix = title
	update_window_by_slide()
	
func _ready() -> void:
	size_changed.connect(_on_size_changed)

func _on_slide_context_initialized() -> void:
	slide_size = SlideHelper.get_context().slide_size
	target_resolution = slide_size.x / slide_size.y
	
func _on_slide_changed(new_slide: Slide) -> void:
	update_slide(new_slide.get_order_index())
	
func update_slide(new_index: int) -> void:
	free_current_slide()
	var slide_index: int = new_index + offset_from_current_slide
	if slide_index < 0 || slide_index >= SlideHelper.slide_controller.slide_instances.size():
		update_window_by_slide()
		return
	var slide: Slide = SlideHelper.slide_controller.slide_instances.get(slide_index)
	load_slide(slide)
	update_window_by_slide()

func free_current_slide() -> void:
	if current_slide != null:
		current_slide.queue_free()
		current_slide = null
		
func load_slide(slide: Slide) -> void:
	current_slide = slide.duplicate() as Slide
	add_child(current_slide)
	current_slide.visible = true
	current_slide.modulate = Color.WHITE
	current_slide.set_progress(1.0)
	current_slide.set_anchors_preset(Control.PRESET_FULL_RECT)
	update_slide_scale()
	slide_updated.emit()

func update_window_by_slide() -> void:
	color_rect.color = Color.BLACK if current_slide == null else bg_color
	var title_suffix: String = "-" if current_slide == null else current_slide.get_title()
	if title_suffix.length() > max_slide_title_length:
		title_suffix = title_suffix.substr(0, max_slide_title_length-3) + "..."
	elif title_suffix.is_empty():
		title_suffix = "?"
	 
	title = tr(window_title_prefix) + ": " + title_suffix

func _on_size_changed() -> void:
	if ignore_next_resize_signal:
		ignore_next_resize_signal = false
		return
	#previous_size = size
	update_relative_size()
	do_resize(false)
	
func on_resize_parent_window(new_window_size: Vector2) -> void:
	current_window_size = new_window_size

	do_resize(true)
	
func do_resize(update_this_window_size: bool) -> void:
	max_size = current_window_size * 0.8
	if !SlideHelper.has_context:
		return
	
	var target_size: Vector2 = Vector2(max_size.x * rel_base_size.x, max_size.y * rel_base_size.y)
	if set_preview_window_resize_scale:
		if update_this_window_size:
			# we need to backup/restore rel_base_size because we don't want to change it here, but the signal
			# does not differentiate between updates via gui and updates via code
			ignore_next_resize_signal = true
			size = target_size
			
		update_slide_scale()
			
	if preview_window_resize_keep_rel_pos:
		move_to_rel_center(rel_center_target)

	recenter_slide_in_window()

func update_slide_scale() -> void:
	if current_slide == null:
		return
	var new_scale: float
	if float(size.x) / float(size.y) > target_resolution:
		new_scale = (size.y / slide_size.y)
	else:
		new_scale = (size.x / slide_size.x)
	current_slide.scale = Vector2.ONE * new_scale

func recenter_slide_in_window() -> void:
	if current_slide == null:
		return
	#current_slide.position = Vector2.ONE
	var window_center: Vector2 = size/2
	var slide_center: Vector2 = (current_slide.size * current_slide.scale)/2
	var offset: Vector2 = window_center - slide_center
	current_slide.position = offset

	
func _notification(what: int) -> void:
	# NOTE: this will only be called if the position was actively changed. 
	# the position may still change from other sources, e.g. if the parent window is resized
	if what == NOTIFICATION_WM_POSITION_CHANGED:
		if position.y < min_y_pos:
			position.y = min_y_pos

		var do_request_close: bool = false
		if position.x + size.x < 0 || position.x > parent_window.size.x:
			position = start_pos
			do_request_close = true
			
		if position.y + size.y < 0 || position.y > parent_window.size.y:
			position = start_pos
			do_request_close = true
			
		rel_center_target = get_rel_center_pos()
		
		if do_request_close:
			close_requested.emit()
			
		
func update_relative_size() -> void:
	rel_base_size = Vector2(float(size.x)/parent_window.size.x, float(size.y)/parent_window.size.y)

func move_to_rel_center(rel_center_pos_new: Vector2) -> void:
	position = (as_vec2f(parent_window.size) * rel_center_pos_new)-as_vec2f(size/2)
	
func get_rel_center_pos() -> Vector2:
	return get_center_pos() / as_vec2f(parent_window.size)
	
func get_center_pos() -> Vector2:
	return position + (size / 2)

func set_preview_window_resize_keep_rel_pos(keep_rel_pos_new: bool) -> void:
	preview_window_resize_keep_rel_pos = keep_rel_pos_new

func set_preview_window_resize_scale(do_scale_new: bool) -> void:
	preview_window_resize_scale = do_scale_new

## converts a Vector2i (int) to a Vector2 (float)
static func as_vec2f(vec2i: Vector2i) -> Vector2:
	return Vector2(vec2i.x, vec2i.y)
