class_name ManualScrollContainer
extends ScrollContainer

const SCROLL_STEP: int = 50

@export var _scroll_backward_button: Button
@export var _scroll_forward_button: Button
@export var _unhover_timer: Timer

var _is_scroll_active: bool = false
var _current_slide_tab: Control = null

func _ready() -> void:
	set_scrollbuttons_visible(false)
	set_hovered(false)
	
func _on_gui_input(event: InputEvent) -> void:
	print("_on_gui_input: ", event)

func set_scroll_active(is_scroll_active_new: bool) -> void:
	_is_scroll_active = is_scroll_active_new
	horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_SHOW_NEVER if is_scroll_active_new else ScrollContainer.SCROLL_MODE_DISABLED
	_unhover_timer.start()

	set_scrollbuttons_visible(is_scroll_active_new)

func set_scrollbuttons_visible(sb_visible_new: bool) -> void:
	_scroll_backward_button.visible = sb_visible_new
	_scroll_forward_button.visible = sb_visible_new

func set_hovered(is_hovered: bool) -> void:
	if !_is_scroll_active:
		return
	TTSlideHelper.is_tab_hover_active = is_hovered

	if is_hovered:
		_unhover_timer.start()
		horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_SHOW_ALWAYS
	else:
		_unhover_timer.stop()
		jump_to_current_slide_tab()
		horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_SHOW_NEVER 

func _on_unhover_timer_timeout() -> void:
	if !_is_scroll_active:
		return
	horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_SHOW_NEVER 
	TTSlideHelper.is_tab_hover_active = false

func set_current_slide_tab(slide_tab_child: Control) -> void:
	_current_slide_tab = slide_tab_child
	jump_to_current_slide_tab()

func jump_to_current_slide_tab() -> void:
	if _current_slide_tab == null:
		push_warning("can't jump to a null tab element")
		return
	ensure_control_visible(_current_slide_tab)

func _on_scroll_backward_button_pressed() -> void:
	_unhover_timer.start()
	set_h_scroll(max(get_h_scroll()-SCROLL_STEP, 0))

func _on_scroll_forward_button_pressed() -> void:
	_unhover_timer.start()
	set_h_scroll(min(get_h_scroll()+SCROLL_STEP, get_h_scroll_bar().max_value))
