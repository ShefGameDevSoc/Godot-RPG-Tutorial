extends Node
## Kills the game upon receiving [signal OWActor.on_actor_died]
##
## NOTE This script expects the [OWActor] to be its direct parent

func _on_actor_died() -> void:
	get_tree().quit()
