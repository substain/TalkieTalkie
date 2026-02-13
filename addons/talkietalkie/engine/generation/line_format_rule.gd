@tool
class_name LineFormatRule
extends Resource

## the regex that will be searched within the string. 
## may find multiple matches in the string
@export var search_regex: String

## the string inside each regex match that will be replaced
## if this is empty (default), the complete match will be replaced
@export var to_replace_str: String = ""

## the string that will be used as a replacement
@export var replace_with_str: String = ""

var _used_search_regex: String
var _regex: RegEx = null

func format(line: String) -> String:
	_init_regex()
	
	var search_matches: Array[RegExMatch] = _regex.search_all(line)
	if search_matches.is_empty():
		return line
	
	var res: String = line
	for rgmatch: RegExMatch in search_matches:
		if to_replace_str.is_empty():
			res = res.replace(rgmatch.get_string(), replace_with_str)
		else:
			res = res.replace(to_replace_str, replace_with_str)
		
	return res

func _init_regex() -> void:
	if _regex == null || _used_search_regex != search_regex:
		_regex = RegEx.new()
		var res = _regex.compile(search_regex)
		_used_search_regex = search_regex
