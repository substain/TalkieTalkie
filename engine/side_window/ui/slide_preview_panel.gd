class_name SlidePreview extends Window

const REL_INDEX_PREVIOUS: int = -1
const REL_INDEX_CURRENT: int = 0
const REL_INDEX_NEXT: int = 1

const MAX_REL_SIZE: float = 0.8

signal slide_updated
signal preview_layout_settings_updated

## specifies the target slide for this component, relative to the current visible slide in the presentation
@export var offset_from_current_slide: int = 0

@export_range(5, 100) var max_slide_title_length: int = 15
@export var min_y_pos: int = 140
@export_category("internal nodes")
@export var color_rect: ColorRect

var current_slide: Slide = null
var original_slide: Slide = null
var parent_window: Window

var slide_size: Vector2 = Vector2.ZERO
var current_window_size: Vector2 = Vector2.ZERO

var rel_center_target: Vector2
var relative_size_to_window: Vector2

var start_pos: Vector2

var target_resolution: float

var window_title_prefix: String

# used to ensure resize signals by code are not triggered
var ignore_next_resize_signal: bool = false

var preview_layout_settings: PreviewLayoutSettings = PreviewLayoutSettings.new() #these settings may be updated / saved
var preview_theme_settings: PreviewThemeSettings = PreviewThemeSettings.new() #readonly

var initialized: bool = false

func _enter_tree() -> void:
	preview_layout_settings = PreviewLayoutSettings.load_default(offset_from_current_slide)
	start_pos = position
	SlideHelper.context_initialized.connect(_on_slide_context_initialized)
	SlideHelper.slide_changed.connect(_on_slide_changed)
	if offset_from_current_slide == 0:
		SlideHelper.progress_changed.connect(_on_slide_progress_changed)
	parent_window = get_parent().get_window()
	rel_center_target = get_rel_center_pos()
	update_relative_size()

	window_title_prefix = title
	update_window_by_slide()
	if SlideHelper.has_context:
		_on_slide_context_initialized()
		load_slide_by_index(SlideHelper.current_slide._order_index)
	
func _ready() -> void:
	size_changed.connect(_on_size_changed)
		
func _on_slide_context_initialized() -> void:
	slide_size = SlideHelper.get_context().slide_size
	target_resolution = slide_size.x / slide_size.y

func _on_slide_changed(new_slide: Slide) -> void:
	load_slide_by_index(new_slide.get_order_index())
	
func load_slide_by_index(new_index: int) -> void:
	free_current_slide()
	var slide_index: int = new_index + offset_from_current_slide
	if slide_index < 0 || slide_index >= SlideHelper.slide_controller.slide_instances.size():
		update_window_by_slide()
		return
		
	original_slide = SlideHelper.slide_controller.slide_instances.get(slide_index)
	var packed_scene: PackedScene = SlideHelper.get_context().slide_templates[slide_index]
	
	load_slide_by_packed_scene(packed_scene)
	update_window_by_slide()

func free_current_slide() -> void:
	if current_slide != null:
		current_slide.queue_free()
		current_slide = null
		
func load_slide_by_packed_scene(packed_scene: PackedScene) -> void:
	current_slide = packed_scene.instantiate() as Slide
	add_child(current_slide)
	current_slide.visible = true
	current_slide.modulate = Color.WHITE
	current_slide.is_currently_active_slide = false
	await get_tree().process_frame
	current_slide.show_full()
	current_slide.set_anchors_preset(Control.PRESET_FULL_RECT)
	update_slide_scale()
	recenter_slide_in_window()
	if current_slide is SceneSlide && (current_slide as SceneSlide).preview_info_elements != null && !(current_slide as SceneSlide).preview_info_elements.is_empty():
		for info_element: Node in (current_slide as SceneSlide).preview_info_elements:
			if info_element is Control:
				(info_element as Control).add_theme_color_override("default_color", preview_theme_settings.info_color)
				
	if offset_from_current_slide == 0:
		_on_slide_progress_changed.call_deferred(original_slide.get_progress())
		
	slide_updated.emit()

func get_copy_node_with_same_path(original_node: Node) -> Node:
	if original_node == null:
		return null
	var rel_path: NodePath = original_slide.get_path_to(original_node)
	return current_slide.get_node_or_null(rel_path)

func update_window_by_slide() -> void:
	color_rect.color = Color.BLACK if current_slide == null else preview_theme_settings.background_color
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
	update_relative_size()
	do_resize(false)
	
func on_resize_parent_window(new_window_size: Vector2) -> void:
	current_window_size = new_window_size
	max_size = current_window_size * MAX_REL_SIZE

	do_resize(true)
	
func do_resize(update_this_window_size: bool) -> void:
	if !SlideHelper.has_context: # this ensures slide_size is valid
		return
	
	var target_size: Vector2 = Vector2(current_window_size.x * relative_size_to_window.x, current_window_size.y * relative_size_to_window.y)
	if preview_theme_settings.keep_rel_pos_on_resize:
		if update_this_window_size:
			# ensure the next signal that will be emitted by setting the size will not re-evaluate
			# (the signal does not differentiate between updates via gui and updates via code)
			ignore_next_resize_signal = true
			size = target_size
			
			
		update_slide_scale()
			
	if preview_theme_settings.scale_on_resize:
		move_to_rel_center(rel_center_target)

	recenter_slide_in_window()
	update_settings()

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
	@warning_ignore("integer_division")
	var window_center: Vector2 = size/2
	var slide_center: Vector2 = (current_slide.size * current_slide.scale)/2
	var offset: Vector2 = window_center - slide_center
	current_slide.position = offset
	
func _notification(what: int) -> void:
	# NOTE: the following notification will only be called if the position was actively changed. 
	# the position may still change from other sources, e.g. if the parent window is resized
	if what == NOTIFICATION_WM_POSITION_CHANGED:
		_on_position_updated()
		
func _on_position_updated() -> void:
	if position.y < min_y_pos:
		position.y = min_y_pos

	var do_request_close: bool = false
	if position.x + size.x < 0 || position.x > parent_window.size.x:
		position = start_pos
		do_request_close = true
		
	if position.y + size.y < 0 || position.y > parent_window.size.y:
		position = start_pos
		do_request_close = true

	preview_layout_settings.position = position
	rel_center_target = get_rel_center_pos()

	if do_request_close:
		close_requested.emit()
		
	update_settings()
		
func _on_slide_progress_changed(_new_progress: float) -> void:
	if original_slide == null || current_slide == null:
		return
	
	var progress_elements: Dictionary[Variant, bool] = original_slide.get_progress_elements()
	for elem: Variant in progress_elements.keys():
		
		var is_elem_visible: bool = progress_elements[elem] == true
		
		if elem is Array:
			handle_progress_elem_array(elem as Array, is_elem_visible)
		elif elem is SlideAnimation:
			handle_progress_elem_animation(elem as SlideAnimation, is_elem_visible)

func handle_progress_elem_array(arr: Array, is_elem_visible: bool) -> void:
	for node: Node in arr:
			if is_elem_visible:
				if node is CanvasItem:
					var copied_node: CanvasItem = get_copy_node_with_same_path(node) as CanvasItem
					if copied_node != null:
						copied_node.modulate = preview_theme_settings.element_seen_modulate
					else:
						print("could not get node from path: ", original_slide.get_path_to(node))
			else:
				if node is CanvasItem:
					var copied_node: CanvasItem = get_copy_node_with_same_path(node) as CanvasItem
					if copied_node != null:
						copied_node.modulate = preview_theme_settings.element_unseen_modulate
					else:
						print("could not get node from path: ", original_slide.get_path_to(node))
		
func handle_progress_elem_animation(anim: SlideAnimation, is_elem_visible: bool) -> void:
	#var source_anim: SlideAnimation = elem as SlideAnimation
	if !(current_slide is AnimSlide) || !(original_slide is AnimSlide):
		return
	var anim_pos: int = (original_slide as AnimSlide).animations.find(anim)
	var target_anim_copy: SlideAnimation = (current_slide as AnimSlide).animations[anim_pos]
	
	for copied_node: Node in target_anim_copy.targets:
			if is_elem_visible:
				if copied_node is CanvasItem:
					if copied_node != null:
						(copied_node as CanvasItem).modulate = preview_theme_settings.element_seen_modulate
			else:
				if copied_node is CanvasItem:
					if copied_node != null:
						(copied_node as CanvasItem).modulate = preview_theme_settings.element_unseen_modulate
	
func update_relative_size() -> void:
	relative_size_to_window = Vector2(float(size.x)/parent_window.size.x, float(size.y)/parent_window.size.y)

func move_to_rel_center(rel_center_pos_new: Vector2) -> void:
	@warning_ignore("integer_division")
	position = (as_vec2f(parent_window.size) * rel_center_pos_new)-as_vec2f(size/2)
	update_settings()

func update_settings() -> void:
	if !initialized:
		return
	preview_layout_settings.size = size
	preview_layout_settings.position = position
	preview_layout_settings_updated.emit()
	#print("updated settings...")

func load_settings(preview_layout_settings_new: PreviewLayoutSettings) -> void:
	var target_pos: Vector2 = preview_layout_settings.position
	target_pos = SideWindow.constrain_to_bounds(target_pos, preview_layout_settings.size, Rect2(Vector2(0, min_y_pos), parent_window.size), 0)

	await get_tree().process_frame
	
	preview_layout_settings = preview_layout_settings_new

	ignore_next_resize_signal = true
	size = preview_layout_settings.size
	update_relative_size()
	start_pos = target_pos
	position = target_pos
	rel_center_target = get_rel_center_pos()
	recenter_slide_in_window()
	initialized = true

	
func get_rel_center_pos() -> Vector2:
	return get_center_pos() / as_vec2f(parent_window.size)
	
func get_center_pos() -> Vector2:
	@warning_ignore("integer_division")
	return position + (size / 2)
	
func set_preview_theme_settings(preview_theme_settings_new: PreviewThemeSettings) -> void:
	preview_theme_settings = preview_theme_settings_new

func update_is_shown(is_shown_new: bool) -> void:
	preview_layout_settings.is_shown = is_shown_new
	update_settings()

# recursively gets all children with filter option, with signature:
# func filter(node: Node) -> bool
# e.g. node is BaseButton
static func collect_nodes_in_children(node: Node, filter: Callable) -> Array[Node]:
	var res: Array[Node] = []
	if filter.call(node):
		res.append(node)
		
	for child: Node in node.get_children():
		var children_nodes: Array[Node]= collect_nodes_in_children(child, filter)
		res.append_array(children_nodes)
				
	return res

## converts a Vector2i (int) to a Vector2 (float)
static func as_vec2f(vec2i: Vector2i) -> Vector2:
	return Vector2(vec2i.x, vec2i.y)
