class_name RPGActor
extends Node

signal action_selection_started

@export var library: ActionLibrary

var selector = null

func make_choice() -> void:
	print("Making choice")
	action_selection_started.emit()
	if selector == null:
		print("%s's selector is unassigned" % name)
		return
	var action: Action = await selector.action_selected
	if action == null:
		return
	print(action.name)
