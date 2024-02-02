class_name Overworld
extends Node2D
## Responsible for placing and moving [OWActor]s about a [TileMap]
##
## Implements grid-based movement by moving [OWActor]s in the direction they request to be moved
## in
## When an actor moves into a new cell, the [signal OWActor.other_entered_my_cell] signal is
## emitted on all actors in that cell

const UNUSED_TILE_COORDS := Vector2i(100000, 100000)

@export_range(0.5, 5) var move_speed: float = 1.6

@export var tile_map_ground_layer := 1

@export var tilemap: TileMap

var actors: Array[OWActor] = []
var occupied_cells: Dictionary = {}

class MovingActor:
	var actor: OWActor
	var start_pos: Vector2
	var direction: Vector2
	var speed: float

var moving_actors: Array[MovingActor] = []

func enter() -> void:
	for actor in actors:
		actor.check_if_alive()

# Adds the [param actor] to the overworld, moving it to nearest space on the tilemap
func add_actor(actor: OWActor):
	if actors.has(actor):
		return

	# Moving the actor to its closest place on the grid
	var half_size: Vector2 = tilemap.tile_set.tile_size * 0.5
	var asjusted_actor_pos: Vector2 = actor.position - half_size

	var ratio_to_tile_size: Vector2 = asjusted_actor_pos / Vector2(tilemap.tile_set.tile_size)
	var floored_ratio: Vector2 = floor(ratio_to_tile_size)
	actor.position = floored_ratio * Vector2(tilemap.tile_set.tile_size) + half_size
	actors.append(actor)

	var actor_coords: Vector2i = tilemap.local_to_map(tilemap.to_local(actor.position))
	if actor_coords in occupied_cells:
		occupied_cells[actor_coords].append(actor)
	else:
		occupied_cells[actor_coords] = [ actor ]

## Removes the [param actor] from the overworld
func remove_actor(actor: OWActor):
	if actors.has(actor):
		actors.erase(actor)

func get_unused_walkable_coords() -> Array[Vector2i]:
	var all_coords: Array[Vector2i] = tilemap.get_used_cells_by_id(tile_map_ground_layer)
	var walkable_coords: Array[Vector2i] = []
	for coord in all_coords:
		var tile_data: TileData = tilemap.get_cell_tile_data(tile_map_ground_layer, coord)

		if tile_data.get_custom_data("walkable"):
			walkable_coords.append(coord)

	for actor in actors:
		var actor_coords := get_actor_cell_coords(actor)
		if actor_coords in walkable_coords:
			all_coords.erase(actor_coords)
	
	return walkable_coords

func get_actor_cell_coords(actor: OWActor) -> Vector2i:
	if not actor in actors:
		return UNUSED_TILE_COORDS
	return tilemap.local_to_map(tilemap.to_local(actor.position))

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

		var length_of_direction_of_travel: float = Vector2(abs(ma.direction)
												   * Vector2(tilemap.tile_set.tile_size)).length()
		var covered_dist := travelled.length()
		var step_dist: float = length_of_direction_of_travel * delta * ma.speed
		var delta_dist := step_dist
		if covered_dist + step_dist >= length_of_direction_of_travel:
			delta_dist = length_of_direction_of_travel - covered_dist
			to_remove.append(i)

		ma.actor.position += delta_dist * ma.direction

	to_remove.sort_custom(func(a, b): return a > b)
	for i in to_remove:
		var ma: MovingActor = moving_actors[i]
		ma.actor.move_direction = OWActor.MoveDirection.NONE
		moving_actors.remove_at(i)

		var coords: Vector2i = tilemap.local_to_map(tilemap.to_local(ma.actor.position))
		if coords in occupied_cells:
			for other: OWActor in occupied_cells[coords]:
				other.other_entered_my_cell.emit(ma.actor)

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

	var current_coords: Vector2i = get_actor_cell_coords(actor)
	var next_tile_coords := current_coords + Vector2i(direction)
	var next_tile_data: TileData = tilemap.get_cell_tile_data(tile_map_ground_layer, next_tile_coords)
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
