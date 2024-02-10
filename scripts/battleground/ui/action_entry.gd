class_name ActionEntry
extends Button

signal action_entry_selected(action)

var _action: Action = null

## Holds the passed in [param action] and fills in the relevant fields in the UI
func fill(action: Action) -> void:
	_action = action
	$MCn/Fields/Name.text = action.name
	$MCn/Fields/Power.text = str(action.power)
	$MCn/Fields/Accuracy.text = "---" if action.cannot_miss else str(action.accuracy)

func _on_pressed() -> void:
	action_entry_selected.emit(_action)
