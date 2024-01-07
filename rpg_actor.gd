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
	await selector.action_selected
	print("Selection Made")
