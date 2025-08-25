class_name TranslationTarget extends Resource

## The key to be translated. 
@export var translation_key: String

## if the translated contains positional placeholders, i.e. {0}, {1} ,... they will be replaced with these strings.
@export var positional_placeholders: Array[String]

var text_template: String = ""

func translate(target_element: Node) -> void:
	if !("text" in target_element):
		push_warning("can only translate controls with a text property")
		return
		
	@warning_ignore("unsafe_property_access")
	var current_text: String = target_element.text as String
	if current_text.contains(translation_key):
		text_template = current_text
	elif text_template == "":
		text_template = translation_key

	var translation: String = text_template.replace(translation_key, tr(translation_key))
	for i: int in positional_placeholders.size():
		translation = translation.replace("{%s}" % i, tr(positional_placeholders[i]))
	
	@warning_ignore("unsafe_property_access")
	target_element.text = translation
