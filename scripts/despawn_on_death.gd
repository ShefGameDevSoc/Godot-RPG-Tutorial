extends Node
## Removes and deletes the [OWActor] upon receiving [signal OWActor.on_actor_died]
##
## NOTE This script expects the [OWActor] to be its direct parent

func _on_actor_died() -> void:
	if Game.world != null:
		Game.world.remove_actor(get_parent())
	get_parent().queue_free()
