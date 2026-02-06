class_name Slide3DLineMapper
extends Node3D

## Maps the slides to 3D world positions on a straight line.
## Also initializes the 3D context for the TTSlideHelper autoload, which is used for 3D transition.

@export var target_parent: Node3D
@export var slide_separation: Vector3 = Vector3(1, 0, -50)
@export var slide_parent_scene: PackedScene = null


func _ready() -> void:
	if target_parent == null:
		target_parent = self
	
	map_slides_to_2d()
	
func map_slides_to_2d() -> void:
	var slide_context: SlideContext3D = TTSlideHelper.get_context_3d()
	var slide_size_3d: Vector3 = Vector3(slide_context.slide_size.x, slide_context.slide_size.y, 0.0) 
	
	var children: Array[Slide] = Util.collect_slides_in_children(target_parent)
	var direction: Vector3 = slide_separation.normalized()
			
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
		
		#TODO: we probably need a subviewport here
		child.reparent(slide_parent)
		child.position = Vector2.ZERO
	
