extends Node

func _on_actor_died() -> void:
	get_tree().quit()
