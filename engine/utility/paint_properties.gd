class_name PaintProperties 
extends Resource


@export var color: Color = Color.RED
@export var thickness: float = 1.0

## Number of trail points. The more points, the longer a drawn trail will be. 
## If this is < 1, this is not interpreted as trail
@export var trail_points: int = 20

## The maximum amount a line will be shown until it is removed. Especially important for non-trail lines.
@export var time_alive: float
@export var icon: Texture2D
@export var icon_scale: float = true
@export var modulate_icon_with_color: bool = true
	
func _init(
			color_new: Color, 
			thickness_new: float,
			trail_points_new: int,
			time_alive_new: float,			
			icon_new: Texture2D,
			icon_scale_new: float,
			modulate_icon_with_color_new: bool) -> void:
	time_alive = time_alive_new
	color = color_new
	thickness = thickness_new
	trail_points = trail_points_new
	icon = icon_new
	icon_scale = icon_scale_new
	modulate_icon_with_color = modulate_icon_with_color_new
