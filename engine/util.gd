class_name Util

const WEB_OS_FEATURE: String = "web"
const ANDROID_OS_NAME: String = "Android"
const IOS_OS_NAME: String = "iOS"

static var extract_num_regex: RegEx = null

static func compare_by_last_number(a: Slide, b: Slide) -> int:
	return last_number_or_zero(a.name) < last_number_or_zero(b.name)

static func ensure_extract_num_regex_initialized() -> void:
	if extract_num_regex == null:
		extract_num_regex = RegEx.new()
		extract_num_regex.compile("\\d+")	

static func last_number_or_zero(str_name: String) -> int:
	ensure_extract_num_regex_initialized()
	
	var numbers_in_string: Array[RegExMatch] = extract_num_regex.search_all(str_name)
	if numbers_in_string.size() == 0:
		return 0
	var res: int = int(numbers_in_string[numbers_in_string.size()-1].subject)
	return res
		
static func collect_slides_in_children(node: Node) -> Array[Slide]:
	var res: Array[Slide] = []
	if node is Slide:
		res.append(node as Slide)
		
	for child: Node in node.get_children():
		var children_nodes: Array[Slide]= collect_slides_in_children(child)
		res.append_array(children_nodes)
				
	return res
	
static func is_web() -> bool:
	return OS.has_feature("web")
	
static func is_mobile() -> bool:
	return OS.get_name() == ANDROID_OS_NAME || OS.get_name() == IOS_OS_NAME || OS.has_feature("web_android") || OS.has_feature("web_ios") 

static func get_talkie_talkie_version() -> String:
	return "v" + ProjectSettings.get_setting("application/config/version")

static func get_godot_version() -> String:
	return Engine.get_version_info()["string"]
