@tool 
class_name SlideCreator 
extends Node
## Transforms text to multiple Slide nodes

const TITLE_INDICATOR: String = "# "
const BULLET_POINT_INDICATOR: String = "*"
const BULLET_POINT_REGEX: String = "^ *\\*"
const BULLET_POINT_CHAR: String = "•"

static var bullet_point_regex: RegEx

class SlideInfo: 
	var title: String = ""
	#var translated_contents
	var contents: Array[String] = []

## The text that will be converted to Slide scenes
@export_multiline var input_text: String = ""

## The scene that will be instantiated. Is expected to be a Slide scene/node
@export var slide_scene: PackedScene

## The name of the child in slide_scene_to_use that should be used for setting the title of the slide.
## If no name is given, no title will be set. Will also fail if no "text" property exists on that child
@export var slide_title_path: String = "TitleLabel"

## The name of the child in slide_scene_to_use that should be used as parent for the content nodes.
@export var slide_content_parent_path: String = "ContentVBC"

## The scene that will be instantiated for content. Is expected to have a "text" property, will fail otherwise
@export var content_scene: PackedScene

## The parent where the new slides are added. If null, this node will be used as parent
@export var target_parent: Node

## If true, the names of the created slides will be compared to other children in the target_parent.
## If a node with the name already exists, it will be replaced. Note: "ignore_if_slide_name_exists" is preferred over this.
@export var replace_existing_instantiated_slides: bool = true

## If true, the names of the created slides will be compared to other children in the target_parent.
## If a node with the name already exists, no slide will be created.
@export var ignore_if_slide_name_exists: bool = true

## If true, all defined content for a slide is combined into one node (instantiated from content_scene_to_use).
## If false, text will be split up by lines and added as multiple nodes.
@export var combine_content_lines: bool = false

## Creates the slides from the given text.
@export_tool_button("Generate Slides") var generate_btn: Callable = do_generate.bind()

func _ready() -> void:
	bullet_point_regex = RegEx.new()
	bullet_point_regex.compile(BULLET_POINT_REGEX)

func do_generate() -> void:
	bullet_point_regex = RegEx.new()
	bullet_point_regex.compile(BULLET_POINT_REGEX)
	
	var cleaned_text: String = prepare_text(input_text)
	var slide_infos: Array[SlideInfo] = transform_to_line_infos(cleaned_text)
	var _slides: Array[Slide] = instantiate_as_slides(slide_infos)

	for slide_info: SlideInfo in slide_infos:
		print(to_debug_string(slide_info))

func instantiate_as_slides(slide_infos: Array[SlideInfo]) -> Array[Slide]:
	if slide_scene == null:
		push_warning("Cannot instantiate a null slide scene. Ensure slide_scene_to_use is set in the edtior.")
		return []
		
	var res: Array[Slide] = []
	for slide_info: SlideInfo in slide_infos:
		var slide: Slide = instantiate_slide(slide_info)
		if slide != null:
			res.append(slide)
		
	return res

func instantiate_slide(slide_info: SlideInfo) -> Slide:
	var target_parent_node: Node = target_parent if target_parent != null else self
	#print("handling slide info:", slide_info)
	var slide_target_title: String = "Slide" + slide_info.title
	
	if target_parent_node.has_node(slide_target_title):
		if ignore_if_slide_name_exists:
			print("Will not create a new slide for '", slide_target_title, "', a node with that name already exists.")
			return null
		if replace_existing_instantiated_slides:
			print("Replacing existing node '", slide_target_title, "' with a newly generated slide.")
			target_parent_node.get_node(slide_target_title).free()
	
	var slide: Slide = slide_scene.instantiate(PackedScene.GEN_EDIT_STATE_INSTANCE) as Slide
	target_parent_node.add_child(slide)
	slide.name = slide_target_title
	Util.make_instantiated_scene_local(slide, get_tree().edited_scene_root)
	
	set_title(slide, slide_info.title, slide_title_path)
	set_contents(slide, slide_info.contents, slide_content_parent_path, content_scene, combine_content_lines)
		
	return slide

static func set_title(instantiated_slide: Slide, new_title: String, title_node_path: String) -> void:
	instantiated_slide.slide_title = new_title

	if title_node_path == null || !instantiated_slide.has_node(title_node_path):
		push_warning("Could not find title node path '" + title_node_path + "' in the instantiated scene. Will not set a title in the created slide.")
		return
	
	var title_node: Node = instantiated_slide.get_node(title_node_path)
	if !Util.has_text_property(title_node):
		push_warning("Can only set title text on a control with a text property, but '", title_node.name, "' does not have a text property. Setting a title will be skipped.")
		return
	
	@warning_ignore("unsafe_property_access") # We already enssured that property exists.
	title_node.text = new_title

static func set_contents(instantiated_slide: Slide, new_contents: Array[String], content_parent_node_path: String, content_scene_to_use: PackedScene, do_combine_content_lines: bool) -> void:
	if content_parent_node_path == null || !instantiated_slide.has_node(content_parent_node_path):
		push_warning("Could not find content parent node path '" + content_parent_node_path + "' in the instantiated scene. Will not set contents in the created slide.")
		return
		
	var content_parent_node: Node = instantiated_slide.get_node(content_parent_node_path)
	for child: Node in content_parent_node.get_children():
		child.free()
		
	if content_scene_to_use == null:
		push_warning("Cannot instantiate null content scenes. Created slides will have no content. Ensure content_scene_to_use is set in the edtior.")
		return

	if do_combine_content_lines:
		create_content_node(content_parent_node, content_scene_to_use, "\n".join(new_contents))
	else:
		for content_line: String in new_contents:
			create_content_node(content_parent_node, content_scene_to_use, content_line)


static func create_content_node(content_parent: Node, content_scene_to_use: PackedScene, content_text: String) -> void:
	var content_node: Control = content_scene_to_use.instantiate() as Control
	content_parent.add_child(content_node)
	Util.make_instantiated_scene_local(content_node, content_parent.get_tree().edited_scene_root)
	if !Util.has_text_property(content_node):
		push_warning("can only set content text on a control with a text property, but '", content_node.name, "' does not have a text property. Setting contents will be skipped.")
		return
	
	@warning_ignore("unsafe_property_access") # We already enssured that property exists.
	content_node.text = content_text


static func prepare_text(input: String) -> String:
	return input.strip_edges()#.replace("\n\n", "\n").replace("  ", " ")

static func transform_to_line_infos(input: String) -> Array[SlideInfo]:
	var slide_infos: Array[SlideInfo] = []
	var current_slide_info: SlideInfo = null
	for line: String in input.split("\n"):
		if line == null || line.strip_edges().is_empty():
			if current_slide_info != null:
				slide_infos.append(current_slide_info)
				if current_slide_info.title.is_empty():
					current_slide_info.title = "?" + str(slide_infos.size()) + "?"
			current_slide_info = null
			continue
			
		if current_slide_info == null:
			current_slide_info = SlideInfo.new()	

		if line.begins_with(TITLE_INDICATOR):
			current_slide_info.title = line.trim_prefix(TITLE_INDICATOR)
			continue
			
		#var regex_matches: Array[RegExMatch] = bullet_point_regex.search_all(line)
		
		var bp_index: int = line.find(BULLET_POINT_INDICATOR)
		if bp_index >= 0:
			line = bullet_point_regex.sub(line, line.substr(0, bp_index) + BULLET_POINT_CHAR)
			
		current_slide_info.contents.append(line)
		
	if current_slide_info != null:
		slide_infos.append(current_slide_info)
		if current_slide_info.title.is_empty():
			current_slide_info.title = "?" + str(slide_infos.size()) + "?"
		
	return slide_infos

static func to_debug_string(slide_info: SlideInfo) -> String:
		var res: String = "SlideInfo: '" + slide_info.title + "'\n   "
		res += "\n   ".join(slide_info.contents)
		return res
