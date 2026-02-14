@tool
class_name LineFormatRule
extends Resource

func format(line: String) -> String:
	## Dummy implementation. Overwrite this in inherited classes.
	return line


static func replace_at_pos(str_to_replace: String, replace_str: String, start_pos: int, end_pos: int) -> String:
	return str_to_replace.left(start_pos) + replace_str + str_to_replace.right(-end_pos)
