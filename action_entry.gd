class_name ActionEntry
extends Button

signal action_entry_selected(action)

var _action: Action = null

func fill(action: Action) -> void:
	_action = action
	$MCn/Fields/Name.text = action.name
	$MCn/Fields/Power.text = str(action.power)
	$MCn/Fields/Accuracy.text = "---" if action.cannot_miss else str(action.accuracy)


func _on_pressed():
	action_entry_selected.emit(_action)
