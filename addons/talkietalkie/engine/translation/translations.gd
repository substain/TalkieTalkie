class_name Translations
extends Node

class TranslationTemplate:
	var template_text: String
	var translation_targets: Array[TranslationTarget] = []
	
	func _init(template_text_new: String) -> void:
		template_text = template_text_new

	func translate() -> String:
		var res: String = template_text
		for tt: TranslationTarget in translation_targets:
			var this_translation: String = tr(tt.translation_key).format(tt.positional_placeholders)
			res = res.replace(tt.translation_key, this_translation)
			res = TalkieTalkie.replace_plugin_path(res)
		return res

@export var target_nodes: Array[Node]

## Nodes that have a "text" property to be translated with the given translation_target
@export var translation_targets: Array[TranslationTarget]

#@export var translation_targets: Array[Node]
var translation_templates: Dictionary[Node, TranslationTemplate] = {}

func _ready() -> void:
	TTPreferences.language_changed.connect(translate)
	infer_target_nodes()
	prepare_translation()
	translate()
	
func infer_target_nodes() -> void:
	if !target_nodes.is_empty():
		return
	
	var children: Array[Node] = get_children()
	if !children.is_empty():
		target_nodes = []
		for ch: Node in children:
			if Util.has_text_property(ch):
				target_nodes.append(ch)
		target_nodes = children
		return
		
	if Util.has_text_property(self):
		target_nodes = [self]
		return

	if Util.has_text_property(get_parent()):
		target_nodes = [get_parent()]
		return
	
	print("No translation target set up for '", self.name, "'")

func prepare_translation() -> void:
	for target_node: Node in target_nodes:
		if !Util.has_text_property(target_node):
			push_warning("Translations expects all target nodes to have a 'text' property, but '", target_node, "' does not have one. Skipping this node.")
			continue
			
		@warning_ignore("unsafe_property_access")
		var template_text: String = target_node.text as String
		var translation_template: TranslationTemplate = TranslationTemplate.new(template_text)
		
		for tt: TranslationTarget in translation_targets:
			if template_text.contains(tt.translation_key):
				translation_template.translation_targets.append(tt)
				
		if !translation_template.translation_targets.is_empty():
			translation_templates[target_node] = translation_template
		
				
func translate() -> void:
	for target_node: Node in translation_templates.keys():
		@warning_ignore("unsafe_property_access")
		target_node.text = translation_templates[target_node].translate()
