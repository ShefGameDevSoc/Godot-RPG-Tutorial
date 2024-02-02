class_name BattleTrigger
extends Node
## Triggers a battle when a player walks into the same grid space this trigger is in
##
## The parent is expected to be an [OWActor] to which this script connects to it's
## [signal other_entered_my_cell] signal

func _on_ow_random_walker_other_entered_my_cell(other_actor: OWActor) -> void:
	if not other_actor.is_in_group("player"):
		return

	var owactor: OWActor = get_parent()
	Game.enter_battle(other_actor.characters, owactor.characters)
