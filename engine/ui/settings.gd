class_name Settings extends HidableUI

signal show_about_window

@export var show_settings_extended: bool = false

@export_category("internal nodes")
@export var open_button: BaseButton
@export var lang_option_button: OptionButton
@export var overall_volume_slider: HSlider
@export var overall_volume_mute_button: CheckBox 
@export var settings_container: PanelContainer
@export var dummy_ui_replacement_button: Button
@export var about_button: Button
@export var restore_side_window_button: Button

var side_window_allowed: bool = false

func _ready() -> void:
	super()
	overall_volume_slider.set_value_no_signal(Preferences.overall_volume)
	lang_option_button.selected = get_locale_button_id(Preferences.language)
	about_button.text = Util.get_talkie_talkie_version()
	set_settings_extended(show_settings_extended)
	update_restore_side_window_button()
	SlideHelper.side_window_settings_updated.connect(update_restore_side_window_button)
	
func update_restore_side_window_button() -> void:
	restore_side_window_button.visible = SlideHelper.is_side_window_restorable

func toggle_settings_extended() -> void:
	set_settings_extended(!show_settings_extended)

func set_settings_extended(is_extended_new: bool) -> void:
	show_settings_extended = is_extended_new
	settings_container.visible = is_extended_new
	#open_button.text = "^" if is_extended_new else "..."

func _on_open_button_pressed() -> void:
	toggle_settings_extended()

func _on_open_button_toggled(toggled_on: bool) -> void:
	set_settings_extended(toggled_on)
	
func _load_values() -> void:
	change_locale(Preferences.language)
	Preferences.language_changed.emit()
	lang_option_button.select(Settings.get_locale_button_id(Preferences.language))
	
func _on_lang_option_button_item_selected(index: int) -> void:
	var locale_new: String = lang_option_button.get_item_text(index);
	var locale_new_short: String = Settings.get_languagecode_fom_locale_uitext(locale_new);
	change_locale(locale_new_short)
	Preferences.set_language(locale_new_short)

func change_locale(locale_short: StringName) -> void:
	TranslationServer.set_locale(locale_short)
	
static func get_languagecode_fom_locale_uitext(locale_str: String) -> StringName:
	if locale_str.contains("English"):
		return &"en";
	else:
		return &"de";

static func get_locale_button_id(locale_short: StringName) -> int:
	match locale_short:
		&"en": return 0
		&"de": return 1
	return 0
	
func _on_overall_volume_slider_value_changed(value: float) -> void:
	PreferencesClass.set_bus_volume(PreferencesClass.AudioType.MASTER, value)
	Preferences.set_overall_volume(value, false)
	
func _on_overall_volume_slider_drag_ended(value_changed: bool) -> void:
	if value_changed:
		Preferences.set_overall_volume(overall_volume_slider.value)

func _on_overall_volume_mute_button_toggled(toggled_on: bool) -> void:
	PreferencesClass.set_bus_muted(PreferencesClass.AudioType.MASTER, toggled_on)
	Preferences.set_overall_volume_muted(toggled_on)

func update_ui_button_position(include_in_settings_ui: bool, ui_button: Button) -> void:
	if include_in_settings_ui:
		ui_button.reparent(dummy_ui_replacement_button.get_parent())
		dummy_ui_replacement_button.queue_free()
	else:
		dummy_ui_replacement_button.modulate.a = 0.0
		
func _on_about_button_pressed() -> void:
	show_about_window.emit()

func _on_restore_side_window_button_pressed() -> void:
	SlideHelper.restore_side_window.emit()
