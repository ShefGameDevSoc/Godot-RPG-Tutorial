class_name Overworld
extends Node2D

@export_range(0.5, 5) var move_speed: float = 1.6

@export var tile_map_ground_layer := 1

@export var _tilemap: TileMap

var actors: Array[OWActor] = []
var occupied_cells: Dictionary = {}

class MovingActor:
	var actor: OWActor
	var start_pos: Vector2
	var direction: Vector2
	var speed: float

var moving_actors: Array[MovingActor] = []

func add_actor(actor: OWActor):
	if not actors.has(actor):
		# Moving the actor to its closest place on the grid
		var half_size: Vector2 = _tilemap.tile_set.tile_size * 0.5
		var asjusted_actor_pos: Vector2 = actor.position - half_size

		var ratio_to_tile_size: Vector2 = asjusted_actor_pos / Vector2(_tilemap.tile_set.tile_size)
		var floored_ratio: Vector2 = floor(ratio_to_tile_size)
		actor.position = floored_ratio * Vector2(_tilemap.tile_set.tile_size) + half_size
		actors.append(actor)

		var actor_coords: Vector2i = _tilemap.local_to_map(_tilemap.to_local(actor.position))
		if actor_coords in occupied_cells:
			occupied_cells[actor_coords].append(actor)
		else:
			occupied_cells[actor_coords] = [ actor ]

func remove_actor(actor: OWActor):
	if actor.has(actor):
		actors.erase(actor)

# Called when the node enters the scene tree for the first time.
func _ready():
	if Game.world == null:
		Game.world = self

func _process(delta: float) -> void:
	for actor in actors:
		if actor.move_direction == OWActor.MoveDirection.NONE:
			continue

		_move_actor(actor)

	var to_remove: Array[int] = []
	for i in moving_actors.size():
		var ma: MovingActor = moving_actors[i]
		var travelled := ma.actor.position - ma.start_pos

		var length_of_direction_of_travel: float = Vector2(abs(ma.direction) * Vector2(_tilemap.tile_set.tile_size)).length()
		var covered_dist := travelled.length()
		var step_dist: float = length_of_direction_of_travel * delta * ma.speed
		var delta_dist := step_dist
		if covered_dist + step_dist >= length_of_direction_of_travel:
			delta_dist = length_of_direction_of_travel - covered_dist
			to_remove.append(i)

		ma.actor.position += delta_dist * ma.direction

	for i in to_remove:
		var ma: MovingActor = moving_actors[i]
		ma.actor.move_direction = OWActor.MoveDirection.NONE
		moving_actors.remove_at(i)

func _move_actor(actor: OWActor) -> void:
	for ma in moving_actors:
		if ma.actor == actor:
			return

	var direction := Vector2()
	match actor.move_direction:
		OWActor.MoveDirection.UP:
			direction = Vector2.UP
		OWActor.MoveDirection.DOWN:
			direction = Vector2.DOWN
		OWActor.MoveDirection.LEFT:
			direction = Vector2.LEFT
		OWActor.MoveDirection.RIGHT:
			direction = Vector2.RIGHT

	var current_coords: Vector2i = _tilemap.local_to_map(_tilemap.to_local(actor.position))
	var next_tile_coords := current_coords + Vector2i(direction)
	var next_tile_data: TileData = _tilemap.get_cell_tile_data(tile_map_ground_layer, next_tile_coords)
	var next_tile_is_walkable = next_tile_data.get_custom_data("walkable")

	var next_tile_is_blocked := false
	if next_tile_coords in occupied_cells:
		for a: OWActor in occupied_cells[next_tile_coords]:
			if a.is_blocking:
				next_tile_is_blocked = true
				break

	if not next_tile_is_walkable or next_tile_is_blocked:
		actor.bumped_into_unwalkable.emit(actor.move_direction)
		actor.move_direction = OWActor.MoveDirection.NONE
		return

	var moving_actor := MovingActor.new()
	moving_actor.actor = actor
	moving_actor.start_pos = actor.position
	moving_actor.direction = direction
	moving_actor.speed = move_speed * actor.move_speed_multiplier
	moving_actors.append(moving_actor)

	occupied_cells[current_coords].erase(actor)
	if len(occupied_cells[current_coords]) == 0:
		occupied_cells.erase(current_coords)
		
	if next_tile_coords in occupied_cells:
		occupied_cells[next_tile_coords].append(actor)
	else:
		occupied_cells[next_tile_coords] = [ actor ]
