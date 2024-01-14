extends Node

@export_range(1, 5) var _max_num_enemies := 1

@export var _potential_enemies: Array[ActionLibrary]

func _on_ow_random_walker_other_entered_my_cell(other_actor: OWActor) -> void:
	if not other_actor.is_in_group("player"):
		return

	var enemies: Array[Character] = []
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	var num_enemies := rng.randi()
	for i in range(min(num_enemies, _max_num_enemies)):
		var char := Character.new()
		char.action_library = _potential_enemies[rng.randi() % len(_potential_enemies)]
		char.max_health = rng.randf_range(40, 300)
		char.attack = rng.randi_range(30, 60)
		char.defense = rng.randi_range(20, 60)
		
		if rng.randf() > 0.3:
			char.health = char.max_health
		else:
			char.health = rng.randi_range(char.max_health * 0.8, char.max_health)

		enemies.append(char)

	print(len(enemies))
	Game.enter_battle(enemies)
