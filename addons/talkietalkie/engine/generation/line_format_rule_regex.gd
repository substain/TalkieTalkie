@tool
class_name LineFormatRuleRegex
extends LineFormatRule

## the regex that will be searched within the string. 
## may find multiple matches in the string
@export var search_regex: String

## the strings that will be used as a replacement. 
## If the regex string does not define capture groups, everything will be replaced by the first element
## Otherwise, all capture groups will be replaced with a matching string in this array as long as there are matching strings
@export var replacement_strings: Array[String] = [""]

var _used_search_regex: String
var _regex: RegEx = null

func format(line: String) -> String:
	_init_regex()
	
	if replacement_strings.size() == 0:
		replacement_strings = [""]
		
	var search_matches: Array[RegExMatch] = _regex.search_all(line)
	if search_matches.is_empty():
		return line

	#print("replacing ", search_matches.size(), " matches in '", line, "'")
	var res: String = line
	var index_offset: int = 0
	for rgmatch: RegExMatch in search_matches:
		var length_before: int = res.length()
		var res_before_debug: String = res
		res = replace_at_pos(res, get_replaced_string(rgmatch, replacement_strings), rgmatch.get_start() + index_offset, rgmatch.get_end() + index_offset)
		#print("io: ", index_offset, ": rgm(",rgmatch.get_group_count(),") at (",rgmatch.get_start(),"|",rgmatch.get_end(),"). changed '", res_before_debug, "' to '", res, "'")

		index_offset = index_offset + res.length() - length_before
		
	return res
	
static func get_replaced_string(rgmatch: RegExMatch, replacements: Array[String]) -> String:
	if rgmatch.get_group_count() == 0:
		return replacements[0]
		
	var repl_string: String = rgmatch.get_string()
	var matches: PackedStringArray = rgmatch.strings
	matches.remove_at(0) # full regex match

	var current_search_index: int = 0
	for rp_idx: int in replacements.size():
		if matches.size() < rp_idx+1:
			break
			
		var m: String = matches[rp_idx]
		
		var first_idx: int = repl_string.find(m, current_search_index)
		if first_idx == -1:
			push_warning("could not find capture group for '", m, "' in '", repl_string, "' from index ", current_search_index)
		
		var target: String = replacements[rp_idx]

		var end_index: int = first_idx + m.length()
		repl_string = replace_at_pos(repl_string, target, first_idx, end_index)
		current_search_index = first_idx + target.length()
		#print("replaced '", m ,"' for '", replacements[rp_idx], "' in target string: '", repl_string, "'")

	return repl_string

func _init_regex() -> void:
	if _regex == null || _used_search_regex != search_regex:
		_regex = RegEx.new()
		var error_status: Error = _regex.compile(search_regex)
		if error_status != OK:
			print("LineFormatRule: Could not compile '", search_regex, "' : Error = ", error_status)
		else:
			_used_search_regex = search_regex
