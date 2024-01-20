class_name BattleTrigger
extends Node

@export_range(1, 5) var _max_num_enemies := 1

@export var _potential_enemies: Array[ActionLibrary]

func _on_ow_random_walker_other_entered_my_cell(other_actor: OWActor) -> void:
	if not other_actor.is_in_group("player"):
		return

	var owactor: OWActor = get_parent()
	Game.enter_battle(other_actor.characters, owactor.characters)
