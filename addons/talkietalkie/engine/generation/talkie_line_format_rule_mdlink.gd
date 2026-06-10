@tool
class_name TalkieLineFormatRuleMdLink
extends TalkieLineFormatRule

const _LINK_REGEX: String = "\\[(.*?)(?:\\]\\()(.*?)\\)" # TODO: use named recursion groups instead
static var _regex: RegEx = null

func format(line: String) -> String:
	_init_regex()
			
	var search_matches: Array[RegExMatch] = _regex.search_all(line)
	if search_matches.is_empty():
		return line

	TalkieUtil.tt_debug("(LineFormatRuleMdLink) replacing %s matches in '%s'" % [search_matches.size(), line])
	var res: String = line
	var index_offset: int = 0
	for rgmatch: RegExMatch in search_matches:
		var length_before: int = res.length()
		var res_before_debug: String = res
		res = replace_at_pos(res, get_replaced_string(rgmatch), rgmatch.get_start() + index_offset, rgmatch.get_end() + index_offset)
		TalkieUtil.tt_debug("(LineFormatRuleMdLink) io: %s: rgm(%s) at (%s|%s). changed '%s' to '%s'"% [index_offset, rgmatch.get_group_count(), rgmatch.get_start(), rgmatch.get_end(), res_before_debug, res])

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
