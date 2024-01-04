extends Node

var world: World = null

func _ready():
	var worlds := get_tree().get_nodes_in_group("world")
	if len(worlds) > 0:
		world = worlds[0]
