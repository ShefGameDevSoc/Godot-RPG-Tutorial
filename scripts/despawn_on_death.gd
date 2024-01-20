extends Node

func _on_actor_died() -> void:
	if Game.world != null:
		Game.world.remove_actor(get_parent())
	get_parent().queue_free()
