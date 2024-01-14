extends Node

@export var _actor: OWActor

func _process(delta: float) -> void:
	if _actor.move_direction != OWActor.MoveDirection.NONE:
		return

	if Input.is_action_pressed("up"):
		_actor.move_direction = OWActor.MoveDirection.UP
	elif Input.is_action_pressed("down"):
		_actor.move_direction = OWActor.MoveDirection.DOWN
	elif Input.is_action_pressed("left"):
		_actor.move_direction = OWActor.MoveDirection.LEFT
	elif Input.is_action_pressed("right"):
		_actor.move_direction = OWActor.MoveDirection.RIGHT
