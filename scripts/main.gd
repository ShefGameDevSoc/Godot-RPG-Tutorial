extends Node

const scr_battle_trigger := preload("res://scripts/overworld/battle_trigger.gd")

@export var _overworld: Overworld
@export var _overworld_camera: Camera2D

@export var _battleground: BattleGround

@export var _menu: Menu

@export var _player_actor: PackedScene
@export var _roaming_enemies: Array[PackedScene]

@export var _player_def: CharacterDefinition
@export var _enemy_defs: Array[CharacterDefinition]

var _paused := false

func _ready() -> void:
	Game.switch_to_overworld_cameras()
	Game.in_battle = false

	var rng := RandomNumberGenerator.new()
	rng.randomize()

	var player: OWActor = _player_actor.instantiate()
	_overworld.add_child(player)
	player.characters = [ _player_def.create(rng) ]
	player.add_to_group("player")
	_overworld_camera.reparent(player)
	
	var player_coords: Vector2i = _overworld.get_actor_cell_coords(player)
	var walkable_coords: Array[Vector2i] = _overworld.get_unused_walkable_coords()

	# Defines a range relative to the player within which enemies cannot spawn
	var buffer := 4
	for x in range(player_coords.x - buffer, player_coords.x + buffer + 1):
		for y in range(player_coords.y - buffer, player_coords.y + buffer + 1):
			var coord := Vector2i(x, y)
			if Vector2(coord - player_coords).length() > buffer:
				continue
			
			if coord in walkable_coords:
				walkable_coords.erase(coord)

	var num_enemies_to_spawn := rng.randi_range(4, 9)
	for i in num_enemies_to_spawn:
		var def_idx := rng.randi() % len(_enemy_defs)
		var enemy: Character = _enemy_defs[def_idx].create(rng)

		var walker_idx := rng.randi() % len(_roaming_enemies)
		var ow_walker: OWActor = _roaming_enemies[walker_idx].instantiate()
		ow_walker.is_blocking = false
		ow_walker.characters = [ enemy ]

		var coord_idx := rng.randi() % len(walkable_coords)
		var enemy_coord: Vector2i = walkable_coords[coord_idx]
		ow_walker.position = _overworld.tilemap.map_to_local(enemy_coord)
		_overworld.add_child(ow_walker)
		walkable_coords.remove_at(coord_idx)
		
		var battle_trigger := Node.new()
		battle_trigger.set_script(scr_battle_trigger)
		ow_walker.add_child(battle_trigger)
		ow_walker.other_entered_my_cell.connect((battle_trigger as BattleTrigger)._on_ow_random_walker_other_entered_my_cell)

func _input(event: InputEvent) -> void:
	if not event.is_action_pressed("open_menu"):
		return
	if Game.in_battle:
		return

	if _paused:
		_paused = false
		_menu.close()
		_overworld.process_mode = Node.PROCESS_MODE_ALWAYS
	else:
		_paused = true
		_menu.open()
		_overworld.process_mode = Node.PROCESS_MODE_DISABLED
