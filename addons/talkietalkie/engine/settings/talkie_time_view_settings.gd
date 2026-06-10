class_name TimeViewSettings extends Resource

## If true, clock time will be displayed
@export var show_clock_time: bool = true

## If true, passed time will be displayed
@export var show_passed_time: bool = true

## The expected duration of this presentation
@export var target_duration_minutes: int = 20

## If true, the expected duration will be shown
@export var show_target_duration: bool = true

## If true, the remaining time fo the expected duration will be shown
@export var show_time_left: bool = true

## Note: not in use yet
@export var warn_thresholds_minutes: Array[int] = [5]

## If true, the timer for the presentation will automatically start on load
@export var autostart_passed_time_timer: bool = true
