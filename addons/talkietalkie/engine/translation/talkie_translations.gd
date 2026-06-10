class_name TalkieTranslations
extends Node

class TranslationTemplate:
	var template_text: String
	var translation_targets: Array[TalkieTranslationTarget] = []
	
	func _init(template_text_new: String) -> void:
		template_text = template_text_new

	func translate() -> String:
		var res: String = template_text
		for tt: TalkieTranslationTarget in translation_targets:
			var this_translation: String = tr(tt.translation_key).format(tt.positional_placeholders)
			res = res.replace(tt.translation_key, this_translation)
			res = TalkieSetup.replace_addon_path(res)
		return res

## Nodes that have a "text" property to be translated with the given translation_target
@export var translation_targets: Array[TalkieTranslationTarget]

## The target nodes that should be translated.
## If this is empty, all children nodes that have a "text" property are collected and setup as targets. This is slightly less performant.
@export var target_nodes: Array[Node]

var translation_templates: Dictionary[Node, TranslationTemplate] = {}

func _ready() -> void:
	TalkiePreferences.language_changed.connect(translate)
	clean_target_nodes()
	infer_target_nodes()
	prepare_translation()
	translate()
	
func clean_target_nodes() -> void:
	if target_nodes.is_empty():
		return
	
	for i: int in target_nodes.size():
		var rev_i: int = target_nodes.size()-1 - i
		if target_nodes[rev_i] == null:
			target_nodes.remove_at(rev_i)
	
func infer_target_nodes() -> void:
	if !target_nodes.is_empty():
		return
	
	var text_children: Array[Node] = TalkieUtil.collect_text_nodes_in_children(get_parent())
	if !text_children.is_empty():
		target_nodes = text_children
		#target_nodes = children
		return
		
	if TalkieUtil.has_text_property(self):
		target_nodes = [self]
		return

	if TalkieUtil.has_text_property(get_parent()):
		target_nodes = [get_parent()]
		return
	
	TalkieUtil.tt_warn("No translation target set up for '%s'. Freeing..."  % self.name)
	queue_free()

func prepare_translation() -> void:
	# ensure translation targets are sorted by the length of their translation keys (descending), because they can contain each other
	translation_targets.sort_custom(sort_by_tt_key_length_desc)
	
	for target_node: Node in target_nodes:
		if !TalkieUtil.has_text_property(target_node):
			TalkieUtil.tt_warn("Translations expects all target nodes to have a 'text' property, but '%s' does not have one. Skipping this node." % target_node)
			continue
			
		@warning_ignore("unsafe_property_access")
		var template_text: String = target_node.text as String
		var translation_template: TranslationTemplate = TranslationTemplate.new(template_text)
		
		for tt: TalkieTranslationTarget in translation_targets:
			if template_text.contains(tt.translation_key):
				translation_template.translation_targets.append(tt)
				
		if !translation_template.translation_targets.is_empty():
			translation_templates[target_node] = translation_template
		
				
func translate() -> void:
	for target_node: Node in translation_templates.keys():
		@warning_ignore("unsafe_property_access")
		target_node.text = translation_templates[target_node].translate()

func sort_by_tt_key_length_desc(tt1: TalkieTranslationTarget, tt2: TalkieTranslationTarget) -> bool:
	return tt1.translation_key.length() > tt2.translation_key.length()
