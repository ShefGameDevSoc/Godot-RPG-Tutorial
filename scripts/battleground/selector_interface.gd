class_name SelectorInterface
extends Node

signal action_selection_started(me: BGActor, allies: Array[BGActor], opponents: Array[BGActor])
signal action_selected(target: BGActor, action: Action)
