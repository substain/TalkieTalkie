@tool 
class_name SlideGenerator 
extends Node
## Transforms markdown-like text to multiple Slide nodes
const HEADER_INDICATOR: String = "#"
const HEADER_REGEX: String = "^ *#+\\s"

static var _header_regex: RegEx

class SlideInfo: 
	var title: String = ""
	#var translated_contents
	var contents: Array[String] = []
	var comment: String = ""

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

## If true, lines that only contain whitespace characters will not show up in the generated slides
## If false, generated slides may contain empty lines. No empty slide without title will be created.
@export var ignore_whitespace_lines: bool = true

## Format rules to be processed for each non-empty line that becomes part of the content
## The rules will be applied in their order in the list
## A common rule might be to create bullet points from "*"-characters (see /engine/resources/bullet_point_lfr.tres 
@export var line_format_rules: Array[LineFormatRule] = []

## A regex to indicate lines that should be comments.
## The default matches lines that starts with either '//', '[//]' or '[comment]'
@export var comment_line_regex: String = "^\\s?(?:\\/\\/|\\[\\/\\/\\]|\\[comment\\])"

## Creates the slides from the given text.
@export_tool_button("Generate Slides") var generate_btn: Callable = do_generate.bind()

var _current_slide_info: SlideInfo
var _all_slide_infos: Array[SlideInfo]
var _generated_node_names: Array[String]
var _comment_regex: RegEx

func do_generate() -> void:
	_init_regex()
	
	var slide_infos: Array[SlideInfo] = _transform_to_line_infos(input_text)
	var _slides: Array[SceneSlide] = _instantiate_as_slides(slide_infos)

	#for slide_info: SlideInfo in slide_infos:
		#print(_to_debug_string(slide_info))

func _instantiate_as_slides(slide_infos: Array[SlideInfo]) -> Array[SceneSlide]:
	if slide_scene == null:
		push_warning("Cannot instantiate a null slide scene. Ensure slide_scene_to_use is set in the edtior.")
		return []
		
	_generated_node_names = []
	var res: Array[SceneSlide] = []
	for slide_info: SlideInfo in slide_infos:
		var slide: SceneSlide = _instantiate_slide(slide_info)
		if slide != null:
			res.append(slide)
		
	return res

func _instantiate_slide(slide_info: SlideInfo) -> SceneSlide:
	var target_parent_node: Node = target_parent if target_parent != null else self
	var slide_target_title: String = "Slide" + slide_info.title
	var slide_node_name: String = slide_target_title.replace(" ", "_")
	
	if !_generated_node_names.has(slide_node_name) && target_parent_node.has_node(slide_node_name):
		if ignore_if_slide_name_exists:
			print("Will not create a new slide for '", slide_node_name, "', a node with that name already exists.")
			return null
		if replace_existing_instantiated_slides:
			print("Replacing existing node '", slide_node_name, "' with a newly generated slide.")
			target_parent_node.get_node(slide_node_name).free()
	
	var slide: SceneSlide = slide_scene.instantiate(PackedScene.GEN_EDIT_STATE_INSTANCE) as SceneSlide
	target_parent_node.add_child(slide)
	slide.name = slide_node_name
	_generated_node_names.append(slide.name)
	Util.make_instantiated_scene_local(slide, get_tree().edited_scene_root)
	slide.set_display_folded(true)
	
	_set_title(slide, slide_info.title, slide_title_path)
	_set_contents(slide, slide_info.contents, slide_content_parent_path, content_scene, combine_content_lines)
	slide.comments = slide_info.comment

	return slide

static func _set_title(instantiated_slide: SceneSlide, new_title: String, title_node_path: String) -> void:
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

static func _set_contents(instantiated_slide: SceneSlide, new_contents: Array[String], content_parent_node_path: String, content_scene_to_use: PackedScene, do_combine_content_lines: bool) -> void:
	instantiated_slide.slide_content = "\n".join(new_contents)
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
		_create_content_node(content_parent_node, content_scene_to_use, "\n".join(new_contents))
	else:
		for content_line: String in new_contents:
			_create_content_node(content_parent_node, content_scene_to_use, content_line)

static func _create_content_node(content_parent: Node, content_scene_to_use: PackedScene, content_text: String) -> void:
	var content_node: Control = content_scene_to_use.instantiate() as Control
	content_parent.add_child(content_node)
	Util.make_instantiated_scene_local(content_node, content_parent.get_tree().edited_scene_root)
	content_node.set_display_folded(true)
	if !Util.has_text_property(content_node):
		push_warning("can only set content text on a control with a text property, but '", content_node.name, "' does not have a text property. Setting contents will be skipped.")
		return
	
	@warning_ignore("unsafe_property_access") # We already enssured that this property exists.
	content_node.text = content_text

func _transform_to_line_infos(input: String) -> Array[SlideInfo]:
	_all_slide_infos = []
	_current_slide_info = null
	for line: String in input.split("\n"):
		
		var is_whitespace_only: bool = _is_only_whitespace(line)

		## Ignore empty lines when there was no other content before
		if _current_slide_info == null && is_whitespace_only:
			continue

		## Handle empty lines
		if is_whitespace_only:
			if _current_slide_info != null && !ignore_whitespace_lines:
				_current_slide_info.contents.append(line)
			continue
		
		## Handle headers indicated by '#'
		var has_created_header: bool = _process_header_line(line)
		if has_created_header:
			continue

		## Ensure slide info exists
		if _current_slide_info == null:
			_finish_previous_info_and_create_new()
		
		## Handle comments
		var handled_as_comment: bool = _process_comment(line)
		if handled_as_comment:
			continue
		
		## Handle all other content
		_process_content_line(line)

	## ensure the last processed SlideInfo is also part of the result
	if _current_slide_info != null:
		_all_slide_infos.append(_current_slide_info)
		
	return _all_slide_infos
	
func _finish_previous_info_and_create_new(slide_title: String = "") -> void:
	if _current_slide_info != null:
		_all_slide_infos.append(_current_slide_info)

	_current_slide_info = SlideInfo.new()
	if slide_title == null || slide_title.is_empty():
		_current_slide_info.title = "?" + str(_all_slide_infos.size() + 1) + "?"
	else:
		_current_slide_info.title = slide_title

## check if the line begins with a number of '#'-characters followed by a space (allowing spaces in front)
## if yes: create new slide, set the title, and return true
## otherwise return false
func _process_header_line(line: String) -> bool:
	var md_header_match: RegExMatch = _header_regex.search(line)
	if md_header_match == null:
		return false
		
	var title: String = (line.substr(md_header_match.get_string().length()) as String).strip_edges()
	_finish_previous_info_and_create_new(title)
	#print("line '", line, "' is header depth ", str(md_header_match.get_string().count("#")), " with text ", current_slide_info.title)
	return true
	
func _process_comment(line: String) -> bool:
	if comment_line_regex.is_empty():
		## if we would allow an empty regex here, everything would be marked as comment
		return false
	
	var comment_match: RegExMatch = _comment_regex.search(line)
	if comment_match == null:
		return false
		
	var comment: String = (line.substr(comment_match.get_string().length()) as String).strip_edges()
	if _current_slide_info.comment.is_empty():
		_current_slide_info.comment = comment
	else:
		_current_slide_info.comment = _current_slide_info.comment + "\n" + comment
	
	return true
	
func _process_content_line(line: String) -> void:
	var formatted_line: String = _format_string_by_rules(line)

	_current_slide_info.contents.append(formatted_line)

func _init_regex() -> void:
	_comment_regex = RegEx.new()
	_comment_regex.compile(comment_line_regex)
	
	if _header_regex != null:
		return
		
	_header_regex = RegEx.new()
	_header_regex.compile(HEADER_REGEX)
	
func _format_string_by_rules(line: String) -> String:
	var res: String = line
	for rule: LineFormatRule in line_format_rules:
		res = rule.format(res)
	return res

static func _is_only_whitespace(line: String) -> bool:
	return line == null || line.strip_edges().is_empty()

static func _to_debug_string(slide_info: SlideInfo) -> String:
	var res: String = "SlideInfo: '" + slide_info.title + "'\n   "
	res += "\n   ".join(slide_info.contents)
	return res
