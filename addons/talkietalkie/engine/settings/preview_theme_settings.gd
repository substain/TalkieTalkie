class_name PreviewThemeSettings extends Resource

## if true, resizing the side window should keep the relative position of the embedded preview windows
@export var scale_on_resize: bool = true
## if true, resizing the side window should also scale the embedded preview windows
@export var keep_rel_pos_on_resize: bool = true
@export var background_color: Color = Color("d2d3e8")
@export var element_seen_modulate: Color = Color.WHITE
@export var element_unseen_modulate: Color = Color(Color.RED, 0.4)
@export var info_color: Color = Color("666666")
