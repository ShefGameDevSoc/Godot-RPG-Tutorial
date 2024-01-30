class_name EscapeMenuButton
extends Button

signal option_selected(option)

var option: String

func _on_pressed() -> void:
	option_selected.emit(option)
