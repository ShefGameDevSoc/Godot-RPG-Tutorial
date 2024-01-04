class_name World
extends Node2D

@export_range(10, 500) var step_size: int = 32
@export_range(0.5, 5) var default_move_speed: float = 1.6

var actors: Array[Actor] = []

class MovingActor:
	var actor: Actor
	var start_pos: Vector2
	var direction: Vector2
	var speed: float

var moving_actors: Array[MovingActor] = []

func add_actor(actor: Actor):
	if not actors.has(actor):
		# Moving the actor to its closest place on the grid
		var step_size_factor: Vector2 = actor.position / step_size
		var closest_mult_of_step_size: Vector2 = floor(step_size_factor)
		actor.position = closest_mult_of_step_size * step_size
		actors.append(actor)

func remove_actor(actor: Actor):
	if actor.has(actor):
		actors.erase(actor)

# Called when the node enters the scene tree for the first time.
func _ready():
	if Game.world == null:
		Game.world = self


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	for actor in actors:
		if actor.move_direction == Actor.MoveDirection.NONE:
			continue

		_move_actor(actor)

	var to_remove: Array[int] = []
	for i in moving_actors.size():
		var ma: MovingActor = moving_actors[i]
		var travelled := ma.actor.position - ma.start_pos

		var covered_dist := travelled.length()
		var step_dist: float = step_size * delta * ma.speed
		print(step_dist)
		var delta_dist := step_dist
		if covered_dist + step_dist >= step_size:
			delta_dist = step_size - covered_dist
			ma.actor.move_direction = Actor.MoveDirection.NONE
			to_remove.append(i)

		ma.actor.position += delta_dist * ma.direction

	for i in to_remove:
		moving_actors.remove_at(i)

func _move_actor(actor: Actor) -> void:
	for ma in moving_actors:
		if ma.actor == actor:
			return

	var direction := Vector2()
	match actor.move_direction:
		Actor.MoveDirection.UP:
			direction = Vector2.UP
		Actor.MoveDirection.DOWN:
			direction = Vector2.DOWN
		Actor.MoveDirection.LEFT:
			direction = Vector2.LEFT
		Actor.MoveDirection.RIGHT:
			direction = Vector2.RIGHT

	var moving_actor := MovingActor.new()
	moving_actor.actor = actor
	moving_actor.start_pos = actor.position
	moving_actor.direction = direction
	moving_actor.speed = default_move_speed
	moving_actors.append(moving_actor)
