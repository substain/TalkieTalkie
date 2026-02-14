@tool
class_name LineFormatRuleMdLink
extends LineFormatRule

const _LINK_REGEX: String = "\\[(.*?)(?:\\]\\()(.*?)\\)" # TODO: use named recursion groups instead
static var _regex: RegEx = null

func format(line: String) -> String:
	_init_regex()
			
	var search_matches: Array[RegExMatch] = _regex.search_all(line)
	if search_matches.is_empty():
		return line

	print("replacing ", search_matches.size(), " matches in '", line, "'")
	var res: String = line
	var index_offset: int = 0
	for rgmatch: RegExMatch in search_matches:
		var length_before: int = res.length()
		var res_before_debug: String = res
		res = replace_at_pos(res, get_replaced_string(rgmatch), rgmatch.get_start() + index_offset, rgmatch.get_end() + index_offset)
		print("io: ", index_offset, ": rgm(",rgmatch.get_group_count(),") at (",rgmatch.get_start(),"|",rgmatch.get_end(),"). changed '", res_before_debug, "' to '", res, "'")

		index_offset = index_offset + res.length() - length_before
		
	return res
	
static func get_replaced_string(rgmatch: RegExMatch) -> String:
	var repl_string: String = rgmatch.get_string()

	var url_name: String = rgmatch.strings[1]
	var url: String = rgmatch.strings[2]
		
	return "[url="+url+"]"+url_name+"[/url]"

func _init_regex() -> void:
	if _regex == null:
		_regex = RegEx.new()
		_regex.compile(_LINK_REGEX)
