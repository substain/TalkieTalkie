class_name Slide extends CanvasItem

@export var slide_title: String

## Nodes that have a "text" property to be translated with the given translation_target
@export var translations: Dictionary[Node, TranslationTarget]

var order_index: int

func _ready() -> void:
	reset()
	Preferences.language_changed.connect(translate)
	translate()
	
## reset the current slides progress
func reset() -> void:
	pass

## skip animations and show the full slide
func show_full() -> void:
	pass

## Continues the current slide progress. Returns true if the full slide is shown.
func continue_slide() -> bool:
	return true
	
## Returns true if the current slide is at the start position
func is_at_start() -> bool:
	return true

## Returns true if the current slide is finished.
func is_finished() -> bool:
	return true

func translate() -> void:
	for translation_node: Node in translations:
		translations[translation_node].translate(translation_node)
