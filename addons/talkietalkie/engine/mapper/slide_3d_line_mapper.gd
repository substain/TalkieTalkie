class_name Slide3DLineMapper
extends Node3D

## Maps the slides to 3D world positions on a straight line.
## Also initializes the 3D context for the TTSlideHelper autoload, which is used for 3D transition.

@export var target_parent: Node
@export var slide_separation: Vector3 = Vector3(1, 0, -50)
@export var slide_parent_scene: PackedScene = null
@export var theme_source: Control = null

func _ready() -> void:
	if target_parent == null:
		target_parent = self
	
	if TTSlideHelper.get_context() != null:
		map_slides_to_3d()
	else:
		TTSlideHelper.context_initialized.connect(map_slides_to_3d)
		
func map_slides_to_3d() -> void:
	var slide_context: SlideContext3D = TTSlideHelper.get_context_3d()
	var slide_size_3d: Vector3 = Vector3(slide_context.slide_size.x, slide_context.slide_size.y, 0.0) 
	
	var theme: Theme = get_theme(target_parent, theme_source)
	
	var children: Array[Slide] = Util.collect_slides_in_children(target_parent)
	var direction: Vector3 = slide_separation.normalized()
	var slide_center_locations: Dictionary[Vector3, Slide] = {}

	for i: int in children.size():
		var child: Slide = children[i]
		var new_pos: Vector3 = i * (slide_size_3d * direction + slide_separation)

		var slide_parent: Node3D = null
		if slide_parent_scene != null:
			slide_parent = slide_parent_scene.instantiate() as Node3D
		else:
			slide_parent = Node3D.new()
			
		target_parent.add_child(slide_parent)
		slide_parent.name = child.name + "_P3D"
		slide_parent.global_position = new_pos
		slide_center_locations[new_pos + Util.to_vec3(slide_context.slide_center_offset, 0)] = child 
		child.reparent(slide_parent)
		
		# NOTE: needed until we have theme propagation via Node2D (see https://github.com/godotengine/godot-proposals/issues/9132)
		if theme != null:
			child.theme = theme
		
		#TODO: we probably need a subviewport here
		child.position = Vector2.ZERO
	slide_context.slide_center_locations = slide_center_locations

static func get_theme(theme_target_parent: Node, theme_parent_opt: Control) -> Theme:
	if theme_target_parent != null && theme_target_parent is Control && (theme_target_parent as Control).theme != null:
		return (theme_target_parent as Control).theme
	
	if theme_parent_opt != null:
		return theme_parent_opt.theme
		
	return null
