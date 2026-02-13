@tool
class_name PresentationGenerator
extends RefCounted

static var _PRESENTATION_BASE_PATH: String = TTSetup.get_plugin_path() + "/engine/base/presentation.tscn"
static var _PRESENTATION_BASE_SCENE: PackedScene = load(_PRESENTATION_BASE_PATH)
static var _DEFAULT_TITLE_LAYOUT_SCENE: PackedScene = load(TTSetup.get_plugin_path() + "/engine/default_template/default_title_layout.tscn")
#
enum PresentationType {
	CONTROL,
	TWO_D,
	THREE_D
}

enum BackgroundType {
	NONE,
	COLOR,
	SCENE
}

class PresentationGenerationData:
	var target_file_path: String
	var presentation_name: String
	var presentation_type: PresentationType
	var add_camera_node: bool
	var background_type: BackgroundType
	var background_file_path: String
	var background_color: Color
	
	var create_title_slide: bool
	var create_content_from_md: bool
	var content_md_text: String
	var selected_theme: Theme
	
	func _init(
		target_file_path_new: String,
		presentation_name_new: String,
		presentation_type_new: PresentationType,
		add_camera_node_new: bool,
		background_type_new: BackgroundType,
		background_file_path_new: String,
		background_color_new: Color,
		create_title_slide_new: bool,
		create_content_from_md_new: bool,
		content_md_text_new: String,
		selected_theme_new: Theme) -> void:
			
		target_file_path = target_file_path_new
		presentation_name = presentation_name_new
		presentation_type = presentation_type_new
		add_camera_node = add_camera_node_new
		background_type = background_type_new
		background_file_path = background_file_path_new
		background_color = background_color_new
		create_title_slide = create_title_slide_new
		create_content_from_md = create_content_from_md_new
		content_md_text = content_md_text_new
		selected_theme = selected_theme_new
	
static func do_generate(pg_data: PresentationGenerationData, do_save: bool = true) -> void:
	
	## 1) open an inherited scene from talkietalkie/engine/base/presentation.tscn in the editor
	EditorInterface.open_scene_from_path(_PRESENTATION_BASE_PATH, true)
	
	## 2) setup and add nodes according to the configuration
	setup_presentation(pg_data, EditorInterface.get_edited_scene_root() as Presentation)	

	if do_save:
		## 3) save inherited scene based on the selected target file path
		EditorInterface.call_deferred("save_scene_as", pg_data.target_file_path, false) # save as scene

static func setup_presentation(pg_data: PresentationGenerationData, presentation: Presentation) -> void:
	
	var slide_parent_node: Control = Control.new()
	slide_parent_node.mouse_filter = Control.MOUSE_FILTER_PASS
	
	## if we're swapping the presentation script (to 2D or 3D), we need to save node references
	var ui: UI = presentation.ui
	var slide_controller: SlideController = presentation.slide_controller
	
	if pg_data.presentation_type == PresentationType.CONTROL:
		## The default presentation: only a control node as parent for the slides
		
		## add the slide_parent_node as base for the slides
		add_node_to_scene(slide_parent_node, presentation, presentation, "Slides")
		
	elif pg_data.presentation_type == PresentationType.TWO_D:
		## A 2D presentation: slides may be mapped on a 2D plane, and a Camera2D is used

		## use a Presentation2D as base node for the presentation
		presentation.set_script(load(TTSetup.get_plugin_path() + "/engine/base/presentation_2d.gd"))
		presentation.ui = ui
		presentation.slide_controller = slide_controller
		
		if pg_data.add_camera_node:
		## add a camera2D and reference it in the presentation2D
			var camera_2d: Camera2D = Camera2D.new()
			add_node_to_scene(camera_2d, presentation, presentation, "Camera2D")
			(presentation as Presentation2D).camera = camera_2d

		## prepare a slide 2D line mapper
		var slide_mapper_2d: Node2D = Node2D.new()
		slide_mapper_2d.set_script(load(TTSetup.get_plugin_path() + "/engine/mapper/slide_2d_line_mapper.gd"))
		add_node_to_scene(slide_mapper_2d, presentation, presentation, "Slide2DMapper")

		## add the slide_parent_node as base for the slides
		add_node_to_scene(slide_parent_node, slide_mapper_2d, presentation, "Slides")
		(slide_mapper_2d as Slide2DLineMapper).target_parent = slide_parent_node
		#slide_base_node.set_process(true) #we don't actually need this now, but we may if we want to add _process() to this later
	
	elif pg_data.presentation_type == PresentationType.THREE_D:
		## A 3D presentation: slides may be mapped on a 3D plane, and a Camera3D is used
		
		## use a Presentation3D as base node for the presentation
		presentation.set_script(load(TTSetup.get_plugin_path() + "/engine/base/presentation_3d.gd"))
		presentation.ui = ui
		presentation.slide_controller = slide_controller
		
		if pg_data.add_camera_node:
			## add a camera3D and reference it in the presentation3D
			var camera_3d: Camera3D = Camera3D.new()
			add_node_to_scene(camera_3d, presentation, presentation, "Camera3D")
			(presentation as Presentation3D).camera = camera_3d
			
		## prepare a slide 3D line mapper
		var slide_mapper_3d: Node3D = Node3D.new()
		slide_mapper_3d.set_script(load(TTSetup.get_plugin_path() + "/engine/mapper/slide_3d_line_mapper.gd"))
		add_node_to_scene(slide_mapper_3d, presentation, presentation, "Slide3DMapper")

		## add the slide_parent_node as base for the slides
		add_node_to_scene(slide_parent_node, slide_mapper_3d, presentation, "Slides")
		(slide_mapper_3d as Slide3DLineMapper).target_parent = slide_parent_node
		#slide_base_node.set_process(true) #we don't actually need this now, but we may if we want to add _process() to this later

	if pg_data.selected_theme != null:
		slide_parent_node.theme = pg_data.selected_theme

	## Set the name of the presentation according to the configuration
	presentation.presentation_name = pg_data.presentation_name
	var presentation_node_name: String = pg_data.presentation_name.replace(" ", "")
	if !pg_data.presentation_name.to_lower().contains("presentation"):
		## append 'Presentation' to the node name if the name does not already contain "Presentation"
		presentation_node_name = pg_data.presentation_name + "Presentation"
	presentation.name = presentation_node_name

	## generate title and markdown slides
	create_slide_content(pg_data, presentation, slide_parent_node)
	
	## add background
	add_background(pg_data, presentation)
		
static func create_slide_content(pg_data: PresentationGenerationData, presentation: Presentation, slide_parent_node: Node) -> void:

	## add slide generator to use either right now or later on
	var slide_generator_node: Node = Node.new()
	slide_generator_node.set_script(load(TTSetup.get_plugin_path() + "/engine/generation/slide_generator.gd"))
	(slide_generator_node as SlideGenerator).line_format_rules = [load(TTSetup.get_plugin_path() + "/engine/resources/bullet_point_lfr.tres")]
	add_node_to_scene(slide_generator_node, presentation, presentation, "SlideGenerator")

	if pg_data.create_title_slide:
		## instantiate title slide template
		var title_slide: SceneSlide = _DEFAULT_TITLE_LAYOUT_SCENE.instantiate(PackedScene.GEN_EDIT_STATE_INSTANCE) as Slide
		add_node_to_scene(title_slide, slide_parent_node, presentation, "SlideTitle")
		Util.make_instantiated_scene_local(title_slide, presentation) #get_tree().edited_scene_root
		
		## set title to the presentation name and hide intro / subtitle label 
		(title_slide.get_node("TitleControl/TitleLabel") as RichTextLabel).text = pg_data.presentation_name
		title_slide.get_node("IntroLabel").visible = false
		title_slide.get_node("SubTitleLabel").visible = false
		title_slide.slide_title = "Title"
		title_slide.slide_content = pg_data.presentation_name
		title_slide.set_display_folded(true)

	if pg_data.create_content_from_md && !pg_data.content_md_text.is_empty():
		var slide_generator: SlideGenerator = slide_generator_node as SlideGenerator #presentation.get_node("SG")
		
		EditorInterface.save_scene_as(pg_data.target_file_path, false)

		## set slide generator input from configured markdown text
		slide_generator.input_text = pg_data.content_md_text
		
		## set the parent node for the slides to be created
		slide_generator.target_parent = slide_parent_node

		## setup the template scenes for the generated slides
		slide_generator.slide_scene = load(TTSetup.get_plugin_path() + "/engine/default_template/default_text_layout.tscn")
		slide_generator.content_scene = load(TTSetup.get_plugin_path() + "/engine/default_template/default_content_element.tscn")
		
		## generate slides from markdown
		slide_generator.do_generate()

static func add_background(pg_data: PresentationGenerationData, presentation: Presentation) -> void:
	if pg_data.background_type == BackgroundType.NONE || (pg_data.background_type == BackgroundType.SCENE && pg_data.background_file_path.is_empty()):
		return
	var background_parent: Node = presentation.get_node("Background")
	
	if pg_data.background_type == BackgroundType.COLOR:
		## create new color rect, set its color and add it below the Background node
		var bg_node: ColorRect = ColorRect.new()
		bg_node.color = pg_data.background_color
		add_node_to_scene(bg_node, background_parent, presentation, "BGColorRect")
		## set background anchors to full rect
		bg_node.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		
	elif pg_data.background_type == BackgroundType.SCENE:
		## instantiate the background scene, and add it below the Background node	
		var background_scene: Node = (load(pg_data.background_file_path) as PackedScene).instantiate(PackedScene.GEN_EDIT_STATE_INSTANCE) as Node
		add_node_to_scene(background_scene, background_parent, presentation)
		## set background anchors to full rect
		background_scene.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

static func add_node_to_scene(node: Node, parent: Node, target_owner: Node, node_name: String = "") -> void:
	parent.add_child(node)
	if !node_name.is_empty():
		node.name = node_name
	node.owner = target_owner
