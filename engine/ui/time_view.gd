class_name TimeView
extends Control


@export var show_clock_time: bool = true
@export var show_passed_time: bool = true
@export var autostart_passed_time_timer: bool = false
@export var target_duration_minutes: int = 20
@export var show_target_duration: bool = true
@export var show_time_left: bool = true #TODO

@export var warn_at_remaining_minutes: int = 5 # TODO

@export_category("internal nodes")
@export var clock_time_value_label: Label
@export var target_duration_value_label: Label
@export var passed_time_value_label: Label
@export var time_left_value_label: Label

@export var clock_time_parent: Control
@export var target_duration_parent: Control
@export var passed_time_parent: Control
@export var time_left_parent: Control

var start_time_ms: int
var timer_running: bool = false
var target_duration_ms: int

func _enter_tree() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	target_duration_ms = minutes_to_ms(target_duration_minutes)
		
func _ready() -> void:
	clock_time_parent.visible = show_clock_time
	target_duration_parent.visible = show_target_duration
	passed_time_parent.visible = show_passed_time
	time_left_parent.visible = show_time_left

	start_time_ms = Time.get_ticks_msec()
	update_clock_time()
	update_target_duration()
	update_time_left()
	update_passed_time()

	if autostart_passed_time_timer:
		start_timer()

func _physics_process(_delta: float) -> void:
	if show_clock_time:
		update_clock_time()
		
	if show_passed_time && timer_running:
		update_passed_time()

	if show_time_left && timer_running:
		update_time_left()

func update_clock_time() -> void:
	clock_time_value_label.text = Time.get_time_string_from_system()
	
func update_target_duration() -> void:
	target_duration_value_label.text = get_timestr_from_ms(target_duration_ms, false, false)

func update_passed_time() -> void:
	passed_time_value_label.text = get_timestr_from_ms(get_passed_time_ms(), false, false)

func update_time_left() -> void:
	time_left_value_label.text = get_timestr_from_ms(target_duration_ms - get_passed_time_ms(), false, false)

func start_timer() -> void:
	timer_running = true
	start_time_ms = Time.get_ticks_msec()
	
func get_passed_time_ms() -> int:
	return Time.get_ticks_msec() - start_time_ms

static func minutes_to_ms(minutes: int) -> int:
	return minutes * 60000

static func get_timestr_from_ms(ms: int, include_ms: bool = true, include_hr_string: bool = true, delimiter: String = ":", ms_delimiter: String = ".") -> String:
	@warning_ignore_start("integer_division")
	var hr_str: String = ""
	if include_hr_string:
		hr_str = str(ms/3600000)+delimiter
	
	var seconds_str: String = str((ms%60000)/1000)
	var minutes_str: String = str((ms%3600000)/60000)

	var time_str: String = hr_str+minutes_str.pad_zeros(2)+delimiter+seconds_str.pad_zeros(2)
	if include_ms:
		var ms_str: String = str(ms)
		if ms_str.length() > 3:
			ms_str = ms_str.erase(0, ms_str.length() - 3)
		time_str = time_str + ms_delimiter + ms_str
	return time_str
	@warning_ignore_restore("integer_division")
