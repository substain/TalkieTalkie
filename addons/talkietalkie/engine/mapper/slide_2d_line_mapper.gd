class_name Slide2DLineMapper
extends Node2D

## Maps the slides to 2D world positions on a straight line.
## Also sets the slide center positions for the 2D context for the TTSlideHelper autoload, which is used for 2D transition.

@export var target_parent: Node
@export var slide_separation: Vector2 = Vector2(200, 0)
@export var slide_parent_scene: PackedScene = null
@export var theme_source: Control = null

func _ready() -> void:
	if target_parent == null:
		target_parent = self
	
	if TTSlideHelper.get_context() != null:
		map_slides_to_2d()
	else:
		TTSlideHelper.context_initialized.connect(map_slides_to_2d)
	
func map_slides_to_2d() -> void:
	var slide_context: SlideContext2D = TTSlideHelper.get_context_2d()
	var slide_size: Vector2 = slide_context.slide_size
	
	var theme: Theme = get_theme(target_parent, theme_source)
	
	var children: Array[Slide] = Util.collect_slides_in_children(target_parent)
	var direction: Vector2 = slide_separation.normalized()
	var slide_center_locations: Dictionary[Vector2, Slide] = {}
		
	for i: int in children.size():
		var child: Slide = children[i]
		var new_pos: Vector2 = i*(slide_size * direction + slide_separation)

		var slide_parent: Node2D = null
		if slide_parent_scene != null:
			slide_parent = slide_parent_scene.instantiate() as Node2D
		else:
			slide_parent = Node2D.new()
			
		target_parent.add_child(slide_parent)
		slide_parent.name = child.name + "_P2D"
		slide_parent.global_position = new_pos
		slide_center_locations[new_pos + slide_context.slide_center_offset] = child 
		child.reparent(slide_parent)
		
		# NOTE: needed until we have theme propagation via Node2D (see https://github.com/godotengine/godot-proposals/issues/9132)
		if theme != null:
			child.theme = theme
		
		@warning_ignore("unsafe_property_access")
		child.position = Vector2.ZERO
	slide_context.slide_center_locations = slide_center_locations

static func get_theme(theme_target_parent: Node, theme_parent_opt: Control) -> Theme:
	if theme_parent_opt != null:
		return theme_parent_opt.theme
		
	if theme_target_parent is Control && (theme_target_parent as Control).theme != null:
		return (theme_target_parent as Control).theme
		
	return null
