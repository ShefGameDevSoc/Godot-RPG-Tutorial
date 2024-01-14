extends Node

@export var _actor: OWActor
@export_range(0, 20) var move_timeout := 1.0

@onready var _timer: Timer = $Timer
@onready var rng: RandomNumberGenerator = RandomNumberGenerator.new()

func _ready() -> void:
	rng.randomize()
	_timer.start(move_timeout)

func _on_timeout() -> void:
	var dir := _random_dir()
	_actor.move_direction = dir
	_timer.start(move_timeout)

func _random_dir() -> OWActor.MoveDirection:
	var i := rng.randi() % 4
	match i:
		0:
			return OWActor.MoveDirection.DOWN
		1:
			return OWActor.MoveDirection.UP
		2:
			return OWActor.MoveDirection.LEFT
		3:
			return OWActor.MoveDirection.RIGHT

	return OWActor.MoveDirection.NONE
